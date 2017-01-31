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
declare @dmoTable int
declare @path varchar(255)
declare @templatePath varchar(255)
declare @databaseName varchar(255)
declare @tableName varchar(255)
declare @source varchar(255)
declare @description varchar(255)
declare @tableCount int
declare @curTableNb int

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

	set @path = 'D:\SQLServerBackups\scripts\' + @databaseName + '_Triggers.sql'
	set @templatePath = 'D:\SQLServerBackups\scripts\TemplateTriggers.sql'

	/* clean up existing files */
	  begin
		select @osCmd = 'del ' + @path
		exec master..xp_cmdshell @osCmd, no_output
		select @osCmd = 'copy ' + @templatePath + ' ' + @path
		exec master..xp_cmdshell @osCmd, no_output
	  end

	/* get a collection of tables */
	select @dmoProperty = 'Databases("' + @databaseName + '").Tables.Count'
	exec @hr = master..sp_OAGetProperty @dmoServer,@dmoProperty,@tableCount OUT
	if @hr <> 0 
	  begin
		exec sp_OAGetErrorInfo @dmoServer, @source OUT, @description OUT
		print '1 ' + @source + ' ' + @description
		GoTo Quit
	  end  

	select @curTableNb = 1
	while @curTableNb <= @tableCount
	BEGIN
		
		/* only script user objects */
		select @boolSystemObject = 0    
		select @dmoProperty = 'Databases("' + @databaseName + '").Tables.Item(' + convert(varchar(5),@curTableNb) + ').SystemObject'
		exec @hr = master..sp_OAGetProperty @dmoServer,@dmoProperty,@boolSystemObject OUT
		if @hr <> 0 
		  begin
			exec sp_OAGetErrorInfo @dmoServer, @source OUT, @description OUT
			print '2 ' + @source + ' ' + @description
			GoTo Quit
		  end

		if @boolSystemObject = 0
		  begin

			select @dmoProperty = 'Databases("' + @databaseName + '").Tables.Item(' + convert(varchar(5),@curTableNb) + ')'		
			exec @hr = master..sp_OAGetProperty @dmoServer,@dmoProperty,@dmoTable OUT
			if @hr <> 0 
			  begin
				exec sp_OAGetErrorInfo @dmoServer, @source OUT, @description OUT
				print '3 ' + @source + ' ' + @description
				GoTo Quit
			  end  

			/* get the number of elements in the collection */
			select @dmoProperty = 'Triggers.Count'		
			exec @hr = master..sp_OAGetProperty @dmoTable,@dmoProperty,@objectCount OUT
			if @hr <> 0 
			  begin
				exec sp_OAGetErrorInfo @dmoTable, @source OUT, @description OUT
				print '4 ' + @source + ' ' + @description
				GoTo Quit
			  end

			select @curObjectNb = 1
			while @curObjectNb <= @objectCount 		
			  begin
			
				/* get the object name */
				select @dmoProperty = 'Triggers.Item(' + convert(varchar(5),@curObjectNb) + ').Name'
				exec @hr = master..sp_OAGetProperty @dmoTable,@dmoProperty,@objectName OUT
				if @hr <> 0 
				  begin
					exec sp_OAGetErrorInfo @dmoTable, @source OUT, @description OUT
					print '5 ' + @source + ' ' + @description
					GoTo Quit
				  end  
				select @dmoMethod = 'Triggers("' + @objectName + '").Script'
				
				EXEC ('
				  begin  
					/* put all object scripts in a single file */
					exec master..sp_OAMethod ' + @dmoTable + ',''' + @dmoMethod + ''',NULL,295,''' + @path + '''
				  end')
				if @hr <> 0 
				  begin
					exec sp_OAGetErrorInfo @dmoTable, @source OUT, @description OUT
					print '6 ' + @source + ' ' + @description
					GoTo Quit
				  end
			  
				select @curObjectNb = @curObjectNb + 1
			  end

			  EXEC @hr = sp_OADestroy @dmoTable
				IF @hr <> 0
				BEGIN
				   EXEC sp_OAGetErrorInfo @dmoTable, @source OUT, @description OUT
					print '7 ' + Cast(@hr as varchar) + ' ' + @source + ' ' + @description
					GoTo Quit
				END
		end
		select @curTableNb = @curTableNb + 1
	END

	FETCH NEXT FROM MHCURSOR INTO @databaseName
END
Quit:
CLOSE MHCURSOR
DEALLOCATE MHCURSOR
