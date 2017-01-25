CREATE TRIGGER [TRACK_DDL_on_PROC]
ON DATABASE 
FOR CREATE_PROCEDURE,ALTER_PROCEDURE,DROP_PROCEDURE
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

IF NOT (@data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(100)') LIKE '%GEN' AND @data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'nvarchar(100)') = 'PROCEDURE')
INSERT DatabaseTracker..StoredProctracker 
   (ProcName, TSQL, PostDateTime, DB_User, hostname, DatabaseName, EventType) 
   VALUES 
   (
   @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(100)'), 
   @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)'),
   GETDATE(), 
   CONVERT(nvarchar(100), CURRENT_USER), 
	host_name(),
   @data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'nvarchar(100)'), 
   @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)')
 ) ;


GO