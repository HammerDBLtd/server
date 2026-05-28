# MariaDB Backup Wrapper

A drop-in `mariabackup`-compatible shell wrapper that translates the
familiar CLI into MariaDB's server-side `BACKUP SERVER` SQL command.
Lets DBAs migrate to BACKUP SERVER without changing existing scripts.

## Overview

`mariabackup.sh` masks the traditional `mariabackup` binary. With
`--backup`, it parses MariaBackup options, sets `backup_include` and
`backup_exclude` via the `mariadb` client, then issues
`BACKUP SERVER TO '<dir>'`. Optional streaming, compression, and
encryption are shell pipelines layered on the resulting directory.
All actual backup work happens server-side.

**Prerequisites:** MariaDB with BACKUP SERVER support, `mariadb`
client in `PATH`, an account with `BACKUP SERVER` + `SET GLOBAL`
privileges, `innodb_log_archive=ON` for incrementals, and the
server's `innodb_log_archive_start` (startup-only) set no higher
than the base backup's end LSN.

---

## --backup

### Description

Creates a backup using `BACKUP SERVER`. Produces a backup directory
with data files, redo logs, and `backup.cnf` carrying LSN metadata.

### Structure

```
mariabackup.sh --backup --target-dir=DIRECTORY [OPTIONS]
``'

### Options

| Option                       | Description                                                              |
| ---------------------------- | ------------------------------------------------------------------------ |
| `--target-dir=DIR`           | **(required)** Backup destination                                        |
| `--incremental-basedir=DIR`  | Incremental backup based on a prior full backup                          |
| `--stream=mbstream`          | Stream the backup to stdout as a tar archive                             |
| `--databases=REGEX`          | Include pattern (comma-separated list supported)                         |
| `--databases-exclude=REGEX`  | Exclude pattern (comma-separated list supported)                         |
| `--tables=REGEX`             | Table-level include (used only if `--databases` not set)                 |
| `--tables-exclude=REGEX`     | Table-level exclude (used only if `--databases-exclude` not set)         |
| `--tables-file=FILE`         | File of `database.table` entries, one per line, merged into `--tables`   |
| `--compress`                 | Pipe stream through `gzip` (or `pigz` if `--compress-threads` is set)    |
| `--compress-threads=N`       | Use `pigz -p N` instead of `gzip`                                        |
| `--encrypt=ALG`              | Pipe stream through `openssl enc -ALG -salt -pbkdf2`                     |

**Connection options** (forwarded to the `mariadb` client):
`--user`/`-u`, `--password`/`-p`, `--host`/`-h`, `--port`/`-P`,
`--socket`/`-S`, `--defaults-file`, `--defaults-extra-file`.

**Silently ignored** (BACKUP SERVER handles server-side):
`--parallel`, `--throttle`, `--no-lock`, `--safe-slave-backup`.


**Precedence:**

- `--databases` wins over `--tables`; `--databases-exclude` wins over
  `--tables-exclude` (the loser is ignored with a warning).
- `--tables-exclude` wins over `--tables`.
- `--tables-file` is merged into `--tables`.

### BACKUP SERVER Mapping

```sql
SET GLOBAL backup_include='<pattern>';      -- only if include built
SET GLOBAL backup_exclude='<pattern>';      -- only if exclude built
BACKUP SERVER TO '/path/to/backup';
```

The patterns land in `backup.cnf` inside the target directory along
with `innodb_log_recovery_start` / `innodb_log_recovery_target`.

---

### --target-dir

#### Description

Backup destination directory. Required. Must not already exist; parent
must exist and be writable.

#### BACKUP SERVER Mapping

```sql
BACKUP SERVER TO '/path/to/backup';
```
---

### --incremental-basedir

#### Description

Creates an incremental backup containing only redo logs since the base
backup. The wrapper reads `innodb_log_recovery_target` from the base
`backup.cnf` and verifies it is **≥** the server's
`@@innodb_log_archive_start`: i.e., the archive still covers from
the base's end LSN forward. If the archive has been pruned past that
point, the incremental is impossible and the wrapper fails fast.

Requires `innodb_log_archive=ON` on the server. The archive floor
(`innodb_log_archive_start`) is a startup-only, read-only variable
configured by the DBA; the wrapper never tries to mutate it.

#### BACKUP SERVER Mapping

```bash
BASE_LSN=$(grep ^innodb_log_recovery_target /base/backup.cnf | cut -d= -f2)
FLOOR=$(mariadb -BN -e "SELECT @@global.innodb_log_archive_start")
[ "$FLOOR" -le "$BASE_LSN" ] || exit 1   # archive pruned past base
mariadb -e "BACKUP SERVER TO '/incremental/path'"
```
---

### --stream

#### Description

Streams the backup directory to stdout as a tar archive. Only
`mbstream` is supported (mapped to `tar`). The included `mbstream.sh`
wrapper drops mbstream-specific flags (`-p`/`--parallel`) so legacy
pipelines keep working.

#### BACKUP SERVER Mapping

```bash
mariadb -e "BACKUP SERVER TO '/tmp/backup'"
tar -c -f - -C /tmp/backup .
```
---

### --compress

#### Description

Pipes the stream through `gzip` (or `pigz` if `--compress-threads` is
set). Implies `--stream=mbstream`. The compression algorithm argument
(e.g. `--compress=quicklz`) is accepted for CLI compatibility but
ignored; output is always gzip-compatible.

#### BACKUP SERVER Mapping

```bash
mariadb -e "BACKUP SERVER TO '/tmp/backup'"
tar -c -f - -C /tmp/backup . | gzip
```

---

### --compress-threads

#### Description

Switches compression from `gzip` to `pigz -p N`. Implies `--compress`.

#### BACKUP SERVER Mapping

```bash
tar -c -f - -C /tmp/backup . | pigz -p N
```

---

### --encrypt

#### Description

Pipes the stream through `openssl enc -ALG -salt -pbkdf2`. Implies
`--stream=mbstream`. Combines with `--compress`: compression runs
before encryption.

#### BACKUP SERVER Mapping

```bash
tar -c -f - -C /tmp/backup . \
    | gzip \                                    # if --compress
    | openssl enc -aes-256-cbc -salt -pbkdf2
