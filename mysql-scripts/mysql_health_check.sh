#!/bin/bash

# MySQL credentials
MYSQL_USER="your_mysql_user"
MYSQL_PASSWORD="your_mysql_password"
MYSQL_HOST="localhost"

# Email settings
EMAIL_TO="your_email@example.com"
EMAIL_SUBJECT="MySQL Health Check Report - $(date +'%Y-%m-%d %H:%M:%S')"
EMAIL_BODY="/tmp/mysql_health_check_report.txt"

# Check MySQL connection
echo "Checking MySQL connection..." > $EMAIL_BODY
if ! mysqladmin ping -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; then
    echo "ERROR: MySQL is not responding!" >> $EMAIL_BODY
    mail -s "$EMAIL_SUBJECT" "$EMAIL_TO" < $EMAIL_BODY
    exit 1
fi
echo "MySQL connection: OK" >> $EMAIL_BODY

# Check slow queries
SLOW_QUERIES=$(mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW GLOBAL STATUS LIKE 'Slow_queries';" | grep "Slow_queries" | awk '{print $2}')
echo "Number of slow queries: $SLOW_QUERIES" >> $EMAIL_BODY

# Check disk space
DISK_USAGE=$(df -h | grep '/$' | awk '{print $5}')
echo "Disk usage on root partition: $DISK_USAGE" >> $EMAIL_BODY
if [ "${DISK_USAGE%?}" -ge 90 ]; then
    echo "WARNING: Disk usage is above 90%!" >> $EMAIL_BODY
fi

# Check replication status (if applicable)
REPLICATION_STATUS=$(mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW SLAVE STATUS\G" | grep "Seconds_Behind_Master")
if [ -z "$REPLICATION_STATUS" ]; then
    echo "Replication is not configured or not running." >> $EMAIL_BODY
else
    echo "Replication status: $REPLICATION_STATUS" >> $EMAIL_BODY
fi

# Send email report
mail -s "$EMAIL_SUBJECT" "$EMAIL_TO" < $EMAIL_BODY

# Clean up
rm $EMAIL_BODY
