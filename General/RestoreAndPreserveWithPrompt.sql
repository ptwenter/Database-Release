/***THIS SCRIPT SHOULD ONLY BE RUN IF YOU ARE OVERWRITING AN EXISTING DATABASE THAT IS ALREADY PROPERLY CONFIGURED***/
/***THIS SCRIPT MAY REQUIRE MODIFICATIONS TO MEET YOUR NEEDS***/
/***OPEN THE SCRIPT IN SQL SERVER MANAGEMENT STUDIO, PRESS CTRL+SHIFT+M, FILL OUT THE VARIABLES, THEN RUN THE SCRIPT***/
/***ALTERNATIVELY, YOU CAN PERFORM A FIND-AND-REPLACE ON THE FOLLOWING 3 ITEMS AND SPECIFY THE APPROPRIATE VALUES: 
"[<DatabaseName, string, Lucity>]", "<DatabaseBackupPath, string, D:\SQLServer\BACKUP\Lucity.bak>", AND "<DatabaseDATAFolder, string, D:\SQLServer\DATA>" ***/

USE master
GO

--Killing all connections and setting the database to SINGLE_USER mode as something still seems to connect if only one or the other is done
declare @kill varchar(MAX);
set @kill = '';
select @kill=@kill+'kill '+ convert(varchar(5),spid) +';' from master..sysprocesses where dbid IN (SELECT DBID FROM master..sysdatabases where name = '<DatabaseName, string, Lucity>');
exec (@kill);
GO

ALTER DATABASE <DatabaseName, string, Lucity> SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

--Copy System Settings so we can restore them after the database is restored
SELECT * INTO #SYSTEMSETTINGS FROM [<DatabaseName, string, Lucity>].dbo.SYSTEMSETTINGS
SELECT * INTO #CONNECTSTRINGS FROM [<DatabaseName, string, Lucity>].dbo.CONNECTSTRINGS
SELECT * INTO #CLIENTLICENSES FROM [<DatabaseName, string, Lucity>].dbo.CLIENTLICENSES
SELECT * INTO #GISCONN FROM [<DatabaseName, string, Lucity>].dbo.GISCONN
SELECT * INTO #GISMAPSERV FROM [<DatabaseName, string, Lucity>].dbo.GISMAPSERV
SELECT * INTO #LUCITYUSERS FROM [<DatabaseName, string, Lucity>].dbo.sysusers
GO

--Restore the database from backup and set database names as needed
RESTORE DATABASE <DatabaseName, string, Lucity> FROM DISK =  '<DatabaseBackupPath, string, D:\SQLServer\BACKUP\Lucity.bak>' WITH REPLACE, MOVE 'Lucity' TO '<DatabaseDATAFolder, string, D:\SQLServer\DATA>\<DatabaseName, string, Lucity>.mdf', MOVE 'LucityLog' TO '<DatabaseDATAFolder, string, D:\SQLServer\DATA>\<DatabaseName, string, Lucity>.ldf' 
GO