```
---


## --prepare

### Description

Prepares a BACKUP SERVER backup directory for restore by running
`mariadbd --bootstrap` against its `backup.cnf`, so InnoDB applies the
archived redo log to the data files and exits. For incrementals,
copies the increment's redo logs into the base directory and advances
the LSN bounds in `backup.cnf` before bootstrap.

### Structure

```
mariabackup.sh --prepare --target-dir=DIRECTORY [OPTIONS]
```

### Options

| Option                          | Description                                                              |
| ------------------------------- | ------------------------------------------------------------------------ |
| `--target-dir=DIR`              | **(required)** Backup directory to prepare                               |
| `--incremental-dir=DIR`         | Merge an incremental backup into `--target-dir` before recovery          |
| `--apply-log`                   | Synonym for `--prepare`                                                  |
| `--apply-log-only`              | Apply redo only; skip rollback (use between incrementals in a chain)     |
| `--export`                      | Produce per-table `.cfg` files for `IMPORT TABLESPACE`                   |
| `--rollback-xa`                 | Roll back prepared XA transactions during recovery                       |
| `--use-memory=N`                | InnoDB buffer pool size during recovery (default 96 MiB)                 |
| `--parallel=N`                  | Threads for redo apply                                                   |
| `--force-non-empty-directories` | Allow `--target-dir` to contain unrelated files                          |

**Forwarded to the bootstrap `mariadbd`:** all `--innodb-*` tunables,
`--tmpdir`/`-t`, `--datadir`/`-h`, `--defaults-file`,
`--defaults-extra-file`, `--defaults-group`,
`--log-innodb-page-corruption`, `--mysqld`.

### BACKUP SERVER Mapping

Full prepare:

```bash
mariadbd --bootstrap --defaults-file=<target>/backup.cnf < /dev/null
```

Incremental prepare:

```bash
cp <inc>/ib_logfile* <target>/
# atomic backup.cnf rewrite (write temp + mv):
#   innodb_log_recovery_start  unchanged (still base's original checkpoint)
#   innodb_log_recovery_target ← <inc> _target
mariadbd --bootstrap --defaults-file=<target>/backup.cnf < /dev/null
```

`--apply-log-only` adds `--innodb-force-recovery=3`.
`--export` pipes `FLUSH TABLES ... FOR EXPORT` statements to bootstrap stdin.

---

### --target-dir

#### Description

Backup directory to prepare. Required. Must already exist and contain
a `backup.cnf` produced by `BACKUP SERVER`.

#### BACKUP SERVER Mapping

```bash
mariadbd --bootstrap --defaults-file=<target>/backup.cnf < /dev/null
```

---

### --incremental-dir

#### Description

Applies an incremental backup on top of `--target-dir`. The wrapper
copies the incremental's `ib_logfile*` into the base and atomically
rewrites `backup.cnf` to advance `innodb_log_recovery_target` to the
incremental's `_target`. `innodb_log_recovery_start` stays pinned to
base's original checkpoint, so recovery always replays from there.

Order-dependent: apply incrementals in the order they were taken.

#### BACKUP SERVER Mapping

```bash
cp /backup/inc1/ib_logfile* /backup/base/
# rewrite /backup/base/backup.cnf:
#   innodb_log_recovery_start  unchanged (base's original checkpoint)
#   innodb_log_recovery_target=<inc1 _target>
mariadbd --bootstrap --defaults-file=/backup/base/backup.cnf < /dev/null
```

---

### --apply-log-only

#### Description

Applies redo but skips rollback of uncommitted transactions. Use only
between incrementals in a chain: the **final** `--prepare` must omit
this option so the rollback phase actually runs. Implemented via
`innodb_force_recovery=3`, which keeps writes enabled (below the
read-only threshold at level 4) and leaves undo logs intact for the
next incremental.

#### BACKUP SERVER Mapping

```bash
mariadbd --bootstrap --innodb-force-recovery=3 \
    --defaults-file=<target>/backup.cnf < /dev/null
