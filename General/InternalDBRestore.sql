/* CHANGE THE @DatabaseFilter VARIABLE TO INDICATE THE SET OF DATABASES YOU WOULD LIKE TO RUN THIS SCRIPT ON PLEASE BE CAREFUL THAT YOU DO NOT SPECIFY A STRING THAT WOULD INCLUDE THE DEV DATABASES*/

/* THIS SCRIPT PERFORMS THE FOLLOWING:
	- CREATES THE LUCITY_USER AND LUCITY_GATEWAY LOGIN ACCOUNTS IF THEY DO NOT EXIST.
	- IF THE LUCITY_GATEWAY LOGIN ACCOUNT EXISTS, THEN THE PASSWORD IS RESET TO 'gateway'.
	- DISABLES ALL DATABASE TRIGGERS THAT A CLIENT/USER MAY HAVE CREATED
	- DROPS ALL TABLE TRIGGERS THAT START WITH "TRIGINTERNAL"
	- CREATES THE USER LUCITY_USER IF IT DOES NOT EXIST IN THE DATABASE	
	- ASSOCIATES THE USER LUCITY_USER TO THE LOGIN LUCITY_USER
	- ASSOCIATES THE USER LUCITY_USER TO THE LUCITYREADERWRITER ROLE IF THE ROLE EXISTS
	- CREATES THE USER LUCITY_GATEWAY IF IT DOES NOT EXIST IN THE GBAUSER% DATABASE
	- ASSOCIATES THE USER LUCITY_GATEWAY TO THE LOGIN LUCITY_GATEWAY
	- ASSOCIATES THE USER LUCITY_GATEWAY TO THE LUCITYGATEWAY ROLE IF THE ROLE EXISTS
	- UPDATES THE CONNECSTRINGS TABLE IN THE GBAUSER% DATABASES TO POINT TO THE CURRENT SERVER AND DATABASES WITH SIMILAR NAMES TO THE USER DATABASE
*/

   

USE master
GO

DECLARE	@DatabaseFilter VARCHAR(50)

SET @DatabaseFilter = 'GBA%NIGHTLY'

--Create LUCITY_USER login
IF NOT EXISTS (select * from [master].dbo.syslogins where name = 'LUCITY_USER')
BEGIN
  IF (select serverproperty('productversion')) between '7' and '9'
    EXEC sp_addlogin 'LUCITY_USER', 'LUCITY', 'master'
  ELSE
    EXEC ('CREATE LOGIN LUCITY_USER WITH PASSWORD = ''LUCITY'', DEFAULT_DATABASE = master, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF')
END

--Create LUCITY_GATEWAY Login
IF NOT EXISTS (select * from [master].dbo.syslogins where name = 'LUCITY_GATEWAY')
BEGIN
IF (select serverproperty('productversion')) between '7' and '9'
EXEC sp_addlogin 'LUCITY_GATEWAY', 'gateway', 'master'
ELSE
EXEC ('CREATE LOGIN LUCITY_GATEWAY WITH PASSWORD = ''gateway'', DEFAULT_DATABASE = master, CHECK_EXPIRATION=OFF')
END
ELSE BEGIN
IF (select serverproperty('productversion')) between '7' and '9'
EXEC master.dbo.sp_password @old=NULL, @new='gateway', @loginame=[LUCITY_GATEWAY]
ELSE
EXEC ('ALTER LOGIN [LUCITY_GATEWAY] WITH PASSWORD=''gateway''')
END

DECLARE @DATABASE VARCHAR(50),
		@SQL VARCHAR(2000),
		@VER INT,
		@DropStatement VARCHAR(1000) 