--Restore Settings
--In the event that the database being ovewritten was not the same version of Lucity, we can't simply clear the tables as they may have new fields and/or records
UPDATE T1 SET T1.CONN_SERVER = T2.CONN_SERVER, T1.CONN_DB = T2.CONN_DB, T1.CONN_USERID = T2.CONN_USERID, T1.CONN_PASSWORD = T2.CONN_PASSWORD, T1.CONN_DISABLED = T2.CONN_DISABLED, T1.CONN_COMPT = T2.CONN_COMPT, T1.CONN_PARMS = T2.CONN_PARMS FROM [<DatabaseName, string, Lucity>].dbo.CONNECTSTRINGS T1 INNER JOIN #CONNECTSTRINGS T2 ON T1.CONN_PROGRAM = T2.CONN_PROGRAM
UPDATE T1 SET T1.SYSSET_VALUE = T2.SYSSET_VALUE FROM [<DatabaseName, string, Lucity>].dbo.SYSTEMSETTINGS T1 INNER JOIN #SYSTEMSETTINGS T2 ON T1.SYSSET_ID = T2.SYSSET_ID
UPDATE T1 SET T1.GCONN_DB = T2.GCONN_DB, T1.GCONN_SERVER = T2.GCONN_SERVER, T1.GCONN_INSTANCE = T2.GCONN_INSTANCE, T1.GCONN_UID = T2.GCONN_UID, T1.GCONN_PW = T2.GCONN_PW, T1.GCONN_AUTH = T2.GCONN_AUTH, T1.GCONN_WSTYPE = T2.GCONN_WSTYPE, T1.GCONN_VERSION = T2.GCONN_VERSION, T1.GCONN_URL = T2.GCONN_URL, T1.GCONN_UPDATE = T2.GCONN_UPDATE, T1.GCONN_REPLICA = T2.GCONN_REPLICA, T1.GCONN_SERVUN = T2.GCONN_SERVUN, T1.GCONN_SERVPW = T2.GCONN_SERVPW, T1.GCONN_GSER_ID = T2.GCONN_GSER_ID FROM [<DatabaseName, string, Lucity>].dbo.GISCONN T1 INNER JOIN #GISCONN T2 ON T1.GCONN_NAME = T2.GCONN_NAME
--INSERT INTO [<DatabaseName, string, Lucity>].dbo.GISCONN SELECT GCONN_NAME, GCONN_DB, GCONN_SERVER, GCONN_INSTANCE, GCONN_UID, GCONN_PW, GCONN_AUTH, GCONN_WSTYPE, GCONN_VERSION, GCONN_MOD_BY, GCONN_MOD_DT, GCONN_MOD_TM, GCONN_ROWVER, GCONN_URL, GCONN_UPDATE, GCONN_REPLICA, GCONN_SERVUN, GCONN_SERVPW, GCONN_GSER_ID FROM #GISCONN WHERE GCONN_NAME NOT IN (SELECT GCONN_NAME FROM [<DatabaseName, string, Lucity>].dbo.GISCONN)
UPDATE T1 SET T1.GSER_URL = T2.GSER_URL FROM [<DatabaseName, string, Lucity>].dbo.GISMAPSERV T1 INNER JOIN #GISMAPSERV T2 ON T1.GSER_ID = T2.GSER_ID
UPDATE T1 SET T1.LIC_CODE = T2.LIC_CODE, T1.LIC_APPNAME = T2.LIC_APPNAME, T1.ELA_EXPIREDATE = T2.ELA_EXPIREDATE, T1.ELA_KEY = T2.ELA_KEY FROM [<DatabaseName, string, Lucity>].dbo.CLIENTLICENSES T1 INNER JOIN #CLIENTLICENSES T2 ON T1.LIC_KEYNAME = T2.LIC_KEYNAME


--Create missing users and schema
DECLARE @SQL VARCHAR(MAX),
		@USERNAME VARCHAR(MAX),
		@LOGINNAME VARCHAR(MAX)
DECLARE MHCURSOR	CURSOR FOR SELECT lu.NAME FROM #LUCITYUSERS lu LEFT JOIN [<DatabaseName, string, Lucity>].dbo.sysusers u ON u.name = lu.name WHERE lu.islogin = 1  AND u.name IS NULL
OPEN MHCURSOR
FETCH NEXT FROM MHCURSOR INTO @USERNAME
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQL = 'USE [<DatabaseName, string, Lucity>]' + CHAR(13) + CHAR(10) + 'EXEC (''CREATE USER [' + @USERNAME + '] WITH DEFAULT_SCHEMA= [' + @USERNAME + ']'')'
	EXEC (@SQL)
	SET @SQL = 'USE [<DatabaseName, string, Lucity>]' + CHAR(13) + CHAR(10) + 'EXEC (''CREATE SCHEMA [' + @USERNAME + '] AUTHORIZATION [' + @USERNAME + ']'')'
	EXEC (@SQL)
	FETCH NEXT FROM MHCURSOR INTO @USERNAME
END
CLOSE MHCURSOR
DEALLOCATE MHCURSOR

--Re-Associate user to logins
DECLARE MHCURSOR	CURSOR FOR SELECT u.NAME, l.NAME FROM [<DatabaseName, string, Lucity>].dbo.sysusers u INNER JOIN #LUCITYUSERS lu ON u.name = lu.name INNER JOIN [master].dbo.syslogins l on lu.sid = l.sid WHERE u.islogin = 1  AND u.name <> 'dbo'
OPEN MHCURSOR
FETCH NEXT FROM MHCURSOR INTO @USERNAME, @LOGINNAME
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC [<DatabaseName, string, Lucity>]..sp_change_users_login 'Update_One', @USERNAME, @LOGINNAME
	FETCH NEXT FROM MHCURSOR INTO @USERNAME, @LOGINNAME
END
CLOSE MHCURSOR
DEALLOCATE MHCURSOR

--Associate user to logins where the names match and the user is not already associated to a login
DECLARE MHCURSOR	CURSOR FOR SELECT u.NAME FROM [<DatabaseName, string, Lucity>].dbo.sysusers u INNER JOIN [master].dbo.syslogins l on u.name = l.name WHERE islogin = 1 AND u.sid NOT IN (SELECT sid FROM [master].dbo.syslogins)
OPEN MHCURSOR
FETCH NEXT FROM MHCURSOR INTO @USERNAME
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC [<DatabaseName, string, Lucity>]..sp_change_users_login 'Update_One', @USERNAME, @USERNAME
	FETCH NEXT FROM MHCURSOR INTO @USERNAME
END
CLOSE MHCURSOR
DEALLOCATE MHCURSOR