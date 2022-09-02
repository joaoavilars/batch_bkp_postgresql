@echo off
setlocal enabledelayedexpansion
echo INICIANDO O SCRIPT
::::::::::::::::::::::::::::
:::::::: LOAD CONFIG ::::::::
::::::::::::::::::::::::::::
 
CALL pg_bkp_config.cmd 
 
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do (
set diaatual=%%c-%%b-%%a
set dia=%%a
set mes=%%b
set ano=%%c)
:::::::::::::::::::::::::::
:::: START THE BACKUPS ::::
::::::::::::::::::::::::::::
:: get day of week number
for /f %%i in ('powershell ^(get-date^).dayOfWeek.value__') do set DAY_OF_WEEK=%%i
if %DAY_OF_WEEK% == %DAY_OF_WEEK_TO_KEEP% (goto WEEK)
::get day of the month
if %dia% == 01 (goto MONTHLY)
:: DAILY BACKUP
:: na linha de comando deve-se colocar pg_backup_rotaded.cmd daily 
set SUFFIX=daily
set FINAL_BACKUP_DIR=%BACKUP_DIR%\%diaatual%-%SUFFIX%
IF NOT EXIST %FINAL_BACKUP_DIR% (mkdir %FINAL_BACKUP_DIR%)
 
::::::::::::::::::::::::
:::: GLOBALS BACKUPS ::::
::::::::::::::::::::::::
IF %ENABLE_GLOBALS_BACKUPS% == "yes" (
pg_dumpall -g -U %USERNAME% -f %FINAL_BACKUP_DIR%\globals.sql %DATABASE%)
 
::::::::::::::::::::::::::::
:::::: FULL BACKUPS ::::::::
::::::::::::::::::::::::::::
if %ENABLE_PLAIN_BACKUPS% == "yes" (
pg_dump --host=%HOSTNAME% -U %USERNAME% --format=%PLAIN_BACKUPS_YES% %other_pg_dump_flags% -f %FINAL_BACKUP_DIR%\%DATABASE%_PLAIN.sql %DATABASE%)

if %ENABLE_CUSTOM_BACKUPS% == "yes" (
pg_dump --host=%HOSTNAME% -U %USERNAME% --format=%file_format% %other_pg_dump_flags% -f %FINAL_BACKUP_DIR%\%DATABASE%.sql %DATABASE%)

 
:: MONTHLY BACKUPS
:MONTHLY
if %dia% == 01 (
FORFILES /P %BACKUP_DIR% /M *-monthly /C "cmd /c IF @isdir == TRUE rd /S /Q @path"
set SUFFIX=monthly
set FINAL_BACKUP_DIR=%BACKUP_DIR%\%diaatual%-!SUFFIX!
IF EXIST !FINAL_BACKUP_DIR!\%DATABASE%.sql (goto EOF)
IF NOT EXIST !FINAL_BACKUP_DIR! (mkdir !FINAL_BACKUP_DIR!)
pg_dump --host=%HOSTNAME% -U %USERNAME% --format=%file_format% %other_pg_dump_flags% -f !FINAL_BACKUP_DIR!\%DATABASE%.sql %DATABASE%
if %DAY_OF_WEEK% == %DAY_OF_WEEK_TO_KEEP% (goto WEEK)
goto EOF)


:WEEK
:: WEEKLY BACKUPS
:: Delete all expired weekly directories
set /a EXPIRED_DAYS=(%WEEKS_TO_KEEP%)+1
if %DAY_OF_WEEK% == %DAY_OF_WEEK_TO_KEEP% (
set SUFFIX=weekly
FORFILES /P %BACKUP_DIR% /D -%EXPIRED_DAYS% /M *-!SUFFIX! /C "cmd /c IF @isdir == TRUE rd /S /Q @path"
set FINAL_BACKUP_DIR=%BACKUP_DIR%\%diaatual%-!SUFFIX!
IF EXIST !FINAL_BACKUP_DIR!\%DATABASE%.sql (goto EOF)
IF NOT EXIST !FINAL_BACKUP_DIR! (mkdir !FINAL_BACKUP_DIR!)
pg_dump --host=%HOSTNAME% -U %USERNAME% --format=%file_format% %other_pg_dump_flags% -f !FINAL_BACKUP_DIR!\%DATABASE%.sql %DATABASE%
if %dia% == 01 (goto MONTHLY)
goto EOF)
 
:: DAILY BACKUPS
 
:: Delete daily backups 7 days old or more
set SUFFIX=daily
FORFILES /P %BACKUP_DIR% /D -%DAYS_TO_KEEP% /M *-%SUFFIX% /C "cmd /c IF @isdir == TRUE rd /S /Q @path"
set FINAL_BACKUP_DIR=%BACKUP_DIR%\%diaatual%-%SUFFIX%
IF NOT EXIST %FINAL_BACKUP_DIR% (mkdir %FINAL_BACKUP_DIR%)
pg_dump --host=%HOSTNAME% -U %USERNAME% --format=%file_format% %other_pg_dump_flags% -f %FINAL_BACKUP_DIR%\%DATABASE%.sql %DATABASE%

:EOF
ECHO SCRIPT FINALIZADO
