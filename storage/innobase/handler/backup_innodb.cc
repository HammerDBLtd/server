/* Copyright (c) 2026, MariaDB plc

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1335  USA */

#include "my_global.h"
#include "sql_class.h"
#include "backup_innodb.h"
#include "sql_backup_interface.h"
#include "trx0trx.h"
#include "buf0flu.h"
#include "log0crypt.h"
#include <vector>
#ifdef __linux__
# include <fcntl.h>
# include <linux/falloc.h>
#endif

/** Associate a transaction with the current session
@param thd   session
@return InnoDB transaction */
trx_t *check_trx_exists(THD *thd) noexcept;

namespace
{
/** Backup state; protected by log_sys.latch */
class InnoDB_backup
{
  /** pointer to backup context, or nullptr if no backup is active */
  trx_t *trx;
  /** the original innodb_log_file_size, or 0 */
  uint64_t old_size;

  /** collection of files to be copied */
  std::vector<uint32_t> queue;
  /** collection of completed log archive files to be
  hard-linked, copied, or moved */
  std::vector<lsn_t> logs;

  /** @return the backup context */
  backup_context &context() const noexcept
  { ut_ad(log_sys.latch_have_any()); ut_ad(trx); return trx->lock.backup; }

public:
  /**
     Start of BACKUP SERVER: collect all files to be backed up
     @param thd     current session
     @param target  backup target
     @return error code
     @retval 0 on success
  */
  int init(THD *thd, const backup_target &target) noexcept
  {
    trx_t *trx= check_trx_exists(thd);
    if (trx->id || trx->state != TRX_STATE_NOT_STARTED)
    {
      ut_ad(trx->state != TRX_STATE_BACKUP);
      my_error(ER_CANT_DO_THIS_DURING_AN_TRANSACTION, MYF(0));
      return 1;
    }

    log_sys.latch.wr_lock();
    ut_ad(!this->trx);
    ut_ad(queue.empty());
    if (!logs.empty())
    {
      /* A new BACKUP SERVER is being invoked before a previous one
      had been fully finalized. Clean up any log files. */
      if (old_size)
        delete_logs();
      logs.clear();
    }

    const bool fail{log_sys.backup_start(&old_size, thd)};

    if (!fail)
    {
      this->trx= trx;
      trx->state= TRX_STATE_BACKUP;
      backup_context &ctx{trx->lock.backup};
      ctx.first_lsn= log_sys.get_first_lsn();;
      ctx.max_first_lsn= 1;
      ctx.first_size= log_sys.file_size;
      const lsn_t start= ctx.checkpoint=
#if 1 /* TODO: for incremental backup, allow the start to be specified */
        log_sys.get_latest_checkpoint(ctx.checkpoint_end_lsn);
#else
        log_sys.archived_checkpoint;
      ctx.checkpoint_end_lsn= log_sys.archived_lsn;
#endif
      ctx.last_lsn= 0;
      ctx.archived= !old_size;

      /* Collect all tablespaces that have been created before our
      start checkpoint. Newer tablespaces will be recovered by the
      innodb_log_archive=ON recovery.

      If a tablespace is deleted before step() is invoked, the file
      will not be copied, and a FILE_DELETE record in the log will
      ensure correct recovery.

      If a tablespace is renamed between this and end(), the recovery
      of a FILE_RENAME record will ensure the correct file name,
      no matter which name was used by step(). */
      mysql_mutex_lock(&fil_system.mutex);
      for (fil_space_t &space : fil_system.space_list)
        if (space.id < SRV_SPACE_ID_UPPER_BOUND &&
            !space.is_being_imported() &&
            /* FIXME: how to initialize create_lsn for old files, to
            have efficient incremental backup?
            fil_node_t::read_page0() cannot assign it from
            FIL_PAGE_LSN because that would not reflect the file
            creation but for example allocating or freeing a page.

            The easy parts of initializing space->create_lsn are
            as follows:
            (1) In log_parse_file() when processing FILE_CREATE
            (2) In deferred_spaces.create() */
            space.get_create_lsn() < start)
          queue.emplace_back(space.id);
      mysql_mutex_unlock(&fil_system.mutex);
    }
    log_sys.latch.wr_unlock();
    DEBUG_SYNC(thd, "innodb_backup_start");
    return fail;
  }

