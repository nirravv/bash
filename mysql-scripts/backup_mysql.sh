#!/bin/bash

# Define variables
BACKUP_DIR="$HOME/db_backups"        # Backup directory
DATE=$(date +%Y%m%d_%H%M%S)          # Date format with hour, minute, and second
RETENTION_COUNT=15                   # Number of backups to retain

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if mode is provided
if [ -z "$1" ]; then
    echo "Usage: $0 {all|specific} [database_name]"
    exit 1
fi

MODE=$1

# Prompt for MySQL password if .my.cnf is not configured
if ! grep -q "password=" ~/.my.cnf; then
    read -sp "Enter MySQL password: " MYSQL_PASSWORD
    echo
    MYSQL_CREDENTIALS="-p$MYSQL_PASSWORD"
else
    MYSQL_CREDENTIALS=""
fi

if [ "$MODE" == "all" ]; then
    # Backup all databases
    FILE_NAME="all_databases_$DATE.sql"  # Backup file name with underscore

    # Backup all databases without compression
    mysqldump --all-databases $MYSQL_CREDENTIALS > "$BACKUP_DIR/$FILE_NAME"

    echo "Backup of all databases completed: $BACKUP_DIR/$FILE_NAME"

    # Retention policy: keep only the last 15 backups for all databases
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/all_databases_*.sql | wc -l)

    if [ $BACKUP_COUNT -gt $RETENTION_COUNT ]; then
        echo "Applying retention policy: keeping the last $RETENTION_COUNT backups for all databases."
        ls -1t "$BACKUP_DIR"/all_databases_*.sql | tail -n +$(($RETENTION_COUNT + 1)) | xargs rm --
        echo "Old backups for all databases removed."
    fi

elif [ "$MODE" == "specific" ]; then
    # Check if database name is provided
    if [ -z "$2" ]; then
        echo "Usage: $0 specific database_name"
        exit 1
    fi
    DATABASE=$2
    FILE_NAME="${DATABASE}_$DATE.sql"  # Backup file name with underscore

    # Backup the specific database without compression
    mysqldump $MYSQL_CREDENTIALS $DATABASE > "$BACKUP_DIR/$FILE_NAME"

    echo "Backup of database '$DATABASE' completed: $BACKUP_DIR/$FILE_NAME"

    # Retention policy: keep only the last 15 backups for this specific database
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/"${DATABASE}"_*.sql | wc -l)

    if [ $BACKUP_COUNT -gt $RETENTION_COUNT ]; then
        echo "Applying retention policy: keeping the last $RETENTION_COUNT backups for database '$DATABASE'."
        ls -1t "$BACKUP_DIR"/"${DATABASE}"_*.sql | tail -n +$(($RETENTION_COUNT + 1)) | xargs rm --
        echo "Old backups for database '$DATABASE' removed."
    fi

else
    echo "Invalid mode. Use 'all' for all databases or 'specific' for a specific database."
    exit 1
fi
