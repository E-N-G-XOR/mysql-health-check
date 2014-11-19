#!/bin/bash

TODAY=$1
MYSQL_HOST=$2
MYSQL_USER=$3
MYSQL_PASS=$4

### SETUP
#PT_QUERY_DIGEST_BIN=

if [ -z "$TODAY" ]; then
TODAY=`date +%F`
fi

SLOW_LOG=`mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -BNe "SELECT @@GLOBAL.slow_query_log_file"`
if [ -z "$SLOW_LOG" ]; then
    echo "can't get query log file from @@GLOBAL.slow_query_log_file, please verify MySQL credentials"
    exit 3
fi
if [ ! -r $SLOW_LOG ]; then
    echo "can't read slow query log file: $SLOW_LOG"
    exit 5
fi

DIGEST_DIR=`dirname $SLOW_LOG`/digests
if [ ! -d $DIGEST_DIR ]; then
    mkdir -p $DIGEST_DIR
fi
if [ ! -d $DIGEST_DIR ]; then
    echo "Can't create digest directory: $DIGEST_DIR"
fi

DIGEST=$DIGEST_DIR/$TODAY.digest
LOG_DAILY=$DIGEST_DIR/$TODAY.log

### prepare
cat $SLOW_LOG >> $LOG_DAILY

### clear logs
## FIXME unaccurate rotation
echo "" > $SLOW_LOG
./bin/pt-query-digest --limit 5 $LOG_DAILY > $DIGEST

### send digest
echo -e "\n\n==== MySQL QUERY digest ===="
cat $DIGEST
