#!/bin/bash
# mariabackup.sh: BACKUP SERVER-compatible mariabackup wrapper.

MODE=""
TARGET_DIR=""
STREAM_FORMAT=""
INCREMENTAL_BASEDIR=""
COMPRESS=""
COMPRESS_THREADS=""
ENCRYPT=""
DATABASES_PATTERN=""
DATABASES_EXCLUDE_PATTERN=""
TABLES_PATTERN=""
TABLES_EXCLUDE_PATTERN=""
TABLES_FILE=""
MARIADB_OPTS=""
INCREMENTAL_DIR=""
APPLY_LOG_ONLY=""
EXPORT=""
ROLLBACK_XA=""
USE_MEMORY=""
FORCE_NON_EMPTY=""
INNODB_OPTS=""
MYSQLD_EXTRA=""
MYSQLD_BIN="mariadbd"
DATADIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --backup)                MODE="backup";     shift ;;
        --prepare|--apply-log)   MODE="prepare";    shift ;;
        --copy-back)             MODE="copy-back";  shift ;;
        --move-back)             MODE="move-back";  shift ;;

        --target-dir=*)              TARGET_DIR="${1#*=}";                shift ;;
        --datadir=*)                 DATADIR="${1#*=}";                   shift ;;
        --stream=*)                  STREAM_FORMAT="${1#*=}";             shift ;;
        --incremental-basedir=*)     INCREMENTAL_BASEDIR="${1#*=}";       shift ;;
        --incremental-dir=*)         INCREMENTAL_DIR="${1#*=}";           shift ;;
        --use-memory=*)              USE_MEMORY="${1#*=}";                shift ;;
        --mysqld=*)                  MYSQLD_BIN="${1#*=}";                shift ;;

        --apply-log-only)              APPLY_LOG_ONLY="yes";  shift ;;
        --export)                      EXPORT="yes";          shift ;;
        --rollback-xa)                 ROLLBACK_XA="yes";     shift ;;
        --force-non-empty-directories) FORCE_NON_EMPTY="yes"; shift ;;

        --innodb-*=*|--innodb-*)                  INNODB_OPTS="$INNODB_OPTS $1";   shift ;;
        --tmpdir=*|--log-innodb-page-corruption)  MYSQLD_EXTRA="$MYSQLD_EXTRA $1"; shift ;;

        --databases=*)               DATABASES_PATTERN="${1#*=}";         shift ;;
        --databases-exclude=*)       DATABASES_EXCLUDE_PATTERN="${1#*=}"; shift ;;
        --tables=*)                  TABLES_PATTERN="${1#*=}";            shift ;;
        --tables-exclude=*)          TABLES_EXCLUDE_PATTERN="${1#*=}";    shift ;;
        --tables-file=*)             TABLES_FILE="${1#*=}";               shift ;;

        --user=*|--password=*|--host=*|--port=*|--socket=*)
            MARIADB_OPTS="$MARIADB_OPTS $1"; shift ;;
        --defaults-file=*|--defaults-extra-file=*)
            MARIADB_OPTS="$MARIADB_OPTS $1"; shift ;;
        -u|-p|-h|-P|-S)
            # Bare `-p` is a password prompt: only consume the next argv if it looks like a value.
            if [[ -n "${2-}" && "$2" != -* ]]; then
                MARIADB_OPTS="$MARIADB_OPTS $1 $2"; shift 2
            else
                MARIADB_OPTS="$MARIADB_OPTS $1"; shift
            fi
            ;;
        -u*|-p*|-h*|-P*|-S*)
            MARIADB_OPTS="$MARIADB_OPTS $1"; shift ;;

        --compress|--compress=*)
            # Compression algorithm value is ignored: output is always gzip/pigz.
            COMPRESS="yes"; shift ;;
        --compress-threads=*) COMPRESS_THREADS="${1#*=}"; shift ;;
        --encrypt=*)          ENCRYPT="${1#*=}";          shift ;;

        --parallel=*|--throttle=*|--no-lock|--safe-slave-backup)
            # Handled server-side by BACKUP SERVER.
            shift ;;

        *) shift ;;
    esac
done

if [[ -z "$TARGET_DIR" ]]; then
    echo "Error: --target-dir required" >&2
    exit 1
fi