  /**
     Process a file that was collected at init().
     This may be invoked from multiple concurrent threads.
     @param thd     current session
     @param target  backup target
     @return number of files remaining, or negative on error
     @retval 0 on completion
  */
  int step(THD *thd, const backup_target &target) noexcept
  {
    uint32_t id= FIL_NULL;
    lsn_t lsn= 0;
    log_sys.latch.wr_lock();
    backup_context &ctx{context()};
    ut_ad(ctx.max_first_lsn);
    size_t size{queue.size()};
    if (!logs.empty())
    {
      lsn= logs.back();
      if (ctx.max_first_lsn < lsn)
        ctx.max_first_lsn= lsn;
      logs.pop_back();
      if (!size)
        size= logs.size();
    }
    else if (size)
    {
      size--;
      id= queue.back();
      queue.pop_back();
    }
    log_sys.latch.wr_unlock();

    if (lsn)
    {
      if (link_or_move(lsn, nullptr, ctx, target))
        return -1;
    }
    else if (fil_space_t *space= fil_space_t::get(id))
    {
      int res= -1;
      uint32_t start{0};
      for (fil_node_t *node= UT_LIST_GET_FIRST(space->chain); node;
           start+= node->size, node= UT_LIST_GET_NEXT(chain, node))
        if ((res= backup(target, node, start)))
          break;
      space->release();
      if (res)
        return res;
    }

    size= std::min(size_t{std::numeric_limits<int>::max()}, size);
    return int(size);
  }

  /**
     Finish copying or finalize the backup.
     @param thd     current session
     @param target  backup target
     @param phase   backup phase
     @return error code
     @retval 0 on success
  */
  int end(THD *thd, const backup_target &target, backup_phase phase) noexcept
  {
    switch (phase) {
    default:
      return 0;
    case BACKUP_PHASE_FINISH:
      return fini(thd, target);
    case BACKUP_PHASE_NO_COMMIT:
      /* Determine the logical time of the backup snapshot */
    case BACKUP_PHASE_ABORT:
      break;
    }

    int fail= 0;
    log_sys.latch.wr_lock();
    if (phase == BACKUP_PHASE_ABORT)
    {
    skip_log_dup:
      queue.clear();
      if (old_size)
        delete_logs();
      logs.clear();
    }
    else
    {
      ut_ad(trx);
      ut_ad(queue.empty());
      ut_ad(thd_to_trx(thd) == trx);
      if (!trx || trx->state != TRX_STATE_BACKUP)
        goto skip_log_dup;
      backup_context &ctx= trx->lock.backup;
      ut_ad(ctx.max_first_lsn);
      ctx.last_lsn= log_sys.get_flushed_lsn(std::memory_order_relaxed);
      while (!logs.empty())
      {
        lsn_t lsn{logs.back()};
        if (lsn > ctx.last_lsn)
          break;
        if (lsn > ctx.max_first_lsn)
          ctx.max_first_lsn= lsn;
        logs.pop_back();
        log_sys.latch.wr_unlock();
        fail= link_or_move(lsn, nullptr, ctx, target);
        log_sys.latch.wr_lock();
        if (fail)
          goto skip_log_dup;
      }

      {
        lsn_t lsn{log_sys.get_first_lsn()};
        if (lsn > ctx.max_first_lsn && lsn < ctx.last_lsn)
        {
          const lsn_t end_lsn{lsn + log_sys.capacity()};
          ctx.max_first_lsn= lsn;
          log_sys.latch.wr_unlock();
          bool live_hardlink;
          if (UNIV_UNLIKELY(ctx.last_lsn > end_lsn))
          {
            live_hardlink= true;
            fail= link_or_move(lsn, &live_hardlink, ctx, target);
            if (fail)
              goto skip_log_dup;
            /* Wait for checkpoint_complete(). If the previous link_or_move()
            set live_hardlink, the file will be a read-only clone by now. */
            buf_flush_sync_batch(end_lsn, true);
            ut_ad(logs.size() == 1);
            ut_ad(logs.back() == lsn);
            logs.clear();
            lsn= log_sys.get_first_lsn();
            ut_ad(lsn == end_lsn);
            ctx.max_first_lsn= lsn;
            ctx.last_lsn= log_get_lsn();
            ut_ad(ctx.last_lsn >= end_lsn);
          }

          live_hardlink= false;
          fail= link_or_move(lsn, &live_hardlink, ctx, target);
          log_sys.latch.wr_lock();
          if (fail)
            goto skip_log_dup;
          if (!live_hardlink)
          {
            fail= write_config(target, ctx);
            if (fail)
              goto skip_log_dup;
            ctx.max_first_lsn= 0;
          }
        }
        else
          goto skip_log_dup;
      }
    }

    ut_ad(!log_sys.resize_in_progress());
    ut_ad(log_sys.archive);

    /* Note: If we temporarily made a hard link to the last log file
    which is writeable by the server, fini() will copy the file.
    If it is also the first (and only) log file in our backup,
    write_checkpoint() will write a checkpoint header that identifies
    the starting point of recovering the backup. */

    if (old_size)
    {
      log_sys.latch.wr_unlock();
      log_sys.backup_stop_archiving(thd);
      log_sys.latch.wr_lock();
    }

    trx= nullptr;
    log_sys.backup_stop(old_size, thd);
    return fail;
  }

