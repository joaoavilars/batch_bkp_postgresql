@echo off
::STGRESQL BACKUP CONFIG ::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Optional hostname to adhere to pg_hba policies.  Will default to "localhost" if none specified.
set HOSTNAME=localhost

:: Optional username to connect to database as.  Will default to "postgres" if none specified.
set USERNAME=postuser
set PGPASSWORD=My_post_pass

:: This dir will be created if it doesn't exist.  This must be writable by the user the script is
:: running as.
set BACKUP_DIR=c:\backups

:: List of strings to match against in database name, separated by space or comma, for which we only
:: wish to keep a backup of the schema, not the data. Any database names which contain any of these
:: values will be considered candidates. (e.g. "system_log" will match "dev_system_log_2010-01")
set SCHEMA_ONLY_LIST="xxx"

:: Will produce a custom-format backup if set to "yes"
set ENABLE_CUSTOM_BACKUPS="no"

:: Will produce a gzipped plain-format backup if set to "yes"
set ENABLE_PLAIN_BACKUPS="no"
set DATABASE=database_name
set PLAIN_BACKUPS_YES=p

:: Will produce gzipped sql file containing the cluster globals, like users and passwords, if set to "yes"
set ENABLE_GLOBALS_BACKUPS="no"


:::::::: SETTINGS FOR ROTATED BACKUPS ::::::::

:: Which day to take the weekly backup from (1-7 = Monday-Sunday)
set DAY_OF_WEEK_TO_KEEP=5

:: Number of days to keep daily backups
set DAYS_TO_KEEP=7

:: How many weeks to keep weekly backups
set WEEKS_TO_KEEP=5

SET other_pg_dump_flags=--blobs -c

SET file_format=c
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

