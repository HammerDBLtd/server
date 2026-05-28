# ==== Purpose ====
#
# Redirect `$XTRABACKUP` so existing test invocations like
#
#     --exec $XTRABACKUP --defaults-file=$MYSQLTEST_VARDIR/my.cnf \
#         --backup --target-dir=$targetdir
#
# run through scripts/mariabackup/mariabackup.sh — the BACKUP SERVER
# compatibility wrapper — without any change to the test body.
#
#
# Skip the test if any of these are missing:
#   - the wrapper script
#   - bash
#   - the mariadb client (wrapper shells out to it)
#
# ==== Usage ====
#
#   --source include/have_mariabackup_wrapper.inc
#   # ... rest of the test, using $XTRABACKUP as usual ...
#
# ==== Exposed variables ====
#
#   $XTRABACKUP        — now points at mariabackup.sh

--source include/linux.inc

--let MARIABACKUP_WRAPPER=$MYSQL_TEST_DIR/../scripts/mariabackup/mariabackup.sh

--error 0,1
perl;
use strict;
use warnings;
use File::Basename;

my $wrapper = $ENV{MARIABACKUP_WRAPPER};
exit 1 unless $wrapper && -x $wrapper;

chomp(my $bash = `command -v bash 2>/dev/null`);
exit 1 unless $bash && -x $bash;

# Prepend its directory to PATH so the bare `mariadb` invocation
# inside the wrapper resolves.
my ($mariadb) = split /\s+/, ($ENV{MYSQL} // '');
exit 1 unless $mariadb && -x $mariadb;
$ENV{PATH} = dirname($mariadb) . ":$ENV{PATH}";

exit 0;
EOF

if ($errno)
{
  --skip mariabackup.sh wrapper unavailable (script, bash, or mariadb client missing)
}

--let XTRABACKUP=$MARIABACKUP_WRAPPER
