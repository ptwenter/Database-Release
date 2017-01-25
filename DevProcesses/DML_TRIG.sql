USE DATABASETRACKER
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TRACK_DML]') AND type in (N'U'))
CREATE TABLE TRACK_DML (DatabaseName varchar(100), TableName varchar(100), PostTime datetime, SystemUser varchar(100), HostName varchar(100), Event varchar(100), ID VARCHAR(100), ColumnsChanged varchar(1000), DataChanged varchar(1000));
GO


DECLARE @DATABASE VARCHAR(50),
	@SQL VARCHAR(MAX),
	@PREFIX VARCHAR(2)
DECLARE MHCURSOR	CURSOR FOR SELECT 'LucityDEV', 'CM'
								UNION SELECT 'LucityDEV', 'EL' 
								UNION SELECT 'LucityDEV', 'EF' 
								UNION SELECT 'LucityDEV', 'PK' 
								UNION SELECT 'LucityDEV', 'SW' 
								UNION SELECT 'LucityDEV', 'SM' 
								UNION SELECT 'LucityDEV', 'ST' 
								UNION SELECT 'LucityDEV', 'US' 
								UNION SELECT 'LucityDEV', 'WT' 
								UNION SELECT 'LucityDEV', 'WK' 
OPEN MHCURSOR
FETCH NEXT FROM MHCURSOR INTO @DATABASE, @PREFIX
WHILE @@FETCH_STATUS = 0
BEGIN

/*******************************************************************************************
START OF TRIGGER BLOCK - COPY FROM HERE TO END OF TRIGGER BLOCK IF YOU ARE CREATING A
NEW TRIGGER AND THEN PASTE AND EDIT THE CODE IMMEDIATELY AFTER THE END OF TRIGGER BLOCK
********************************************************************************************/
IF @PREFIX <> 'US'
BEGIN
SET @SQL = 'USE ' + @DATABASE + '
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = ''DATABASE'' AND name = N''LUCITY_PREVENT_DDL'')
DISABLE TRIGGER [LUCITY_PREVENT_DDL] ON DATABASE
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[dbo].[TRIGINTERNAL_TRACK_' + @PREFIX + 'FIELDS]''))
DROP TRIGGER [dbo].[TRIGINTERNAL_TRACK_' + @PREFIX + 'FIELDS]

DECLARE @SQL VARCHAR(MAX)

SET @SQL = 

''CREATE TRIGGER TRIGINTERNAL_TRACK_' + @PREFIX + 'FIELDS 
ON ' + @PREFIX + 'FIELDS
FOR INSERT, UPDATE, DELETE 
AS

DECLARE @EVENT VARCHAR(100),
	@COLUMNSCHANGED VARCHAR(1000),
	@DATACHANGED VARCHAR(1000),
	@COLUMN VARCHAR(50),
	@COLUMNID INT,
	@ID INT,
	@INSERT BIT,
	@UPDATE BIT,
	@DELETE BIT

IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED) AND (UPDATE(ID))
SELECT @INSERT = 1, @UPDATE = 0, @DELETE = 1
ELSE IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
SELECT @INSERT = 0, @UPDATE = 1, @DELETE = 0
ELSE IF EXISTS (SELECT * FROM INSERTED)
SELECT @INSERT = 1, @UPDATE = 0, @DELETE = 0
ELSE IF EXISTS (SELECT * FROM DELETED)
SELECT @INSERT = 0, @UPDATE = 0, @DELETE = 1

SELECT @COLUMNSCHANGED = '''''''', @DATACHANGED = ''''''''

