/* Creates Scripts for every database and outputs them to a directory that the Server has access to */

declare @dmoMethod varchar(255) 
declare @dmoProperty varchar(255) 
declare @hr int
declare @boolSystemObject tinyint
declare @objectCount int
declare @curObjectNb int
declare @objectName varchar(256) 
declare @osCmd varchar(255)
declare @msg varchar(255)
declare @dmoServer int
declare @path varchar(255)
declare @templatePath varchar(255)
declare @databaseName varchar(255)

set nocount on

/* create a server object */
exec @hr = master..sp_OACreate 'SQLDMO.SQLServer', @dmoServer OUT


/* set the security context to integrated */
--exec @hr = master..sp_OASetProperty @dmoServer,'loginSecure',0
exec @hr = master..sp_OASetProperty @dmoServer,'loginSecure',1

/* connect to the specified server */
--exec @hr = master..sp_OAMethod @dmoServer,'Connect',NULL,@@SERVERNAME,'sa','----'
exec @hr = master..sp_OAMethod @dmoServer,'Connect',NULL,@@SERVERNAME


DECLARE MHCURSOR	CURSOR FOR SELECT NAME FROM [master].dbo.sysdatabases WHERE NAME LIKE 'LucityDev'
OPEN MHCURSOR
FETCH NEXT FROM MHCURSOR INTO @databaseName
WHILE @@FETCH_STATUS = 0
BEGIN

	set @path = 'D:\NetShares\N\Progdev\SP_Backup\' + @databaseName + '_Procedures.sql'
	set @templatePath = 'D:\NetShares\N\Progdev\SP_Backup\TemplateProcedures.sql'

	/* clean up existing files */
	  begin
		select @osCmd = 'del ' + @path
		exec master..xp_cmdshell @osCmd, no_output
		select @osCmd = 'copy ' + @templatePath + ' ' + @path
		exec master..xp_cmdshell @osCmd, no_output
	  end

	/* get the number of elements in the collection */
	select @dmoProperty = 'Databases("' + @databaseName + '").StoredProcedures.Count'
	exec @hr = master..sp_OAGetProperty @dmoServer,@dmoProperty,@objectCount OUT
	if @hr <> 0 
	  begin
		--exec sp_displayoaerrorinfo @dmoServer, @hr
		return
	  end
	select @curObjectNb = 1
	while @curObjectNb <= @objectCount 
	  begin
		  begin
			/* only script user objects */
			select @boolSystemObject = 0    
			select @dmoProperty = 'Databases("' + @databaseName + '").StoredProcedures.Item(' + convert(varchar(5),@curObjectNb) + ').SystemObject'
			exec @hr = master..sp_OAGetProperty @dmoServer,@dmoProperty,@boolSystemObject OUT
			if @hr <> 0 
			  begin
				--exec sp_displayoaerrorinfo @dmoServer, @hr
				return
			  end
		  end

		if @boolSystemObject = 0
		  begin
			/* get the object name */
			select @dmoProperty = 'Databases("' + @databaseName + '").StoredProcedures.Item(' + convert(varchar(5),@curObjectNb) + ').Name'
			exec @hr = master..sp_OAGetProperty @dmoServer,@dmoProperty,@objectName OUT
			if @hr <> 0 
			  begin
				--exec sp_displayoaerrorinfo @dmoServer, @hr
				return
			  end  
			select @dmoMethod = 'Databases("' + @databaseName + '").StoredProcedures("' + @objectName + '").Script'
			--if not exists(select * from fn_listextendedproperty(default, 'user', 'dbo', 'procedure', @objectName, default, default) WHERE NAME = 'microsoft_database_tools_support')
			--  begin  
			--	/* put all object scripts in a single file */
			--	exec @hr = master..sp_OAMethod @dmoServer,@dmoMethod,NULL,295,@path
			--  end
			EXEC ('if not exists(select * from ' + @databasename + '..fn_listextendedproperty(default, ''user'', ''dbo'', ''procedure'', ''' + @objectName + ''', default, default) WHERE NAME = ''microsoft_database_tools_support'')
			  begin  
				/* put all object scripts in a single file */
				exec master..sp_OAMethod ' + @dmoServer + ',''' + @dmoMethod + ''',NULL,295,''' + @path + '''
			  end')
			if @hr <> 0 
			  begin
				--exec sp_displayoaerrorinfo @dmoServer, @hr
				return
			  end
		  end
		select @curObjectNb = @curObjectNb + 1
	  end

	FETCH NEXT FROM MHCURSOR INTO @databaseName
END
CLOSE MHCURSOR
DEALLOCATE MHCURSOR