  /**
     Clean up after end().
     @param thd     the parameter that had been passed to end()
     @param target  backup target
     @return error code
     @retval 0 on success
  */
  int fini(THD *thd, const backup_target &target) noexcept
  {
    int fail= 0;
    log_sys.latch.wr_lock();
    if (!trx)
    {
      ut_ad(queue.empty());
      if (old_size)
        delete_logs();
      logs.clear();
    }
    log_sys.latch.wr_unlock();

    trx_t *const trx= thd_to_trx(thd);
    if (!trx || trx->state != TRX_STATE_BACKUP)
      ut_ad("invalid state" == 0);
    else
    {
      ut_ad(!trx->id);
      const backup_context &ctx{trx->lock.backup};
      if (ctx.max_first_lsn)
      {
        /* Copy our clone of the last log until the final LSN */
        ut_ad(target.stream == target.NO_STREAM);
#ifdef _WIN32
        std::string src{target.path};
        src.push_back('/');
        std::string dst{src};
        src.append("ib_logfile101");
        log_sys.append_archive_name(dst, ctx.max_first_lsn);
        const char *s_= src.c_str(), *d_= dst.c_str();
        HANDLE s, d;
        for (;;)
        {
          s= CreateFile(s_, GENERIC_READ,
                        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                        my_win_file_secattr(), OPEN_EXISTING,
                        FILE_ATTRIBUTE_NORMAL, nullptr);
          if (s != INVALID_HANDLE_VALUE)
            break;
          switch (GetLastError()) {
          case ERROR_SHARING_VIOLATION:
          case ERROR_LOCK_VIOLATION:
            std::this_thread::sleep_for(std::chrono::seconds(1));
            continue;
          }
          my_error(ER_FILE_NOT_FOUND, MYF(ME_ERROR_LOG), s_, errno);
          fail= 1;
          goto done;
        }
        d= CreateFile(d_, GENERIC_WRITE, 0, my_win_file_secattr(),
                      CREATE_NEW, FILE_ATTRIBUTE_NORMAL, nullptr);
        if (d == INVALID_HANDLE_VALUE)
        {
        fail:
          fail= 1;
          my_osmaperr(GetLastError());
          CloseHandle(s);
          my_error(ER_ERROR_ON_RENAME, MYF(ME_ERROR_LOG), s_, d_, errno);
        }
        else
        {
          const uint64_t payload_end= log_sys.START_OFFSET +
            ctx.last_lsn - ctx.max_first_lsn;
          /* First, extend the file to a valid size. */
          {
            LARGE_INTEGER li;
            li.QuadPart=
              std::max<uint64_t>(log_sys.FILE_SIZE_MIN,
                                 (payload_end + 4095) & ~4095ULL);
            fail= !SetFilePointerEx(d, li, nullptr, FILE_BEGIN) ||
              !SetEndOfFile(d);
          }
          if (!fail)
            fail= copy_file(&s, &d, log_sys.START_OFFSET, payload_end) ||
              (ctx.max_first_lsn == ctx.first_lsn &&
               write_checkpoint(d, ctx.checkpoint_end_lsn - ctx.first_lsn +
                                log_sys.START_OFFSET));
          if (!CloseHandle(d) || fail)
            goto fail;

          CloseHandle(s);

          if (!DeleteFile(s_))
          {
            my_osmaperr(GetLastError());
            my_error(ER_CANT_DELETE_FILE, MYF(ME_ERROR_LOG), s_, errno);
            fail= 1;
          }
        }
#else
        int s= openat(target.fd, "ib_logfile101", O_RDONLY);
        std::string dst;
        log_sys.append_archive_name(dst, ctx.max_first_lsn);
        int d{-1};
        if (s == -1)
        {
          my_error(ER_FILE_NOT_FOUND, MYF(ME_ERROR_LOG), "ib_logfile101",
                   errno);
          fail= 1;
          goto done;
        }
        d= openat(target.fd, dst.c_str(),
                  O_CREAT | O_EXCL | O_TRUNC | O_WRONLY, 0666);
        if (d < 0)
        {
        fail:
          fail= 1;
          my_error(ER_ERROR_ON_RENAME, MYF(ME_ERROR_LOG),
                   "ib_logfile101", dst.c_str(), errno);
          close(s);
        }
        else
        {
          const uint64_t payload_end= log_sys.START_OFFSET +
            ctx.last_lsn - ctx.max_first_lsn;
          /* First, extend the file to a valid size. */
          fail= ftruncate(d, std::max<off_t>(log_sys.FILE_SIZE_MIN,
                                             (payload_end + 4095) & ~4095LL));
          if (!fail)
            fail= copy_file(s, d, log_sys.START_OFFSET, payload_end) ||
              (ctx.max_first_lsn == ctx.first_lsn &&
               write_checkpoint(d, ctx.checkpoint_end_lsn - ctx.first_lsn +
                                log_sys.START_OFFSET));
          if (close(d) || fail)
            goto fail;
          if (unlinkat(target.fd, "ib_logfile101", 0))
          {
            my_error(ER_CANT_DELETE_FILE, MYF(ME_ERROR_LOG),
                     "ib_logfile101", errno);
            fail= 1;
          }
          std::ignore= close(s);
        }
#endif
      done:
        fail= write_config(target, ctx);
      }
      trx->lock.backup= {};
      trx->state= TRX_STATE_NOT_STARTED;
    }
    return fail;
  }

