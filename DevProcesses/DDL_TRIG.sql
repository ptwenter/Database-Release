USE DATABASETRACKER
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TRACK_DDL]') AND type in (N'U'))
CREATE TABLE TRACK_DDL (XMLEvent xml, DatabaseName varchar(100), ObjectName varchar(100), ObjectType varchar(100), TargetObjectName varchar(100), PostTime datetime, HostName varchar(100), Event nvarchar(100));
GO


DECLARE @DATABASE VARCHAR(50),
	@SQL VARCHAR(MAX)
DECLARE MHCURSOR	CURSOR FOR SELECT NAME FROM [master].dbo.sysdatabases WHERE NAME LIKE 'LUCITYDEV'
OPEN MHCURSOR
FETCH NEXT FROM MHCURSOR INTO @DATABASE
WHILE @@FETCH_STATUS = 0
BEGIN

SET @SQL = 'USE ' + @DATABASE + '

IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = ''DATABASE'' AND name = N''TRACK_DDL'')DROP TRIGGER [TRACK_DDL] ON DATABASE

DECLARE @SQL VARCHAR(MAX)

SET @SQL = 

''CREATE TRIGGER TRACK_DDL 
ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS 
AS
DECLARE @data XML
SET @data = EVENTDATA()

SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON

IF @data.value(''''(/EVENT_INSTANCE/EventType)[1]'''', ''''nvarchar(100)'''') <> ''''CREATE_STATISTICS''''
	AND HOST_NAME() <> ''''GBAMS-DEV-01'''' AND NOT (@data.value(''''(/EVENT_INSTANCE/ObjectName)[1]'''', ''''nvarchar(100)'''') LIKE ''''%GEN'''' AND @data.value(''''(/EVENT_INSTANCE/ObjectType)[1]'''', ''''nvarchar(100)'''') = ''''PROCEDURE'''')
INSERT DATABASETRACKER.dbo.TRACK_DDL 
   (XMLEvent, DatabaseName, ObjectName, ObjectType, TargetObjectName, PostTime, HostName, Event)  
   VALUES 
   (@data,
   @data.value(''''(/EVENT_INSTANCE/DatabaseName)[1]'''', ''''varchar(100)''''),
   @data.value(''''(/EVENT_INSTANCE/ObjectName)[1]'''', ''''varchar(100)''''),
   @data.value(''''(/EVENT_INSTANCE/ObjectType)[1]'''', ''''varchar(100)''''),
   @data.value(''''(/EVENT_INSTANCE/TargetObjectName)[1]'''', ''''varchar(100)''''),
   @data.value(''''(/EVENT_INSTANCE/PostTime)[1]'''', ''''datetime''''),
   HOST_NAME(),
   @data.value(''''(/EVENT_INSTANCE/EventType)[1]'''', ''''nvarchar(100)'''')) ''

EXEC (@SQL)'

EXEC (@SQL)

FETCH NEXT FROM MHCURSOR INTO @DATABASE
END
CLOSE MHCURSOR
DEALLOCATE MHCURSOR