CREATE TRIGGER [TRACK_DDL_on_TABLE]
ON DATABASE 
AFTER CREATE_TABLE,ALTER_TABLE
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

declare @tableName nvarchar(max)
declare @msg varchar(1000)
Set @msg = ''
select @tableName= @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(max)')
Declare @columnName nvarchar(128),
		@dataType nvarchar(128)

DECLARE COLUMN_DATA_TYPE CURSOR FOR 
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE (DATA_TYPE NOT IN ('int','float','varchar','smallint','bit','datetime','money','decimal','geometry','varbinary') OR (DATA_TYPE = 'varchar' AND CHARACTER_MAXIMUM_LENGTH = -1 AND COLUMN_NAME LIKE '%[_]MEMO%' AND TABLE_NAME NOT LIKE '%GDMEMO')) AND TABLE_NAME = @tableName
OPEN COLUMN_DATA_TYPE

FETCH NEXT FROM COLUMN_DATA_TYPE 
INTO @columnName, @dataType
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @msg = @msg + @tableName + '.' + @columnName + ' (' + @dataType + ') ' + ' is not a supported GBAMS datatype or references _MEMO in the column name.' + CHAR(13) + CHAR(10)
	FETCH NEXT FROM COLUMN_DATA_TYPE 
	INTO @columnName, @dataType
END
CLOSE COLUMN_DATA_TYPE
DEALLOCATE COLUMN_DATA_TYPE

IF @msg <> '' 
RAISERROR (@msg , 16, 1)