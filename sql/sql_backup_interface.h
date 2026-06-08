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

struct backup_target;
#ifdef _WIN32
/* Use CopyFileEx() to copy entire files */
struct native_file_handle;
#elif defined __APPLE__
/* You should invoke fclonefileat(2) manually before attempting
copy_entire_file() or copy_file() */
# include <sys/attr.h>
# include <sys/clonefile.h>
# include <copyfile.h>
/** Copy an entire file.
@param src  source file descriptor
@param dst  target to append src to
@return error code (negative)
@retval 0   on success */
inline int copy_entire_file(int src, int dst)
{
  return fcopyfile(src, dst, NULL, COPYFILE_ALL | COPYFILE_CLONE);
}
#else
# ifdef __cplusplus
extern "C"
# endif
/** Copy an entire file.
@param src  source file descriptor
@param dst  target to append src to
@return error code (non-positive)
@retval 0   on success */
int copy_entire_file(int src, int dst);
#endif

#ifdef __cplusplus
extern "C"
#endif
/** Copy a portion of a file.
@param src   source file descriptor
@param dst   target to append src to
@param start first offset to copy
@param end   last offset to copy (exclusive)
@return error code (non-positive)
@retval 0   on success */
int copy_file(IF_WIN(const native_file_handle&,int) src,
              IF_WIN(const native_file_handle&,int) dst,
              uint64_t start, uint64_t end);

#ifdef __cplusplus
extern "C"
#endif
/** Append to the configuration file.
@param target   backup target
@param config   the configuration file snippet to append
@param size     length of the snippet
@return error code (non-positive)
@retval 0   on success */
int backup_config_append(const backup_target &target,
                         const char *config, size_t size);