```

---

### --export

#### Description

Produces per-table `.cfg` files alongside the data files so individual
tables can be restored on another server via
`ALTER TABLE ... IMPORT TABLESPACE`. The wrapper enumerates the backed-up
tables and feeds `FLUSH TABLES ... FOR EXPORT` to bootstrap stdin after
recovery.

#### BACKUP SERVER Mapping

```bash
mariadbd --bootstrap --defaults-file=<target>/backup.cnf <<EOF
FLUSH TABLES db1.tbl1, db1.tbl2, ... FOR EXPORT;
UNLOCK TABLES;
EOF
```

---

### --use-memory

#### Description

InnoDB buffer pool size during recovery. Larger values speed up redo
apply on big backups; default is 96 MiB.

#### BACKUP SERVER Mapping

```bash
mariadbd --bootstrap --innodb-buffer-pool-size=N \
    --defaults-file=<target>/backup.cnf < /dev/null
```

---

### --rollback-xa

#### Description

Rolls back prepared XA transactions during recovery. Off by default:
prepared XA state survives the prepare unless this option is set.

Implemented as a **two-pass** bootstrap because `tc-heuristic-recover`
and automatic crash recovery are mutually exclusive in the server
(`sql/log.cc:12285`):

1. **Pass 1**: normal recovery. Applies redo, rolls back uncommitted
   non-XA transactions.
2. **Pass 2**: heuristic XA cleanup. Starts again with
   `--tc-heuristic-recover=ROLLBACK`, which force-rolls-back **all**
   prepared XA transactions and exits.

#### BACKUP SERVER Mapping

```bash
# Pass 1: normal recovery
mariadbd --bootstrap --defaults-file=<target>/backup.cnf < /dev/null

# Pass 2: heuristic XA rollback
mariadbd --bootstrap --tc-heuristic-recover=ROLLBACK \
    --defaults-file=<target>/backup.cnf < /dev/null
```

---

### --innodb-\* tunables

#### Description

All `--innodb-*` options accepted by `mariadbd` are forwarded
verbatim. Required when the source server used non-default page size,
log group home dir, or data file path: recovery needs to read the
files back under the same geometry.

#### BACKUP SERVER Mapping

```bash
mariadbd --bootstrap \
    --innodb-page-size=16K \
    --innodb-log-files-in-group=2 \
    --defaults-file=<target>/backup.cnf < /dev/null
