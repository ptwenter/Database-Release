--set identity_insert user_info on 
--insert into user_info (initials, password, last_name, first_name, default_group, allow_gba_auth, user_id,EMAIL,USER_ENABLED,USER_MUSTCHG,USER_MOD_BY,USER_MOD_DT,USER_MOD_TM,USER_CRT_BY,USER_CRT_DTTM,USER_HASH,USER_PWD_DTTM, USER_SHRDTABGID, USER_PWD_NOEXP, USER_LOCKED, USER_FAIL_DTTM, USER_FAILCOUNT) select initials, password, last_name, first_name, default_group, allow_gba_auth, user_id,EMAIL,USER_ENABLED,USER_MUSTCHG,USER_MOD_BY,USER_MOD_DT,USER_MOD_TM,USER_CRT_BY,USER_CRT_DTTM,USER_HASH,USER_PWD_DTTM, USER_SHRDTABGID, USER_PWD_NOEXP, USER_LOCKED, USER_FAIL_DTTM, USER_FAILCOUNT from [lct-sql-01\DEV2008].Lucitydev.dbo.user_info WHERE INITIALS NOT IN (SELECT INITIALS FROM USER_INFO)
--set identity_insert user_info off
--set identity_insert windowstouser ON 
--insert into windowstouser (UM_ID, UM_WINACCOUNT, UM_GBAINITIALS, UM_USER_ID) select UM_ID, UM_WINACCOUNT, UM_GBAINITIALS, UM_USER_ID from [lct-sql-01\DEV2008].Lucitydev.dbo.windowstouser 
--set identity_insert windowstouser off
--set identity_insert group_names ON 
--insert into group_names (GROUP_NAME, GROUP_MAP_ID, GROUP_ROWVER, GROUP_DFLTWOVW, GROUP_MBLMAP_ID, GROUP_ID) select GROUP_NAME, GROUP_MAP_ID, GROUP_ROWVER, GROUP_DFLTWOVW, GROUP_MBLMAP_ID, GROUP_ID from [lct-sql-01\DEV2008].Lucitydev.dbo.group_names where group_name not in (select group_name from group_names)
--set identity_insert group_names OFF
--insert into group_assignment select * from [lct-sql-01\DEV2008].Lucitydev.dbo.group_assignment WHERE GROUP_NAME + INITIALS NOT IN (SELECT GROUP_NAME + INITIALS FROM group_assignment)
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = T2.SYSSET_VALUE FROM SYSTEMSETTINGS T1 INNER JOIN [lct-sql-01\DEV2008].Lucitydev.dbo.SYSTEMSETTINGS T2 ON T1.SYSSET_ID = T2.SYSSET_ID
UPDATE CONNECTSTRINGS SET CONN_SERVER = T2.CONN_SERVER, CONN_DB = T2.CONN_DB, CONN_USERID = T2.CONN_USERID, CONN_PASSWORD = T2.CONN_PASSWORD FROM CONNECTSTRINGS T1 INNER JOIN [lct-sql-01\DEV2008].Lucitydev.dbo.CONNECTSTRINGS T2 ON T1.CONN_PROGRAM = T2.CONN_PROGRAM
DELETE FROM CLIENTLICENSES
INSERT INTO CLIENTLICENSES SELECT * FROM [lct-sql-01\DEV2008].Lucitydev.dbo.CLIENTLICENSES
DELETE FROM LBLDGPROPINFO
INSERT INTO LBLDGPROPINFO SELECT * FROM [lct-sql-01\DEV2008].Lucitydev.dbo.LBLDGPROPINFO
--DELETE FROM CMIMPORTUPDATE
--Make sure all new columns are listed
--INSERT INTO CMIMPORTUPDATE (IMP_NAME, IMP_DAT_SOURCE, IMP_DAT_TYPE, IMP_DAT_SQL, IMP_DAT_HEADER, IMP_DAT_SCHEMA, IMP_DAT_DELIM, IMP_CORRELATS, IMP_MAPPINGS, IMP_DESTINATION, IMP_ADD, IMP_UPDATE, IMP_UNIQUE, IMP_EXPORT, IMP_EXPORT_DIR, IMP_SHOW_REVIEW, IMP_GROUP, IMP_GROUP_ORD, IMP_EML_ALWAYS, IMP_EML_ERROR, IMP_EML_FROM, IMP_EML_TO, IMP_EML_CC, IMP_EML_HOST, IMP_EML_SUB, IMP_MOD_BY, IMP_MOD_DT, IMP_MOD_TM, IMP_ROWVER, IMP_CRT_BY, IMP_CRT_DTTM, IMP_CLEAR, IMP_TEMPLATE, IMP_SYS_TMPLT, IMP_PROMPT_CONN, IMP_DESC, IMP_TRACK_SRCE, IMP_CUSTOM, IMP_DL_TYPE, IMP_DL_SRCE, IMP_DL_RMV, IMP_PRE_PROC, IMP_POST_PROC, IMP_TSC_ID, IMP_CDTY_IMP) SELECT IMP_NAME, IMP_DAT_SOURCE, IMP_DAT_TYPE, IMP_DAT_SQL, IMP_DAT_HEADER, IMP_DAT_SCHEMA, IMP_DAT_DELIM, IMP_CORRELATS, IMP_MAPPINGS, IMP_DESTINATION, IMP_ADD, IMP_UPDATE, IMP_UNIQUE, IMP_EXPORT, IMP_EXPORT_DIR, IMP_SHOW_REVIEW, IMP_GROUP, IMP_GROUP_ORD, IMP_EML_ALWAYS, IMP_EML_ERROR, IMP_EML_FROM, IMP_EML_TO, IMP_EML_CC, IMP_EML_HOST, IMP_EML_SUB, IMP_MOD_BY, IMP_MOD_DT, IMP_MOD_TM, IMP_ROWVER, IMP_CRT_BY, IMP_CRT_DTTM, IMP_CLEAR, IMP_TEMPLATE, IMP_SYS_TMPLT, IMP_PROMPT_CONN, IMP_DESC, IMP_TRACK_SRCE, IMP_CUSTOM, IMP_DL_TYPE, IMP_DL_SRCE, IMP_DL_RMV, IMP_PRE_PROC, IMP_POST_PROC, IMP_TSC_ID, IMP_CDTY_IMP FROM [lct-sql-01\DEV2008].Lucitydev.dbo.CMIMPORTUPDATE