  /**
     Complete the first checkpoint in a new archive log file.
  */
  void checkpoint_complete() noexcept
  {
    ut_ad(log_sys.latch_have_wr());
    if (trx)
      logs.emplace_back(log_sys.get_first_lsn() - log_sys.capacity());
  }

private:
  /** Safely start backing up a tablespace file
  @param end  last page to copy */
  static void backup_start(fil_space_t *space, uint32_t end) noexcept
  {
    if (space->backup_start(end))
      os_aio_wait_until_no_pending_writes(false);
  }
  /* Stop backing up a tablespace */
  static void backup_stop(fil_space_t *space) noexcept
  { space->backup_stop(); }

  /** Delete unnecessary logs that had been created for backup. */
  void delete_logs() noexcept
  {
    ut_ad(old_size);
    for (const lsn_t lsn : logs)
      IF_WIN(DeleteFile,unlink)(log_sys.get_archive_path(lsn).c_str());
  }

  /**
     Back up a persistent InnoDB data file.
     @param target backup target
     @param node   InnoDB data file
     @param start  first page number
  */
  int backup(const backup_target &target, fil_node_t *node, uint32_t start)
    noexcept
  {
    for (bool tried_mkdir{false};;)
    {
      ut_ad(target.stream == target.NO_STREAM);
#ifdef _WIN32
      std::string path{target.path};
      path.push_back('/');
      path.append(node->name);
      HANDLE f= CreateFile(path.c_str(), GENERIC_WRITE, 0,
                           my_win_file_secattr(), CREATE_NEW,
                           FILE_ATTRIBUTE_NORMAL, nullptr);
      if (f == INVALID_HANDLE_VALUE)
      {
        unsigned long err= GetLastError();
        if (err == ERROR_PATH_NOT_FOUND && !tried_mkdir &&
            node->space->id && !srv_is_undo_tablespace(node->space->id))
        {
          tried_mkdir= true;
          path.erase(path.rfind('/'));
          if (CreateDirectory(path.c_str(),
                              my_dir_security_attributes.lpSecurityDescriptor
                              ? &my_dir_security_attributes : nullptr) ||
              (err= GetLastError()) == ERROR_ALREADY_EXISTS)
            continue;
        }

        my_osmaperr(err);
        goto fail;
      }
#else
      int f;
# ifdef __APPLE__
      backup_start(node->space,
                   (node->space->size + fil_space_t::BACKUP_BATCH_SIZE - 1) &
                   ~fil_space_t::BACKUP_BATCH_SIZE);
      f= fclonefileat(node->handle, target.fd, node->name, 0);
      backup_stop(node->space);
      if (!f)
        break;
      switch (errno) {
      case ENOENT:
        goto try_mkdir;
      case ENOTSUP:
        break;
      default:
        goto fail;
      }
# endif
      f= openat(target.fd, node->name,
                O_CREAT | O_EXCL | O_TRUNC | O_WRONLY, 0666);
      if (f < 0)
      {
        if (errno == ENOENT)
        {
# ifdef __APPLE__
        try_mkdir:
# endif
          if (!tried_mkdir && node->space->id &&
              !srv_is_undo_tablespace(node->space->id))
          {
            tried_mkdir= true;
            const char *sep= strchr(node->name, '/');
            ut_ad(sep);
            sep= strchr(sep + 1, '/');
            ut_ad(sep);
            std::string dir{node->name, size_t(sep - node->name)};
            if (!mkdirat(target.fd, dir.c_str(), 0777) || errno == EEXIST)
              continue;
          }
        }
        goto fail;
      }
#endif
      int err{0};
      for (const uint32_t file_size{node->size},
             page_size{node->space->physical_size()};;)
      {
        const uint32_t end{start + fil_space_t::BACKUP_BATCH_SIZE};
        backup_start(node->space, end);
        /* TODO: avoid copying freed page ranges */
        err= copy_file(IF_WIN(&,)node->handle, IF_WIN(&,)f,
                       start * uint64_t{page_size},
                       std::min(end, file_size) * uint64_t{page_size});
        backup_stop(node->space);
        if (err || (start= end) >= file_size)
          break;
      }

      if (IF_WIN(!CloseHandle(f), close(f)) || err)
        goto fail;
      break;
    }
    return 0;
  fail:
    my_error(ER_CANT_CREATE_FILE, MYF(0), node->name, errno);
    return -1;
  }