# --prepare
if [[ "$MODE" == "prepare" ]]; then
    if [[ ! -d "$TARGET_DIR" ]]; then
        echo "Error: Target directory does not exist: $TARGET_DIR" >&2
        exit 1
    fi
    if [[ ! -f "$TARGET_DIR/backup.cnf" ]]; then
        echo "Error: backup.cnf not found in target directory: $TARGET_DIR" >&2
        exit 1
    fi

    if [[ -n "$INCREMENTAL_DIR" ]]; then
        if [[ ! -d "$INCREMENTAL_DIR" ]]; then
            echo "Error: Incremental directory does not exist: $INCREMENTAL_DIR" >&2
            exit 1
        fi
        if [[ ! -f "$INCREMENTAL_DIR/backup.cnf" ]]; then
            echo "Error: backup.cnf not found in incremental directory: $INCREMENTAL_DIR" >&2
            exit 1
        fi
        INC_TARGET=$(grep "^innodb_log_recovery_target" "$INCREMENTAL_DIR/backup.cnf" | cut -d= -f2 | tr -d ' ')
        if [[ -z "$INC_TARGET" ]]; then
            echo "Error: Could not read innodb_log_recovery_target from $INCREMENTAL_DIR/backup.cnf" >&2
            exit 1
        fi
        echo "Merging incremental: advancing _target to $INC_TARGET" >&2

        cp "$INCREMENTAL_DIR"/ib_logfile* "$TARGET_DIR/" || {
            echo "Error: Failed to copy redo logs from $INCREMENTAL_DIR" >&2
            exit 1
        }

        # _start stays pinned to base's original checkpoint; only _target advances.
        TMP_CNF="$TARGET_DIR/backup.cnf.tmp.$$"
        sed -e "s/^innodb_log_recovery_target=.*/innodb_log_recovery_target=$INC_TARGET/" \
            "$TARGET_DIR/backup.cnf" > "$TMP_CNF" \
            && mv "$TMP_CNF" "$TARGET_DIR/backup.cnf" || {
            echo "Error: Failed to update $TARGET_DIR/backup.cnf" >&2
            rm -f "$TMP_CNF"
            exit 1
        }
    fi

    BOOTSTRAP_OPTS=""
    [[ -n "$APPLY_LOG_ONLY" ]] && BOOTSTRAP_OPTS="$BOOTSTRAP_OPTS --innodb-force-recovery=3"
    [[ -n "$USE_MEMORY"     ]] && BOOTSTRAP_OPTS="$BOOTSTRAP_OPTS --innodb-buffer-pool-size=$USE_MEMORY"
    [[ -n "$INNODB_OPTS"    ]] && BOOTSTRAP_OPTS="$BOOTSTRAP_OPTS$INNODB_OPTS"
    [[ -n "$MYSQLD_EXTRA"   ]] && BOOTSTRAP_OPTS="$BOOTSTRAP_OPTS$MYSQLD_EXTRA"

    if [[ -n "$EXPORT" ]]; then
        echo "Warning: --export is not yet implemented; running plain recovery" >&2
    fi

    # Pass 1: normal recovery.
    echo "Pass 1: $MYSQLD_BIN --bootstrap --defaults-file=$TARGET_DIR/backup.cnf$BOOTSTRAP_OPTS" >&2
    $MYSQLD_BIN --bootstrap --defaults-file="$TARGET_DIR/backup.cnf" $BOOTSTRAP_OPTS < /dev/null
    PREP_STATUS=$?
    if [[ $PREP_STATUS -ne 0 ]]; then
        echo "Error: prepare pass 1 failed (exit $PREP_STATUS)" >&2
        exit $PREP_STATUS
    fi

    # Pass 2: heuristic XA rollback. tc-heuristic-recover conflicts with
    # automatic crash recovery, so it has to run separately after pass 1.
    if [[ -n "$ROLLBACK_XA" ]]; then
        echo "Pass 2: $MYSQLD_BIN --bootstrap --tc-heuristic-recover=ROLLBACK --defaults-file=$TARGET_DIR/backup.cnf" >&2
        $MYSQLD_BIN --bootstrap --tc-heuristic-recover=ROLLBACK \
            --defaults-file="$TARGET_DIR/backup.cnf" < /dev/null
        XA_STATUS=$?
        if [[ $XA_STATUS -ne 0 ]]; then
            echo "Error: prepare pass 2 (XA rollback) failed (exit $XA_STATUS)" >&2
            exit $XA_STATUS
        fi
    fi

    echo "Prepare completed: $TARGET_DIR" >&2
    exit 0
fi

