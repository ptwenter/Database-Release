@echo off
SET server=localhost
SET /P server="Server [%server%]: "

SET database=Lucity
SET /P database="Database [%database%]: "

SET port=5432
SET /P port="Port [%port%]: "

SET username=postgres
SET /P username="Username [%username%]: "

SET password=Lucity
SET /P password="Password [%password%]: "

SET PGPASSWORD=%password%

cd "C:\Program Files\PostgreSQL\bin"

createuser -h %server% -U %username% -p %port% -L lucitygateway
createuser -h %server% -U %username% -p %port% -L lucityreaderwriter

echo Dropping Existing Database
dropdb -h %server% -U %username% -p %port% --if-exists %database%

echo Creating %databse%
createdb -h %server% -U %username% -p %port% %database%


pause