DECLARE MHCURSOR	CURSOR FOR SELECT NAME FROM [master].dbo.sysdatabases WHERE NAME LIKE @DatabaseFilter AND NAME NOT LIKE 'GBAGIS%'
OPEN MHCURSOR
FETCH NEXT FROM MHCURSOR INTO @DATABASE
WHILE @@FETCH_STATUS = 0
BEGIN
		--Disable all Database Triggers
		SET @SQL = 'USE ' + @DATABASE + '
			DECLARE @DropStatement VARCHAR(1000)
			DECLARE DropStatements CURSOR LOCAL FAST_FORWARD FOR SELECT ''DISABLE TRIGGER ['' +  
			NAME COLLATE SQL_Latin1_General_CP1_CI_AS + ''] ON '' + parent_class_desc FROM [' + @DATABASE + '].sys.triggers 
			WHERE TYPE = ''TR'' AND is_ms_shipped = 0 AND parent_class_desc = ''DATABASE''
			OPEN DropStatements 
			FETCH NEXT FROM DropStatements INTO @DropStatement 
			WHILE @@FETCH_STATUS = 0
			BEGIN 
			 EXEC (@DropStatement)
			 FETCH NEXT FROM DropStatements INTO @DropStatement 			 
			END 
			CLOSE DropStatements 
			DEALLOCATE DropStatements'
		EXEC (@SQL)

		--Disable all Table Triggers starting with TRIGINTERNAL
		SET @SQL = 'USE ' + @DATABASE + '
			DECLARE @DropStatement VARCHAR(1000)
			DECLARE DropStatements CURSOR LOCAL FAST_FORWARD FOR SELECT ''DROP TRIGGER ['' +  
			NAME COLLATE SQL_Latin1_General_CP1_CI_AS + '']'' FROM [' + @DATABASE + '].sys.triggers 
			WHERE TYPE = ''TR'' AND is_ms_shipped = 0 AND parent_class_desc = ''OBJECT_OR_COLUMN'' AND NAME LIKE ''TRIGINTERNAL%''
			OPEN DropStatements 
			FETCH NEXT FROM DropStatements INTO @DropStatement 
			WHILE @@FETCH_STATUS = 0
			BEGIN 
			 EXEC (@DropStatement)
			 FETCH NEXT FROM DropStatements INTO @DropStatement 			 
			END 
			CLOSE DropStatements 
			DEALLOCATE DropStatements'
		EXEC (@SQL)
			
		--Re-add LUCITY_USER to the databases
		SET @SQL = 'USE ' + @DATABASE + '
			   IF EXISTS (SELECT * FROM sysusers WHERE NAME = ''LUCITY_USER'')
			   EXEC sp_change_users_login ''Update_One'', ''LUCITY_USER'', ''LUCITY_USER''
			   ELSE BEGIN
			   IF (select serverproperty(''productversion'')) between ''7'' and ''9''
			   EXEC sp_grantdbaccess ''LUCITY_USER'', ''LUCITY_USER''
			   ELSE BEGIN
			   EXEC (''CREATE USER [LUCITY_USER] FOR LOGIN [LUCITY_USER] WITH DEFAULT_SCHEMA=[LUCITY_USER]'')
			   EXEC (''CREATE SCHEMA [LUCITY_USER] AUTHORIZATION [LUCITY_USER]'')
			   END
			   END

			   EXEC sp_addrolemember ''LUCITYREADERWRITER'', ''LUCITY_USER'''
		EXEC (@SQL)

		--Re-add LUCITY_GATEWAY to the GBAUSER databases and update CONNECTSTRINGS table
		IF @DATABASE LIKE 'GBAUSER%' OR @DATABASE LIKE 'LUCITY%'
		BEGIN
			SET @SQL = 'USE ' + @DATABASE + '
			   IF EXISTS (SELECT * FROM sysusers WHERE NAME = ''LUCITY_GATEWAY'')
			   EXEC sp_change_users_login ''Update_One'', ''LUCITY_GATEWAY'', ''LUCITY_GATEWAY''
			   ELSE BEGIN
			   IF (select serverproperty(''productversion'')) between ''7'' and ''9''
			   EXEC sp_grantdbaccess ''LUCITY_GATEWAY'', ''LUCITY_GATEWAY''
			   ELSE BEGIN
			   EXEC (''CREATE USER [LUCITY_GATEWAY] FOR LOGIN [LUCITY_GATEWAY] WITH DEFAULT_SCHEMA=[LUCITY_GATEWAY]'')
			   EXEC (''CREATE SCHEMA [LUCITY_GATEWAY] AUTHORIZATION [LUCITY_GATEWAY]'')
			   END
			   END

			   IF EXISTS (SELECT * FROM dbo.sysusers WHERE name = N''LUCITYGATEWAY'' AND ISSQLROLE = 1)
			   EXEC sp_addrolemember ''LUCITYGATEWAY'', ''LUCITY_GATEWAY'''
			EXEC (@SQL)
			

			SET @SQL = 'USE ' + @DATABASE + '
			   IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N''[dbo].[CONNECTSTRINGS]'') AND OBJECTPROPERTY(id, N''IsTable'') = 1)
			   UPDATE dbo.CONNECTSTRINGS SET CONN_SERVER = CAST(SERVERPROPERTY(''SERVERNAME'') AS VARCHAR), CONN_DB = CASE WHEN DB_NAME() LIKE ''GBA%'' THEN CONN_PROGRAM + SUBSTRING(DB_NAME(),8,100) ELSE DB_NAME() END, CONN_USERID = ''LUCITY_USER'', CONN_PASSWORD = ''LUCITY'' WHERE CONN_SERVER IS NOT NULL'
			EXEC (@SQL)
		END


		--Set the compatibility level equal to the Model database
		SELECT @VER = cmptlevel FROM [master].dbo.sysdatabases WHERE NAME = 'MODEL'
		EXEC [master]..sp_dbcmptlevel @DATABASE, @VER
		
		
	FETCH NEXT FROM MHCURSOR INTO @DATABASE
END
CLOSE MHCURSOR
DEALLOCATE MHCURSOR