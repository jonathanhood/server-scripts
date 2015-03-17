#!/bin/bash

# Parse CLI arguments
if [ "$#" -eq 0 ]; then
    echo "Usage: backup_owncloud cleanup"
    echo "Usage: backup_owncloud backup <mysql-user> <mysql-pass>"
    exit
fi

ACTION=$1

# General Settings
BACKUPS_TO_KEEP=5

# Backup location settings
BACKUP_ROOT=/mnt/raid/backups/owncloud
BACKUP_DATA=$BACKUP_ROOT/data
BACKUP_MYSQL=$BACKUP_ROOT/mysql
BACKUP_CONFIG=$BACKUP_ROOT/config

# Source location settings
OWNCLOUD_DATA=/mnt/raid/owncloud/
OWNCLOUD_CONFIG=/var/www/owncloud/config/

# Make folders if they don't exist
mkdir -p $BACKUP_DATA
mkdir -p $BACKUP_MYSQL
mkdir -p $BACKUP_CONFIG

# Perform a backup
if [ "$ACTION" == "backup" ]; then
    if [ "$#" -ne 3 ]; then
        echo "Usage: backup_owncloud backup <mysql-user> <mysql-pass>"
    fi

    MYSQL_USER=$2
    MYSQL_PASS=$3

    # Backup data with rsync
    rsync -Aax $OWNCLOUD_DATA $BACKUP_DATA/owncloud-data_`date +"%Y%m%d"`/

    # Backup config with rsync
    rsync -Aax $OWNCLOUD_CONFIG $BACKUP_CONFIG/owncloud-config_`date +"%Y%m%d"`/

    # Backup mysql by doing a dump
    mysqldump --lock-tables -h localhost -u $MYSQL_USER -p$MYSQL_PASS owncloud > $BACKUP_MYSQL/owncloud-mysql_`date +"%Y%m%d"`.bak
fi

# Cleanup old backups
if [ "$ACTION" == "cleanup" ]; then
    cleanup_old_backups() {
        DIRECTORY=$1
        BACKUP_COUNT=`ls $DIRECTORY | wc -l`

        if [ "$BACKUP_COUNT" -gt "$BACKUPS_TO_KEEP" ]; then
            NUM_BACKUPS_TO_REMOVE=`expr $BACKUP_COUNT - $BACKUPS_TO_KEEP`
            ls $DIRECTORY | tail -n $NUM_BACKUPS_TO_REMOVE | xargs rm -rf
        fi
    }

    cleanup_old_backups $BACKUP_DATA
    cleanup_old_backups $BACKUP_CONFIG
    cleanup_old_backups $BACKUP_MYSQL
fi

