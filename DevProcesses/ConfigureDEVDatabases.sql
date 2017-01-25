USE LucityDev
GO
IF NOT EXISTS (SELECT * FROM LucityDev.dbo.sysusers WHERE NAME = 'GBAMS\gbaMSDevDBOwners')
	CREATE USER [GBAMS\gbaMSDevDBOwners] FOR LOGIN [GBAMS\gbaMSDevDBOwners]
EXEC sp_addrolemember N'db_owner', N'GBAMS\gbaMSDevDBOwners'
IF NOT EXISTS (SELECT * FROM LucityDev.dbo.sysusers WHERE NAME = 'GBAMS\gbaMSDEVInstanceUsers')
	CREATE USER [GBAMS\gbaMSDEVInstanceUsers] FOR LOGIN [GBAMS\gbaMSDEVInstanceUsers]
EXEC sp_addrolemember N'GBAMS_GATEWAY', N'GBAMS\gbaMSDEVInstanceUsers'
IF NOT EXISTS (SELECT * FROM LucityDev.dbo.sysusers WHERE NAME = 'GBAMS\Domain Users')
	CREATE USER [GBAMS\Domain Users] FOR LOGIN [GBAMS\Domain Users]
EXEC sp_addrolemember N'GBAMS_GATEWAY', N'GBAMS\Domain Users'


DROP TRIGGER [LUCITY_PREVENT_DDL] ON DATABASE
GO

USE DatabaseTracker
GO
IF NOT EXISTS (SELECT * FROM DatabaseTracker.dbo.sysusers WHERE NAME = 'GBAMS\gbaMSDevDBOwners')
	CREATE USER [GBAMS\gbaMSDevDBOwners] FOR LOGIN [GBAMS\gbaMSDevDBOwners]
EXEC sp_addrolemember N'db_ddladmin', N'GBAMS\gbaMSDevDBOwners'
EXEC sp_addrolemember N'db_datawriter', N'GBAMS\gbaMSDevDBOwners'
EXEC sp_addrolemember N'db_datareader', N'GBAMS\gbaMSDevDBOwners'

DROP USER [LUCITY_USER]
GO
CREATE USER [LUCITY_USER] FOR LOGIN [LUCITY_USER] WITH DEFAULT_SCHEMA=[dbo]
GO
GRANT INSERT ON [dbo].[TRACK_DDL] TO [LUCITY_USER]
GRANT DELETE ON [dbo].[TRACK_DDL] TO [LUCITY_USER]
GRANT UPDATE ON [dbo].[TRACK_DDL] TO [LUCITY_USER]
GRANT REFERENCES ON [dbo].[TRACK_DDL] TO [LUCITY_USER]
GRANT INSERT ON [dbo].[TRACK_DML] TO [LUCITY_USER]
GRANT DELETE ON [dbo].[TRACK_DML] TO [LUCITY_USER]
GRANT UPDATE ON [dbo].[TRACK_DML] TO [LUCITY_USER]
GRANT REFERENCES ON [dbo].[TRACK_DML] TO [LUCITY_USER]
GO

use [Eden_Demo]
GO
IF NOT EXISTS (SELECT * FROM Eden_Demo.dbo.sysusers WHERE NAME = 'GBAMS\gbaMSDevDBOwners')
	CREATE USER [GBAMS\gbaMSDevDBOwners] FOR LOGIN [GBAMS\gbaMSDevDBOwners]
DROP USER [LUCITY_USER]
GO
CREATE USER [LUCITY_USER] FOR LOGIN [LUCITY_USER] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sp_addrolemember N'db_owner', N'LUCITY_USER'
GO
