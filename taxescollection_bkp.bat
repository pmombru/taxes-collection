  @echo off
   for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
     set dow=%%i
     set month=%%j
     set day=%%k
     set year=%%l
   )
   for /f "tokens=1-3 delims=: " %%i in ("%time%") do (
     set hour=%%i
     set mins=%%j
     set secs=%%k
   )
   set datestr=%year%%month%%day%%hour%%mins%
   echo datestr is %datestr%
    
   set BACKUP_FILE=C:\Trabajo\Toptal\taxescollection_%datestr%.backup
   echo backup file name is %BACKUP_FILE%
   echo on
   "C:\Program Files\PostgreSQL\11\bin\pg_dump" -h localhost -p 5432 -U postgres -F c -b -v -w -f %BACKUP_FILE% TaxesCollection