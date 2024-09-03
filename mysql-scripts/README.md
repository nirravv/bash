MySQL Database Backup and Restore Guide
================================================
This repository contains Bash scripts for automating the backup and restoration of MySQL databases. The scripts provide flexible options for backing up either all databases or specific databases, each with independent retention policies to maintain a defined number of backups.

**Prerequisites :**

- Ensure you have MySQL installed on your system.
- You must have the necessary permissions to perform database backups and restores.
- The scripts are designed to run on a Unix-like environment (e.g., Linux, macOS).

Go to your home directory First (Recommended for beginners)

    cd ~

First Download the Required files
    
    git clone https://github.com/nirravv/bash.git

then go to the mysql-scripts 

    cd bash/mysql-scripts

then make all scripts executable.
    
    chmod +x *.sh
    
now you are good for using these scripts.

### 1. Setting Up the .my.cnf File for MySQL Authentication

To avoid being prompted for your MySQL password each time you run the scripts, you can store your MySQL credentials in a configuration file.
Steps to Create the .my.cnf File:

#### Create the .my.cnf File:

Open a terminal and create a file in your home directory named .my.cnf using your preferred text editor, e.g.:

    nano ~/.my.cnf

Add the Following Content to the File:

    [client]
    user=your_mysql_username
    password=your_mysql_password

Replace your_mysql_username and your_mysql_password with your actual MySQL username and password.

#### Set the Correct Permissions:
----
Ensure that the file is only readable by you:

    chmod 600 ~/.my.cnf

This step is crucial to prevent other users from viewing your MySQL credentials.

#### Verify Configuration:

To verify that MySQL can use this configuration, run a simple command:

    mysql -e "SHOW DATABASES;"

If no password prompt appears and you can see the list of databases, the configuration is correct.

### 2. Backup Process

**Script:** backup_mysql.sh

This script creates a backup of your MySQL databases and automatically manages old backups by deleting files older than 14 days.

**Steps:**

Go to right directory where script is located.

    cd ~/bash/mysql-scripts

Run Following Script to Backup All databases :

    ./backup_mysql.sh all

script will create a backup of all MySQL databases in the format all_databases_YearMonthDay_HourMinutesSeconds.sql.

Run Following Script to backup specific database :
    
    ./backup_mysql.sh specific {your_database_name}

For the specific database backup please change {your_database_name} with name of your actual database name. script will create a backup of specific MySQL databases in the format {your_database_name}_{YearMonthDay_HourMinutesSeconds}.sql.

For example my database name is test_db so i will use following script to backup this database :

    ./backup_mysql.sh specific test_db

Output File: test_db_{YearMonthDay_HourMinutesSeconds}.sql

Backup Directory:
The script will automatically create the ~/db_backups directory if it doesn't exist. All backups will be stored in this directory.

Automatic Cleanup:
The script automatically deletes backup files older than last 15 backups from the backup directory whenever you will run it for next backup.

### 3. Restore Process
**Script:** restore_mysql.sh

This script lists available backups and allows you to select and restore a specific backup. You can either restore all databases or choose a specific database to restore.

**Steps:**

Go to right directory where script is located.

    cd ~/bash/mysql-scripts

Run the Script to restore all databases :

    ./restore_mysql.sh all

Run Following Script to restore specific database :

    ./restore_mysql.sh specific {your_database_name}

**Select a Backup:**
The script will list all available backups in the ~/db_backups directory. Enter the number corresponding to the backup you wish to restore.

**Choose Restore Option:**
When you will run the script you could specify an argument to either restore all databases or specific database.
If you choose to restore a specific database, the script will list the databases that are specifically backed up by you, allowing you to restore specific one.

**Confirmation:**
The script will prompt you for confirmation before restoring the database.

**Restoration Complete:**
Once the restore process is complete, a confirmation message will be displayed.


### 4. Important Notes

**Backup Location:** Ensure that the backup files are stored in a secure location with appropriate permissions.

**Restore Precautions:** Restoring a database will overwrite the existing data. Ensure you are restoring the correct backup.

**Automation:** You can set up cron jobs to automate the backup process at regular intervals.

### 5. Setting Up Cron Jobs for Automatic Backups (Optional)

To automate the backup process, you can set up a cron job that runs the backup script at regular intervals.
Steps to Set Up a Cron Job:

Open the Crontab:

    crontab -e

Add the Following Entry:

Following example schedules back up of all databases every day at 2 AM:

    0 2 * * * ~/bash/mysql-scripts/backup_mysql.sh all

Following example schedules back up of test_db database every day at 2 AM:

    0 2 * * * ~/bash/mysql-scripts/backup_mysql.sh specific test_db  # Replace test_db with your actual database name

Save and Exit:
The cron job is now set up to automatically back up your databases daily.

### 6. License
This script is free to use and modify as per your requirements. However, I am not responsible for any damages, data loss, or issues that arise from using or modifying these scripts. Ensure that you thoroughly review and test the scripts in your environment before deploying them in production.

### 7. Support

For any issues or questions, please contact the script maintainer.