```

---


## --copy-back

### Description

Copies a prepared backup into the server's datadir. The source backup
directory is preserved. Run after `--prepare` has applied redo logs
and the backup is consistent. The server must be **stopped** during
the copy.

### Structure

```
mariabackup.sh --copy-back --target-dir=DIRECTORY --datadir=DATADIR [OPTIONS]
```

### Options

| Option                          | Description                                                      |
| ------------------------------- | ---------------------------------------------------------------- |
| `--target-dir=DIR`              | **(required)** Prepared backup directory (source)                |
| `--datadir=DIR`                 | **(required)** Server datadir (destination)                      |
| `--force-non-empty-directories` | Allow `--datadir` to contain pre-existing files                  |
| `--parallel=N`                  | Ignored: `cp -r` is single-threaded                              |

**Forwarded for split-path layouts:** `--innodb-data-home-dir`,
`--innodb-undo-directory`, `--innodb-log-group-home-dir`,
`--defaults-file`, `--defaults-extra-file`, `--defaults-group`.

### BACKUP SERVER Mapping

```bash
cp -r /backup/base/* /var/lib/mysql/
# post-action:
chown -R mysql:mysql /var/lib/mysql/
systemctl start mariadb
```

The wrapper refuses a non-empty `--datadir` unless
`--force-non-empty-directories` is set, and prints the post-action
`chown` and server-start commands to stderr after the copy completes.

---

## --move-back

### Description

Moves a prepared backup into the server's datadir. The source backup
is consumed (its files are renamed onto the datadir). Faster than
`--copy-back` when source and destination share a filesystem: each
file becomes a single `rename(2)` instead of a full copy.

### Structure

```
mariabackup.sh --move-back --target-dir=DIRECTORY --datadir=DATADIR [OPTIONS]
```

### Options

Same as `--copy-back`. `mv` preserves the source file ownership, so
the post-action `chown` is still required before starting the server.

### BACKUP SERVER Mapping

```bash
mv /backup/base/* /var/lib/mysql/
# post-action:
chown -R mysql:mysql /var/lib/mysql/
systemctl start mariadb
```

---


## backup.cnf Format

Auto-generated by `BACKUP SERVER` inside the target directory.

```ini
[mariadbd]
datadir=/backup/partial
innodb_log_recovery_start=12288
innodb_log_recovery_target=15000
backup_include=^prod\..*
backup_exclude=^prod\.temp.*,^prod\.cache.*
```

| Field                         | Description                                                                                |
| ----------------------------- | ------------------------------------------------------------------------------------------ |
| `datadir`                     | Backup directory path                                                                      |
| `innodb_log_recovery_start`   | Latest checkpoint LSN at the start of the base backup. Recovery begins scanning here.      |
|                               |  Pinned: does not advance when incrementals are merged in.                                 |
| `innodb_log_recovery_target`  | End LSN of the backup. Recovery stops here, ignoring any extra archive records on disk.    |
|                               |  Advances with each merged incremental.                                                    |
| `backup_include`              | Include pattern, partial backups only                                                      |
| `backup_exclude`              | Exclude pattern, partial backups only                                                      |

Both `_start` and `_target` are written by `BACKUP SERVER`; `_start`
stays fixed across the prepare chain while `_target` advances as
incrementals are applied. The include/exclude lines are omitted when
no filter was applied.

---

## BACKUP SERVER Variables

| Variable                    | Type           | Access | Description                                                                  |
| --------------------------- | -------------- | ------ | ---------------------------------------------------------------------------- |
| `innodb_log_archive`        | Boolean        | RW     | Enables redo log archiving. Must be `ON` for incremental backups.            |
| `innodb_log_archive_start`  | Integer (LSN)  | Read-only, startup-only | Floor for `innodb_log_recovery_start`: declares where the   |
|                             |                |                         | on-disk redo archive begins. Set by the DBA at server       |
|                             |                |                         | startup (`mariadbd --innodb-log-archive-start=N`) after     |
|                             |                |                         | pruning old archive files; Wrapper only reads it            |
|                             |                |                         | (`SELECT @@global.innodb_log_archive_start`) to verify      |
|                             |                |                         | an incremental is still possible.                           |
| `backup_include`            | String (POSIX ERE) | RW | Comma-separated patterns matched against `db.table` (literal `.`).           |
| `backup_exclude`            | String (POSIX ERE) | RW | Comma-separated patterns matched against `db.table`.                         |

The wrapper sets `backup_include` and `backup_exclude` via
`SET GLOBAL`, then runs `BACKUP SERVER`. `innodb_log_archive_start`
is read-only and configured at server startup. Final include/exclude
patterns are also written into `backup.cnf` for
restore tooling.

---