IF @UPDATE = 1
BEGIN

	DECLARE ColumnCursor CURSOR FOR SELECT COLUMN_NAME, COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA + ''''.'''' + TABLE_NAME),
		COLUMN_NAME, ''''ColumnID'''') AS COLUMN_ID FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''''' + @PREFIX + 'FIELDS'''' AND
		COLUMN_NAME NOT IN (''''USERNAME'''',''''DEFAULTVALUE'''',''''ALLOWINPUT'''',''''REQUIRED'''',''''RESTRICTEDITS'''',
		''''MINRANGE'''',''''MAXRANGE'''',''''CALCULATION'''',''''SPELLCHECK'''',''''VALIDTE'''')

	OPEN ColumnCursor

	FETCH NEXT FROM ColumnCursor INTO @COLUMN, @COLUMNID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--IF UPDATE(@COLUMN)
		IF SUBSTRING(COLUMNS_UPDATED(),1 + FLOOR((@COLUMNID - 1)/8) ,1) & POWER(2,((@COLUMNID - (FLOOR((@COLUMNID - 1)/8) * 8))-1)) > 0
		BEGIN				
			IF LEN(@COLUMNSCHANGED) > 0
				SELECT @COLUMNSCHANGED = @COLUMNSCHANGED + '''','''', @DATACHANGED = @DATACHANGED + '''' + '''''''','''''''' + ''''
			SELECT @COLUMNSCHANGED = @COLUMNSCHANGED + @COLUMN, @DATACHANGED = @DATACHANGED + ''''CAST('''' + @COLUMN + '''' AS VARCHAR(1000))''''
		END

		FETCH NEXT FROM ColumnCursor INTO @COLUMN, @COLUMNID
	END
	CLOSE ColumnCursor
	DEALLOCATE ColumnCursor	

	IF @COLUMNSCHANGED <> ''''''''
	BEGIN

		DECLARE UpdatedCursor CURSOR FOR SELECT ID FROM INSERTED

		OPEN UpdatedCursor

		FETCH NEXT FROM UpdatedCursor INTO @ID

		WHILE @@FETCH_STATUS = 0
		BEGIN

			EXEC (''''
			INSERT DATABASETRACKER.dbo.TRACK_DML 
	   			(DatabaseName, TableName, PostTime, SystemUser, HostName, Event, ID, ColumnsChanged, DataChanged)  
   			SELECT
   				''''''''' + @DATABASE + ''''''''', ''''''''' + @PREFIX + 'FIELDS'''''''', GETDATE(), SYSTEM_USER, HOST_NAME(), ''''''''UPDATE'''''''', '''''''''''' + @ID + '''''''''''', '''''''''''' + @COLUMNSCHANGED + '''''''''''', '''' + @DATACHANGED + '''' FROM ' + @PREFIX + 'FIELDS WHERE ID = '''' + @ID)
		
			FETCH NEXT FROM UpdatedCursor INTO @ID
		END
		CLOSE UpdatedCursor
		DEALLOCATE UpdatedCursor
	END

END

IF @DELETE = 1
BEGIN
	INSERT DATABASETRACKER.dbo.TRACK_DML 
   		(DatabaseName, TableName, PostTime, SystemUser, HostName, Event, ID, DataChanged)  
	SELECT
		''''' + @DATABASE + ''''', ''''' + @PREFIX + 'FIELDS'''', GETDATE(), SYSTEM_USER, HOST_NAME(), ''''DELETE'''', ID, TABLENAME + FIELDNAME FROM DELETED
END

IF @INSERT = 1
BEGIN
	INSERT DATABASETRACKER.dbo.TRACK_DML 
   		(DatabaseName, TableName, PostTime, SystemUser, HostName, Event, ID, DataChanged)  
   	SELECT
		''''' + @DATABASE + ''''', ''''' + @PREFIX + 'FIELDS'''', GETDATE(), SYSTEM_USER, HOST_NAME(), ''''INSERT'''', ID, TABLENAME + FIELDNAME FROM INSERTED
END''

EXEC (@SQL)
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = ''DATABASE'' AND name = N''LUCITY_PREVENT_DDL'')
ENABLE TRIGGER [LUCITY_PREVENT_DDL] ON DATABASE
GO'

EXEC (@SQL)
END

/*******************************************************************************************
END OF TRIGGER BLOCK
********************************************************************************************/

/*******************************************************************************************
START OF TRIGGER BLOCK - COPY FROM HERE TO END OF TRIGGER BLOCK IF YOU ARE CREATING A
NEW TRIGGER AND THEN PASTE AND EDIT THE CODE IMMEDIATELY AFTER THE END OF TRIGGER BLOCK
********************************************************************************************/
IF @PREFIX <> 'US'
BEGIN
SET @SQL = 'USE ' + @DATABASE + '
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = ''DATABASE'' AND name = N''LUCITY_PREVENT_DDL'')
DISABLE TRIGGER [LUCITY_PREVENT_DDL] ON DATABASE
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[dbo].[TRIGINTERNAL_TRACK_' + @PREFIX + 'FIELDSDESC]''))
DROP TRIGGER [dbo].[TRIGINTERNAL_TRACK_' + @PREFIX + 'FIELDSDESC]