  /** Write a checkpoint header pointing to the start of the backup.
  @param dst       target file
  @param c         offset of the FILE_CHECKPOINT mini-transaction
  @return error code
  @retval 0 on success */
  static int write_checkpoint(IF_WIN(HANDLE,int) dst, uint64_t c) noexcept
  {
#ifdef _WIN32
    using tpool::pwrite;
#endif
    uint64_t buf[8]{};
    ut_ad(c >= log_sys.START_OFFSET);
    if (log_sys.is_encrypted())
      log_crypt_write_header(reinterpret_cast<byte*>(buf), true);
    buf[4 * log_sys.is_encrypted()]= my_htobe64(c);

    for (ssize_t o= 0, count= sizeof buf; count;)
    {
      ssize_t ret=
        pwrite(dst, reinterpret_cast<const byte*>(buf) + o, count, o);
      if (ret <= 0 || ret > count)
        return -1;
      o+= ret;
      count-= ret;
    }
    return 0;
  }

  /** Write the configuration parameters for restoring the backup
  @param target  backup target
  @param ctx     backup context
  @return error code (non-positive)
  @retval 0   on success */
  static int write_config(const backup_target &target,
                          const backup_context &ctx) noexcept
  {
    char config[sizeof "[server]\n# checkpoint=" +
                sizeof "innodb_log_recovery_start=" +
                sizeof "innodb_log_recovery_target=\n" + 45 * 3];
    const int size=
      snprintf(config, sizeof config,
               "[server]\n# checkpoint=" LSN_PF "\n"
               "innodb_log_recovery_start=" LSN_PF "\n"
               "innodb_log_recovery_target=" LSN_PF "\n",
               ctx.checkpoint, ctx.checkpoint_end_lsn, ctx.last_lsn);
    return backup_config_append(&target, config, size_t(size));
  }

