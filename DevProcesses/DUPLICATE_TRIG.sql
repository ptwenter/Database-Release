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

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[dbo].[TRIGINTERNAL_' + @PREFIX + 'PROPERTY_UNIQUECHECK]''))
DROP TRIGGER [dbo].[TRIGINTERNAL_' + @PREFIX + 'PROPERTY_UNIQUECHECK]

DECLARE @SQL VARCHAR(MAX)

SET @SQL = 

''CREATE TRIGGER TRIGINTERNAL_' + @PREFIX + 'PROPERTY_UNIQUECHECK 
ON ' + @PREFIX + 'PROPERTY
FOR INSERT, UPDATE
AS

BEGIN
	IF EXISTS (SELECT PROP_MODULEID, PROP_PROPERTY FROM ' + @PREFIX + 'PROPERTY GROUP BY PROP_MODULEID, PROP_PROPERTY HAVING COUNT(*) > 1)
	BEGIN
		ROLLBACK TRAN
		RAISERROR (''''Duplicate PROP_MODULEID and PROP_PROPERTY values will be created'''' , 16, 1, 2000)
		RETURN
	END
	IF EXISTS (SELECT PROP_PROPERTY FROM inserted WHERE PROP_PROPERTY LIKE ''''%[#!@$&* ()+=-_|\<>%,./]%'''')
	BEGIN
		ROLLBACK TRAN
		RAISERROR (''''PROP_PROPERTY has invalid characters!'''' , 16, 1, 2000)
		RETURN
	END
END''

EXEC (@SQL)'

EXEC (@SQL)
END

/*******************************************************************************************
END OF TRIGGER BLOCK
********************************************************************************************/

FETCH NEXT FROM MHCURSOR INTO @DATABASE, @PREFIX
END
CLOSE MHCURSOR
DEALLOCATE MHCURSOR