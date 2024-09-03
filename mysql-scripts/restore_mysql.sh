#!/bin/bash

# Define variables
BACKUP_DIR="$HOME/db_backups"  # Backup directory

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
    # Restore all databases
    echo "Available backups for all databases:"
    select FILE_NAME in "$BACKUP_DIR"/all_databases_*.sql; do
        if [ -n "$FILE_NAME" ]; then
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done

    # Confirm the selected backup
    echo "You have selected: $FILE_NAME"
    read -p "Are you sure you want to restore this backup? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        echo "Restore canceled."
        exit 1
    fi

    # Restore all databases
    mysql $MYSQL_CREDENTIALS < "$FILE_NAME"

    echo "Restore of all databases completed."

elif [ "$MODE" == "specific" ]; then
    # Check if database name is provided
    if [ -z "$2" ]; then
        echo "Usage: $0 specific database_name"
        exit 1
    fi
    DATABASE=$2

    # List available backups for the specific database
    echo "Available backups for database '$DATABASE':"
    select FILE_NAME in "$BACKUP_DIR"/"$DATABASE"_*.sql; do
        if [ -n "$FILE_NAME" ]; then
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done

    # Confirm the selected backup
    echo "You have selected: $FILE_NAME"
    read -p "Are you sure you want to restore this backup? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        echo "Restore canceled."
        exit 1
    fi

    # Create the database if it doesn't exist
    mysql $MYSQL_CREDENTIALS -e "CREATE DATABASE IF NOT EXISTS $DATABASE"

    # Restore the specific database
    mysql $MYSQL_CREDENTIALS $DATABASE < "$FILE_NAME"

    echo "Restore of database '$DATABASE' completed."

else
    echo "Invalid mode. Use 'all' for all databases or 'specific' for a specific database."
    exit 1
fi