  /** Hard-link (copy) or rename (move) an archive log file.
  @param lsn       The first LSN in the file
  @param clone     pointer to a flag that will be set if a live log was
                   hard-linked (needing deduplication),
                   or nullptr if the source log file is known to be read-only
  @param ctx       backup context
  @param target    backup target
  @return error code
  @retval 0 on success */
  static int link_or_move(lsn_t lsn, bool *clone,
                          const backup_context &ctx,
                          const backup_target &target) noexcept
  {
    const std::string p{log_sys.get_archive_path(lsn)};
    const char *const path= p.c_str(), *basename= strrchr(path, '/');
    if (!basename)
      basename= path;
    else
      basename++;
    const bool move{!clone && !ctx.archived};
#ifdef _WIN32
    std::string b{target.path};
    b.push_back('/');
    b.append((clone && !*clone) ? "ib_logfile101" : basename);
    const char *destname= b.c_str();

    unsigned long err;
    if (move)
    {
      if (!MoveFileEx(path, destname, MOVEFILE_COPY_ALLOWED))
      {
      fail:
        err= GetLastError();
      got_err:
        my_osmaperr(err);
        my_error(ER_ERROR_ON_RENAME, MYF(ME_ERROR_LOG), path, basename, errno);
        return -1;
      }

      if (lsn < ctx.checkpoint)
      {
        if (!SetFileAttributes(destname, FILE_ATTRIBUTE_NORMAL))
          goto fail;
        HANDLE dh= CreateFile(destname, GENERIC_WRITE,
                              FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr,
                              OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
        if (dh == INVALID_HANDLE_VALUE)
          goto fail;
        if (os_file_set_sparse_win32(dh))
          std::ignore=
            os_file_punch_hole(dh, 0, log_sys.START_OFFSET +
                               ((ctx.checkpoint - lsn) & ~4095ULL));
        int fail= write_checkpoint(dh, ctx.checkpoint_end_lsn - lsn +
                                   log_sys.START_OFFSET);
        CloseHandle(dh);
        if (fail)
          goto fail;
      }
    }
    else if (!CreateHardLink(destname, path, nullptr))
    {
      if ((err= GetLastError()) != ERROR_NOT_SAME_DEVICE)
        goto got_err;
      /* Hard-linking failed. Try copying with the final name. */
      b= target.path;
      b.push_back('/');
      b.append(basename);
      destname= b.c_str();

      if (lsn >= ctx.checkpoint && (lsn < ctx.max_first_lsn || !ctx.last_lsn))
      {
        /* Copy a middle log file entirely. */
        sql_print_information("CopyFileEx %s, %s", path, destname);
        if (!CopyFileEx(path, destname, nullptr, nullptr, nullptr,
                        COPY_FILE_NO_BUFFERING))
          goto fail;
      }
      else
      {
        HANDLE s, d;
        for (;;)
        {
          s= CreateFile(path, GENERIC_READ,
                        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                        my_win_file_secattr(), OPEN_EXISTING,
                        FILE_ATTRIBUTE_NORMAL, nullptr);
          if (s != INVALID_HANDLE_VALUE)
            break;
          switch (GetLastError()) {
          case ERROR_SHARING_VIOLATION:
          case ERROR_LOCK_VIOLATION:
            std::this_thread::sleep_for(std::chrono::seconds(1));
            continue;
          }
          goto fail;
        }
        d= CreateFile(destname, GENERIC_WRITE, 0, my_win_file_secattr(),
                      CREATE_NEW, FILE_ATTRIBUTE_NORMAL, nullptr);
        if (d == INVALID_HANDLE_VALUE)
        {
          CloseHandle(s);
          goto fail;
        }

        uint64_t payload_start{log_sys.START_OFFSET};
        uint64_t payload_end{payload_start + ctx.last_lsn - lsn};

        if (lsn < ctx.checkpoint)
        {
          /* Copy the necessary part of the first log file. */
          ut_ad(lsn == ctx.first_lsn);
          payload_start= ((ctx.checkpoint - lsn) + 4095) & ~4095ULL;
          if (!ctx.last_lsn || ctx.last_lsn >= ctx.first_lsn + ctx.first_size)
            payload_end= ctx.first_size;
        }

        /* First, extend the file to a valid size. */
        {
          LARGE_INTEGER li;
          li.QuadPart=
            std::max<uint64_t>(log_sys.FILE_SIZE_MIN,
                               (payload_end + 4095) & ~4095ULL);
          err= !SetFilePointerEx(d, li, nullptr, FILE_BEGIN) ||
            !SetEndOfFile(d);
        }

        if (!err)
        {
          err= copy_file(&s, &d, payload_start, payload_end);
          if (!err && lsn < ctx.checkpoint)
            err= write_checkpoint(d, ctx.checkpoint_end_lsn - lsn +
                                  log_sys.START_OFFSET);
        }

        if (err | !(CloseHandle(s) & CloseHandle(d)))
          goto fail;
      }
    }
    else if (clone)
      *clone= true;
#else
    if (move
        ? !renameat(AT_FDCWD, path, target.fd, basename)
        : !linkat(AT_FDCWD, path, target.fd,
                  (clone && !*clone) ? "ib_logfile101" : basename,
                  AT_SYMLINK_FOLLOW))
    {
# ifdef __linux__
      if (!move || lsn != ctx.first_lsn);
      else if (off_t garbage= (ctx.checkpoint - lsn) & ~4095ULL)
        /* Best effort to punch a hole to free up some garbage in
        the first file. We do not care about failures. */
        if (!fchmodat(target.fd, basename, 0644, 0))
        {
          int dst= openat(target.fd, basename, O_RDWR);
          if (dst >= 0)
            fallocate(dst, FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
                      log_sys.START_OFFSET, garbage);
          close(dst);
          std::ignore= fchmodat(target.fd, basename, 0444, 0);
        }
# endif
      if (clone)
        *clone= !move;
      return 0;
    }
    else if (errno != EXDEV)
    {
    fail:
      my_error(ER_ERROR_ON_RENAME, MYF(ME_ERROR_LOG), path, basename, errno);
      return -1;
    }
    else
    {
      int src= open(path, O_RDONLY);
      if (src < 0)
        goto fail;
      if (move && unlink(path))
      {
      close_and_fail:
        std::ignore= close(src);
        goto fail;
      }
      int dst= openat(target.fd, basename,
                      O_CREAT | O_EXCL | O_TRUNC | O_WRONLY, 0666);
      if (dst < 0)
        goto close_and_fail;
      int err;
      if (lsn >= ctx.checkpoint && (lsn < ctx.max_first_lsn || !ctx.last_lsn))
        /* Copy a middle log file entirely. */
        err= copy_entire_file(src, dst);
      else
      {
        uint64_t payload_start{log_sys.START_OFFSET};
        uint64_t payload_end{payload_start + ctx.last_lsn - lsn};

        if (lsn < ctx.checkpoint)
        {
          /* Copy the necessary part of the first log file. */
          ut_ad(lsn == ctx.first_lsn);
          payload_start= ((ctx.checkpoint - lsn) + 4095) & ~4095ULL;
          if (!ctx.last_lsn || ctx.last_lsn >= ctx.first_lsn + ctx.first_size)
            payload_end= ctx.first_size;
        }

        /* First, extend the file to a valid size. */
        err= ftruncate(dst, std::max<off_t>(log_sys.FILE_SIZE_MIN,
                                            (payload_end + 4095) & ~4095LL));
        if (!err)
        {
          err= copy_file(src, dst, payload_start, payload_end);
          if (!err && lsn < ctx.checkpoint)
            err= write_checkpoint(dst, ctx.checkpoint_end_lsn - lsn +
                                  log_sys.START_OFFSET);
        }
      }

      if (err | close(dst) | close(src))
        goto fail;
    }
#endif
    return 0;
  }
};

/** The backup context; protected by log_sys.latch */
static InnoDB_backup innodb_backup;
}

bool log_t::backup_start(uint64_t *old_size, THD *thd) noexcept
{
  ut_ad(latch_have_wr());
  ut_ad(!backup);
  backup= true;
  *old_size= 0;
  if (archive)
    return false;
  const uint64_t old_file_size{file_size};
  latch.wr_unlock();
  const bool fail{set_archive(true, thd, true)};
  latch.wr_lock();
  if (!fail)
  {
    *old_size= old_file_size;
    return false;
  }
  ut_ad(backup);
  backup= false;
  const uint64_t new_file_size{file_size};
  latch.wr_unlock();
  if (old_file_size != new_file_size && old_file_size &&
      resize_start(old_file_size, thd) == RESIZE_STARTED)
    resize_finish(thd);
  latch.wr_lock();
  return true;
}

void log_t::backup_stop(uint64_t old_size, THD *thd) noexcept
{
  ut_ad(latch_have_wr());
  /* We will be invoked with old_size=0 after a failed backup_start(),
  or if innodb_log_archive=ON held during a successful backup_start(). */
  ut_ad(!old_size || !resize_in_progress());
  ut_ad(!old_size || backup);
  backup= false;
  const uint64_t new_size{file_size};
  latch.wr_unlock();
  if (old_size && old_size != new_size &&
      resize_start(old_size, thd) == RESIZE_STARTED)
    resize_finish(thd);
}

int innodb_backup_start(THD *thd, const backup_target &target,
                        backup_phase phase) noexcept
{
  return phase == BACKUP_PHASE_START && innodb_backup.init(thd, target);
}

int innodb_backup_step(THD *thd, const backup_target &target,
                       backup_phase phase) noexcept
{
  return phase == BACKUP_PHASE_START && innodb_backup.step(thd, target);
}

int innodb_backup_end(THD *thd, const backup_target &target,
                      backup_phase phase) noexcept
{
  return innodb_backup.end(thd, target, phase);
}

void innodb_backup_checkpoint() noexcept
{
  innodb_backup.checkpoint_complete();
}
