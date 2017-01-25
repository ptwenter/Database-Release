/*
--In order to avoid increment time fields, need to indicate a starting date at least greater than 1/1/1900
DECLARE @sql varchar(max)
DECLARE Date_Update CURSOR FOR 
	SELECT 'UPDATE ' + TABLE_NAME + ' SET ' + COLUMN_NAME + ' = DATEADD(yy, 1,' + COLUMN_NAME + ') WHERE ' + COLUMN_NAME + ' > ''12/31/1999'' AND ' + COLUMN_NAME + ' < ''1/1/9999''' from INFORMATION_SCHEMA.COLUMNS where DATA_TYPE = 'datetime' and TABLE_NAME in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_TYPE = 'BASE TABLE') and COLUMN_NAME not like '%ROWVER' and COLUMN_NAME not like '%MOD_TM' 
OPEN Date_Update
FETCH NEXT FROM Date_Update INTO @sql
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC (@sql)
	FETCH NEXT FROM Date_Update INTO @sql
END
CLOSE Date_Update
DEALLOCATE Date_Update
*/
--DO NOT RUN THE ABOVE BECAUSE IF AN ERROR OCCURS (IE, FULL TRANSACTION LOG), YOU DON'T KNOW WHERE IT STOPPED AND HAVE NO WAY TO RESUME
--RUN THE FOLLOWING SELECT STATEMENT, THEN RUN THE OUTPUT IN ANOTHER QUERY, OR IN BLOCKS
--In order to avoid increment time fields, need to indicate a starting date at least greater than 1/1/1900
SELECT 'UPDATE ' + TABLE_NAME + ' SET ' + COLUMN_NAME + ' = DATEADD(yy, 1,' + COLUMN_NAME + ') WHERE ' + COLUMN_NAME + ' > ''12/31/1999'' AND ' + COLUMN_NAME + ' < ''1/1/9999''' from INFORMATION_SCHEMA.COLUMNS where DATA_TYPE = 'datetime' and TABLE_NAME in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_TYPE = 'BASE TABLE') and COLUMN_NAME not like '%ROWVER' and COLUMN_NAME not like '%MOD_TM' 