DECLARE @SQL VARCHAR(MAX)

SET @SQL = 

''CREATE TRIGGER TRIGINTERNAL_TRACK_' + @PREFIX + 'FIELDSDESC 
ON ' + @PREFIX + 'FIELDSDESC
FOR INSERT, UPDATE, DELETE 
AS

DECLARE @EVENT VARCHAR(100),
	@COLUMNSCHANGED VARCHAR(1000),
	@DATACHANGED VARCHAR(1000),
	@COLUMN VARCHAR(50),
	@COLUMNID INT,
	@ID INT,
	@CODE INT, 
	@TRACKINGID VARCHAR(100),
	@INSERT BIT,
	@UPDATE BIT,
	@DELETE BIT

IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED) AND (UPDATE(ID) OR UPDATE(CODE))
SELECT @INSERT = 1, @UPDATE = 0, @DELETE = 1
ELSE IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
SELECT @INSERT = 0, @UPDATE = 1, @DELETE = 0
ELSE IF EXISTS (SELECT * FROM INSERTED)
SELECT @INSERT = 1, @UPDATE = 0, @DELETE = 0
ELSE IF EXISTS (SELECT * FROM DELETED)
SELECT @INSERT = 0, @UPDATE = 0, @DELETE = 1

SELECT @COLUMNSCHANGED = '''''''', @DATACHANGED = ''''''''

IF @UPDATE = 1
BEGIN

	DECLARE ColumnCursor CURSOR FOR SELECT COLUMN_NAME, COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA + ''''.'''' + TABLE_NAME),
		COLUMN_NAME, ''''ColumnID'''') AS COLUMN_ID FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''''' + @PREFIX + 'FIELDSDESC''''

	OPEN ColumnCursor

	FETCH NEXT FROM ColumnCursor INTO @COLUMN, @COLUMNID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--IF UPDATE(@COLUMN)
		IF SUBSTRING(COLUMNS_UPDATED(),1 + FLOOR((@COLUMNID - 1)/8) ,1) & POWER(2,((@COLUMNID - (FLOOR((@COLUMNID - 1)/8) * 8))-1)) > 0
		BEGIN				
			IF LEN(@COLUMNSCHANGED) > 0
				SELECT @COLUMNSCHANGED = @COLUMNSCHANGED + '''','''', @DATACHANGED = @DATACHANGED + '''' + '''''''','''''''' + ''''
			SELECT @COLUMNSCHANGED = @COLUMNSCHANGED + @COLUMN, @DATACHANGED = @DATACHANGED + ''''CAST('''' + @COLUMN + '''' AS VARCHAR(1000))''''
		END
	
		FETCH NEXT FROM ColumnCursor INTO @COLUMN, @COLUMNID
	END
	CLOSE ColumnCursor
	DEALLOCATE ColumnCursor	

	IF @COLUMNSCHANGED <> ''''''''
	BEGIN

		DECLARE UpdatedCursor CURSOR FOR SELECT ID, CODE, CAST(ID AS VARCHAR) + '''','''' + CAST(CODE AS VARCHAR) FROM INSERTED

		OPEN UpdatedCursor

		FETCH NEXT FROM UpdatedCursor INTO @ID, @CODE, @TRACKINGID

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (''''
			INSERT DATABASETRACKER.dbo.TRACK_DML 
		   		(DatabaseName, TableName, PostTime, SystemUser, HostName, Event, ID, ColumnsChanged, DataChanged)  
	   		SELECT
   				''''''''' + @DATABASE + ''''''''', ''''''''' + @PREFIX + 'FIELDSDESC'''''''', GETDATE(), SYSTEM_USER, HOST_NAME(), ''''''''UPDATE'''''''', '''''''''''' + @TRACKINGID + '''''''''''', '''''''''''' + @COLUMNSCHANGED + '''''''''''', '''' + @DATACHANGED + '''' FROM ' + @PREFIX + 'FIELDSDESC WHERE ID = '''' + @ID + '''' AND CODE = '''' + @CODE)
		
			FETCH NEXT FROM UpdatedCursor INTO @ID, @CODE, @TRACKINGID
		END
		CLOSE UpdatedCursor
		DEALLOCATE UpdatedCursor
	END

END

IF @DELETE = 1
BEGIN
	INSERT DATABASETRACKER.dbo.TRACK_DML 
   		(DatabaseName, TableName, PostTime, SystemUser, HostName, Event, ID, DataChanged)  
	SELECT
		''''' + @DATABASE + ''''', ''''' + @PREFIX + 'FIELDSDESC'''', GETDATE(), SYSTEM_USER, HOST_NAME(), ''''DELETE'''', CAST(ID AS VARCHAR) + '''','''' + CAST(CODE AS VARCHAR), DESCRIPTION FROM DELETED
END

IF @INSERT = 1
BEGIN
	INSERT DATABASETRACKER.dbo.TRACK_DML 
   		(DatabaseName, TableName, PostTime, SystemUser, HostName, Event, ID, DataChanged)  
   	SELECT
		''''' + @DATABASE + ''''', ''''' + @PREFIX + 'FIELDSDESC'''', GETDATE(), SYSTEM_USER, HOST_NAME(), ''''INSERT'''', CAST(ID AS VARCHAR) + '''','''' + CAST(CODE AS VARCHAR), DESCRIPTION FROM INSERTED
END''

EXEC (@SQL)
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = ''DATABASE'' AND name = N''LUCITY_PREVENT_DDL'')
ENABLE TRIGGER [LUCITY_PREVENT_DDL] ON DATABASE
GO'