--Populate the LL and CMIMPORTUPDATE tables
DECLARE @TABLENAME VARCHAR(50),
		@COLUMN_NAME VARCHAR(50),
		@IS_IDENTITY BIT,
		@HAS_IDENTITY BIT,
		@COLUMN_NAMES VARCHAR(MAX),
		@SQL VARCHAR(MAX)
DECLARE LLCURSOR	CURSOR FOR SELECT TABLE_NAME FROM [lct-sql-01\DEV2008].Lucitydev.INFORMATION_SCHEMA.TABLES WHERE (TABLE_NAME LIKE 'LL%' OR TABLE_NAME = 'CMIMPORTUPDATE' OR TABLE_NAME LIKE 'CML%') AND TABLE_TYPE = 'BASE TABLE'
OPEN LLCURSOR
FETCH NEXT FROM LLCURSOR INTO @TABLENAME
WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE COLUMN_CURSOR CURSOR FOR
	SELECT '[' + UPPER(NAME) + ']', IS_IDENTITY FROM [lct-sql-01\DEV2008].Lucitydev.SYS.COLUMNS WHERE OBJECT_ID = (SELECT OBJECT_ID FROM [lct-sql-01\DEV2008].Lucitydev.SYS.OBJECTS WHERE NAME= @TABLENAME) ORDER BY COLUMN_ID

	OPEN COLUMN_CURSOR

	FETCH NEXT FROM COLUMN_CURSOR
	INTO @COLUMN_NAME, @IS_IDENTITY

	SET @COLUMN_NAMES = ''
	SET @HAS_IDENTITY = 0

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @COLUMN_NAMES = ''
			SET @COLUMN_NAMES = @COLUMN_NAME
		ELSE
			SET @COLUMN_NAMES = @COLUMN_NAMES + ', ' + @COLUMN_NAME

		IF @IS_IDENTITY = 1
			SET @HAS_IDENTITY = 1

		FETCH NEXT FROM COLUMN_CURSOR INTO @COLUMN_NAME, @IS_IDENTITY
	END
	CLOSE COLUMN_CURSOR
	DEALLOCATE COLUMN_CURSOR
		
	SET @SQL = 'DELETE FROM ' + @TABLENAME + '; ' + 'INSERT INTO ' + @TABLENAME + '(' + @COLUMN_NAMES + ') SELECT ' + @COLUMN_NAMES + ' FROM [lct-sql-01\DEV2008].Lucitydev.dbo.' + @TABLENAME + ';'
	
	IF @HAS_IDENTITY = 1
		SET @SQL = 'SET IDENTITY_INSERT DBO.' + @TABLENAME + ' ON; ' + @SQL + ' SET IDENTITY_INSERT DBO.' + @TABLENAME + ' OFF;'

	PRINT @SQL
	EXEC (@SQL)
		
	FETCH NEXT FROM LLCURSOR INTO @TABLENAME
END
CLOSE LLCURSOR
DEALLOCATE LLCURSOR