# --copy-back / --move-back
if [[ "$MODE" == "copy-back" || "$MODE" == "move-back" ]]; then
    if [[ ! -d "$TARGET_DIR" ]]; then
        echo "Error: Target directory does not exist: $TARGET_DIR" >&2
        exit 1
    fi
    if [[ ! -f "$TARGET_DIR/backup.cnf" ]]; then
        echo "Error: backup.cnf not found in $TARGET_DIR (not a prepared backup?)" >&2
        exit 1
    fi
    if [[ -z "$DATADIR" ]]; then
        echo "Error: --datadir required for --$MODE" >&2
        exit 1
    fi
    if [[ ! -d "$DATADIR" ]]; then
        echo "Error: Datadir does not exist: $DATADIR" >&2
        exit 1
    fi
    if [[ -z "$FORCE_NON_EMPTY" ]] && [[ -n "$(ls -A "$DATADIR" 2>/dev/null)" ]]; then
        echo "Error: Datadir is not empty: $DATADIR" >&2
        echo "Pass --force-non-empty-directories to override" >&2
        exit 1
    fi

    if [[ "$MODE" == "copy-back" ]]; then
        echo "Copying $TARGET_DIR/ to $DATADIR/" >&2
        cp -r "$TARGET_DIR"/. "$DATADIR"/ || {
            echo "Error: copy-back failed" >&2
            exit 1
        }
    else
        echo "Moving $TARGET_DIR/ to $DATADIR/" >&2
        ( shopt -s dotglob nullglob
          mv "$TARGET_DIR"/* "$DATADIR"/ ) || {
            echo "Error: move-back failed" >&2
            exit 1
        }
    fi

    echo "Restore completed: $DATADIR" >&2
    echo "Post-action required:" >&2
    echo "    chown -R mysql:mysql $DATADIR" >&2
    echo "    systemctl start mariadb" >&2
    exit 0
fi

# --backup

if [[ -e "$TARGET_DIR" ]]; then
    echo "Error: Target directory already exists: $TARGET_DIR" >&2
    echo "Remove it first or choose a different target directory" >&2
    exit 1
fi

PARENT_DIR="$(dirname "$TARGET_DIR")"
if [[ ! -d "$PARENT_DIR" ]]; then
    echo "Error: Parent directory does not exist: $PARENT_DIR" >&2
    exit 1
fi
if [[ ! -w "$PARENT_DIR" ]]; then
    echo "Error: Parent directory is not writable: $PARENT_DIR" >&2
    exit 1
fi

if [[ -n "$COMPRESS" || -n "$ENCRYPT" ]] && [[ -z "$STREAM_FORMAT" ]]; then
    STREAM_FORMAT="mbstream"
fi

if [[ -n "$INCREMENTAL_BASEDIR" ]]; then
    if [[ ! -d "$INCREMENTAL_BASEDIR" ]]; then
        echo "Error: Base backup directory does not exist: $INCREMENTAL_BASEDIR" >&2
        exit 1
    fi
    if [[ ! -f "$INCREMENTAL_BASEDIR/backup.cnf" ]]; then
        echo "Error: backup.cnf not found in base backup directory: $INCREMENTAL_BASEDIR" >&2
        exit 1
    fi
    BASE_LSN=$(grep "^innodb_log_recovery_target" "$INCREMENTAL_BASEDIR/backup.cnf" | cut -d= -f2 | tr -d ' ')
    if [[ -z "$BASE_LSN" ]]; then
        echo "Error: Could not read innodb_log_recovery_target from $INCREMENTAL_BASEDIR/backup.cnf" >&2
        exit 1
    fi
    echo "Base backup LSN: $BASE_LSN" >&2

    # innodb_log_archive_start is startup-only and read-only on the server.
    # Verify the archive floor still covers the base before kicking off the
    # incremental: if older logs have been pruned, the request is impossible.
    SERVER_FLOOR=$(mariadb $MARIADB_OPTS -BN -e "SELECT @@global.innodb_log_archive_start" 2>/dev/null)
    if [[ -z "$SERVER_FLOOR" ]]; then
        echo "Error: Could not read @@global.innodb_log_archive_start from server" >&2
        exit 1
    fi
    if (( SERVER_FLOOR > BASE_LSN )); then
        echo "Error: server's innodb_log_archive_start=$SERVER_FLOOR exceeds base backup's" >&2
        echo "       end LSN=$BASE_LSN. Archive files needed for this incremental have" >&2
        echo "       been pruned. Take a fresh full backup instead." >&2
        exit 1
    fi
    echo "Archive floor OK: server $SERVER_FLOOR <= base $BASE_LSN" >&2
fi

# Build backup_include / backup_exclude with precedence:
#   --databases beats --tables; --databases-exclude beats --tables-exclude.
#   --tables-file is escaped (`.` -> `[.]`) and merged into --tables.
# BACKUP SERVER has a single include / single exclude variable, so --databases
# and --tables cannot both apply: combine them into one --databases regex.

FINAL_INCLUDE=""
FINAL_EXCLUDE=""

if [[ -n "$TABLES_FILE" ]]; then
    if [[ ! -f "$TABLES_FILE" ]]; then
        echo "Error: Tables file not found: $TABLES_FILE" >&2
        exit 1
    fi
    TABLES_FROM_FILE=""
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        # Escape `.` to `[.]` so prod.users does not accidentally match prodxusers.
        table_pattern="${line//./[.]}"
        if [[ -z "$TABLES_FROM_FILE" ]]; then
            TABLES_FROM_FILE="$table_pattern"
        else
            TABLES_FROM_FILE="$TABLES_FROM_FILE,$table_pattern"
        fi
    done < "$TABLES_FILE"
    if [[ -n "$TABLES_PATTERN" ]]; then
        TABLES_PATTERN="$TABLES_PATTERN,$TABLES_FROM_FILE"
    else
        TABLES_PATTERN="$TABLES_FROM_FILE"
    fi
fi

if [[ -n "$DATABASES_PATTERN" ]]; then
    FINAL_INCLUDE="$DATABASES_PATTERN"
    if [[ -n "$TABLES_PATTERN" ]]; then
        echo "Warning: --tables='$TABLES_PATTERN' is ignored because --databases takes precedence" >&2
        echo "  To filter both database and tables, combine them into one --databases pattern." >&2
    fi
elif [[ -n "$TABLES_PATTERN" ]]; then
    FINAL_INCLUDE="$TABLES_PATTERN"
fi

if [[ -n "$DATABASES_EXCLUDE_PATTERN" ]]; then
    FINAL_EXCLUDE="$DATABASES_EXCLUDE_PATTERN"
elif [[ -n "$TABLES_EXCLUDE_PATTERN" ]]; then
    FINAL_EXCLUDE="$TABLES_EXCLUDE_PATTERN"
fi

if [[ -n "$FINAL_INCLUDE" ]]; then
    echo "Setting backup_include='$FINAL_INCLUDE'" >&2
    mariadb $MARIADB_OPTS -e "SET GLOBAL backup_include='$FINAL_INCLUDE'"
fi

if [[ -n "$FINAL_EXCLUDE" ]]; then
    echo "Setting backup_exclude='$FINAL_EXCLUDE'" >&2
    mariadb $MARIADB_OPTS -e "SET GLOBAL backup_exclude='$FINAL_EXCLUDE'"
fi

SQL="BACKUP SERVER TO '$TARGET_DIR'"
echo "Executing: $SQL" >&2
mariadb $MARIADB_OPTS -e "$SQL"

if [[ -n "$STREAM_FORMAT" ]]; then
    case "$STREAM_FORMAT" in
        mbstream)
            echo "Creating tar stream from $TARGET_DIR" >&2
            SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            STREAM_CMD=("$SCRIPT_DIR/mbstream.sh" -c -f - -C "$TARGET_DIR" .)
            if [[ -n "$COMPRESS" && -n "$ENCRYPT" ]]; then
                if [[ -n "$COMPRESS_THREADS" ]]; then
                    echo "Compressing with pigz -p $COMPRESS_THREADS and encrypting with $ENCRYPT" >&2
                    "${STREAM_CMD[@]}" | pigz -p "$COMPRESS_THREADS" | openssl enc -"$ENCRYPT" -salt -pbkdf2
                else
                    echo "Compressing with gzip and encrypting with $ENCRYPT" >&2
                    "${STREAM_CMD[@]}" | gzip | openssl enc -"$ENCRYPT" -salt -pbkdf2
                fi
            elif [[ -n "$COMPRESS" ]]; then
                if [[ -n "$COMPRESS_THREADS" ]]; then
                    echo "Compressing with pigz -p $COMPRESS_THREADS" >&2
                    "${STREAM_CMD[@]}" | pigz -p "$COMPRESS_THREADS"
                else
                    echo "Compressing with gzip" >&2
                    "${STREAM_CMD[@]}" | gzip
                fi
            elif [[ -n "$ENCRYPT" ]]; then
                echo "Encrypting with $ENCRYPT" >&2
                "${STREAM_CMD[@]}" | openssl enc -"$ENCRYPT" -salt -pbkdf2
            else
                "${STREAM_CMD[@]}"
            fi
            ;;
        *)
            echo "Error: Unsupported stream format: $STREAM_FORMAT (only mbstream is supported)" >&2
            exit 1
            ;;
    esac
fi