EXEC (@SQL)
END

/*******************************************************************************************
END OF TRIGGER BLOCK
********************************************************************************************/

/*******************************************************************************************
START OF TRIGGER BLOCK - COPY FROM HERE TO END OF TRIGGER BLOCK IF YOU ARE CREATING A
NEW TRIGGER AND THEN PASTE AND EDIT THE CODE IMMEDIATELY AFTER THE END OF TRIGGER BLOCK
********************************************************************************************/
IF @PREFIX <> 'US'
BEGIN
SET @SQL = 'USE ' + @DATABASE + '
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = ''DATABASE'' AND name = N''LUCITY_PREVENT_DDL'')
DISABLE TRIGGER [LUCITY_PREVENT_DDL] ON DATABASE
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[dbo].[TRIGINTERNAL_TRACK_' + @PREFIX + 'FIELDSDESCTXT]''))
DROP TRIGGER [dbo].[TRIGINTERNAL_TRACK_' + @PREFIX + 'FIELDSDESCTXT]

DECLARE @SQL VARCHAR(MAX)

SET @SQL = 

''CREATE TRIGGER TRIGINTERNAL_TRACK_' + @PREFIX + 'FIELDSDESCTXT 
ON ' + @PREFIX + 'FIELDSDESCTXT
FOR INSERT, UPDATE, DELETE 
AS

DECLARE @EVENT VARCHAR(100),
	@COLUMNSCHANGED VARCHAR(1000),
	@DATACHANGED VARCHAR(1000),
	@COLUMN VARCHAR(50),
	@COLUMNID INT,
	@ID INT,
	@CODE VARCHAR(25), 
	@TRACKINGID VARCHAR(100),
	@INSERT BIT,
	@UPDATE BIT,
	@DELETE BIT

IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED) AND (UPDATE(ID) OR UPDATE(CODE))
SELECT @INSERT = 1, @UPDATE = 0, @DELETE = 1
ELSE IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
SELECT @INSERT = 0, @UPDATE = 1, @DELETE = 0
ELSE IF EXISTS (SELECT * FROM INSERTED)
SELECT @INSERT = 1, @UPDATE = 0, @DELETE = 0
ELSE IF EXISTS (SELECT * FROM DELETED)
SELECT @INSERT = 0, @UPDATE = 0, @DELETE = 1

SELECT @COLUMNSCHANGED = '''''''', @DATACHANGED = ''''''''

IF @UPDATE = 1
BEGIN

	DECLARE ColumnCursor CURSOR FOR SELECT COLUMN_NAME, COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA + ''''.'''' + TABLE_NAME),
		COLUMN_NAME, ''''ColumnID'''') AS COLUMN_ID FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''''' + @PREFIX + 'FIELDSDESCTXT''''

	OPEN ColumnCursor

	FETCH NEXT FROM ColumnCursor INTO @COLUMN, @COLUMNID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--IF UPDATE(@COLUMN)
		IF SUBSTRING(COLUMNS_UPDATED(),1 + FLOOR((@COLUMNID - 1)/8) ,1) & POWER(2,((@COLUMNID - (FLOOR((@COLUMNID - 1)/8) * 8))-1)) > 0
		BEGIN				
			IF LEN(@COLUMNSCHANGED) > 0
				SELECT @COLUMNSCHANGED = @COLUMNSCHANGED + '''','''', @DATACHANGED = @DATACHANGED + '''' + '''''''','''''''' + ''''
			SELECT @COLUMNSCHANGED = @COLUMNSCHANGED + @COLUMN, @DATACHANGED = @DATACHANGED + ''''CAST('''' + @COLUMN + '''' AS VARCHAR(1000))''''
		END
	
		FETCH NEXT FROM ColumnCursor INTO @COLUMN, @COLUMNID
	END
	CLOSE ColumnCursor
	DEALLOCATE ColumnCursor	

	IF @COLUMNSCHANGED <> ''''''''
	BEGIN

		DECLARE UpdatedCursor CURSOR FOR SELECT ID, CODE, CAST(ID AS VARCHAR) + '''','''' + CODE FROM INSERTED

		OPEN UpdatedCursor

		FETCH NEXT FROM UpdatedCursor INTO @ID, @CODE, @TRACKINGID

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (''''
			INSERT DATABASETRACKER.dbo.TRACK_DML 
		   		(DatabaseName, TableName, PostTime, SystemUser, HostName, Event, ID, ColumnsChanged, DataChanged)  
   			SELECT
   				''''''''' + @DATABASE + ''''''''', ''''''''' + @PREFIX + 'FIELDSDESCTXT'''''''', GETDATE(), SYSTEM_USER, HOST_NAME(), ''''''''UPDATE'''''''', '''''''''''' + @TRACKINGID + '''''''''''', '''''''''''' + @COLUMNSCHANGED + '''''''''''', '''' + @DATACHANGED + '''' FROM ' + @PREFIX + 'FIELDSDESCTXT WHERE ID = '''' + @ID + '''' AND CODE = '''''''''''' + @CODE + '''''''''''''''')
		
			FETCH NEXT FROM UpdatedCursor INTO @ID, @CODE, @TRACKINGID
		END
		CLOSE UpdatedCursor
		DEALLOCATE UpdatedCursor
	END

END

IF @DELETE = 1
BEGIN
	INSERT DATABASETRACKER.dbo.TRACK_DML 
   		(DatabaseName, TableName, PostTime, SystemUser, HostName, Event, ID, DataChanged)  
	SELECT
		''''' + @DATABASE + ''''', ''''' + @PREFIX + 'FIELDSDESCTXT'''', GETDATE(), SYSTEM_USER, HOST_NAME(), ''''DELETE'''', CAST(ID AS VARCHAR) + '''','''' + CODE, DESCRIPTION FROM DELETED
END

IF @INSERT = 1
BEGIN
	INSERT DATABASETRACKER.dbo.TRACK_DML 
   		(DatabaseName, TableName, PostTime, SystemUser, HostName, Event, ID, DataChanged)  
   	SELECT
		''''' + @DATABASE + ''''', ''''' + @PREFIX + 'FIELDSDESCTXT'''', GETDATE(), SYSTEM_USER, HOST_NAME(), ''''INSERT'''', CAST(ID AS VARCHAR) + '''','''' + CODE, DESCRIPTION FROM INSERTED
END''

EXEC (@SQL)
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = ''DATABASE'' AND name = N''LUCITY_PREVENT_DDL'')
ENABLE TRIGGER [LUCITY_PREVENT_DDL] ON DATABASE
GO'

EXEC (@SQL)
END

/*******************************************************************************************
END OF TRIGGER BLOCK
********************************************************************************************/

FETCH NEXT FROM MHCURSOR INTO @DATABASE, @PREFIX
END
CLOSE MHCURSOR
DEALLOCATE MHCURSOR