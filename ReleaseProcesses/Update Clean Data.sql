/* These statements ensure that data in the Clean database does not contain testing values and is uniform */
/* If modifying/adding statements to the below, determine if the same modifications need to be made to the script that backs up the Clean dbs */

update Lucity..cmfields set defaultvalue = null where defaultvalue = ''
update Lucity..elfields set defaultvalue = null where defaultvalue = ''
update Lucity..effields set defaultvalue = null where defaultvalue = ''
update Lucity..pkfields set defaultvalue = null where defaultvalue = ''
update Lucity..swfields set defaultvalue = null where defaultvalue = ''
update Lucity..smfields set defaultvalue = null where defaultvalue = ''
update Lucity..stfields set defaultvalue = null where defaultvalue = ''
update Lucity..wtfields set defaultvalue = null where defaultvalue = ''
update Lucity..wkfields set defaultvalue = null where defaultvalue = ''
update Lucity..cmfields set calculation = null where calculation = ''
update Lucity..elfields set calculation = null where calculation = ''
update Lucity..effields set calculation = null where calculation = ''
update Lucity..pkfields set calculation = null where calculation = ''
update Lucity..swfields set calculation = null where calculation = ''
update Lucity..smfields set calculation = null where calculation = ''
update Lucity..stfields set calculation = null where calculation = ''
update Lucity..wtfields set calculation = null where calculation = ''
update Lucity..wkfields set calculation = null where calculation = ''
update Lucity..cmfields set UserName = null
update Lucity..elfields set UserName = null
update Lucity..effields set UserName = null
update Lucity..pkfields set UserName = null
update Lucity..swfields set UserName = null
update Lucity..smfields set UserName = null
update Lucity..stfields set UserName = null
update Lucity..wtfields set UserName = null
update Lucity..wkfields set UserName = null
update Lucity..cmfields set allowinput = 1
update Lucity..elfields set allowinput = 1
update Lucity..effields set allowinput = 1
update Lucity..pkfields set allowinput = 1
update Lucity..swfields set allowinput = 1
update Lucity..smfields set allowinput = 1
update Lucity..stfields set allowinput = 1
update Lucity..wtfields set allowinput = 1
update Lucity..wkfields set allowinput = 1
DELETE FROM Lucity..CMFIELDSDESC WHERE ID NOT IN (SELECT ID FROM Lucity..CMFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..CMFIELDSDESCTXT WHERE ID NOT IN (SELECT ID FROM Lucity..CMFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..ELFIELDSDESC WHERE ID NOT IN (SELECT ID FROM Lucity..ELFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..ELFIELDSDESCTXT WHERE ID NOT IN (SELECT ID FROM Lucity..ELFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..EFFIELDSDESC WHERE ID NOT IN (SELECT ID FROM Lucity..EFFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..EFFIELDSDESCTXT WHERE ID NOT IN (SELECT ID FROM Lucity..EFFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..PKFIELDSDESC WHERE ID NOT IN (SELECT ID FROM Lucity..PKFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..PKFIELDSDESCTXT WHERE ID NOT IN (SELECT ID FROM Lucity..PKFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..SWFIELDSDESC WHERE ID NOT IN (SELECT ID FROM Lucity..SWFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..SWFIELDSDESCTXT WHERE ID NOT IN (SELECT ID FROM Lucity..SWFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..SMFIELDSDESC WHERE ID NOT IN (SELECT ID FROM Lucity..SMFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..SMFIELDSDESCTXT WHERE ID NOT IN (SELECT ID FROM Lucity..SMFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..STFIELDSDESC WHERE ID NOT IN (SELECT ID FROM Lucity..STFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..STFIELDSDESCTXT WHERE ID NOT IN (SELECT ID FROM Lucity..STFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..WTFIELDSDESC WHERE ID NOT IN (SELECT ID FROM Lucity..WTFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..WTFIELDSDESCTXT WHERE ID NOT IN (SELECT ID FROM Lucity..WTFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..WKFIELDSDESC WHERE ID NOT IN (SELECT ID FROM Lucity..WKFIELDS WHERE SHAREDFIELD IS NULL)
DELETE FROM Lucity..WKFIELDSDESCTXT WHERE ID NOT IN (SELECT ID FROM Lucity..WKFIELDS WHERE SHAREDFIELD IS NULL)
delete from Lucity..activeuser
delete from Lucity..AUDITLOGONS
delete from Lucity..Group_Assignment WHERE Group_name + Initials <> 'PublicWebGroupPublicWebUser' AND Group_name + Initials <> 'RESTAPIGroupRESTAPILogon'
delete from Lucity..OBJECTLOCK
delete from Lucity..TEMPORARYTOKENS
delete from Lucity..CLIENTLICENSES
delete from Lucity..User_Info WHERE Initials NOT IN ('PublicWebUser', 'RESTAPILogOn', 'ScheduledTasksUser', 'BackgroundTaskUser')
update Lucity..User_Info set Password = '5A69527563653665' where initials = 'PublicWebUser'
update Lucity..User_Info set Password = '' where initials = 'RESTAPILogOn'
delete from Lucity..USERLICENSES
delete from Lucity..WINDOWSTOUSER	
update Lucity..SYSTEMSETTINGS set SYSSET_VALUE = NULL WHERE SYSSET_NAME IN ('LicenseIdentifier','ClientNumber','ClientName','ConfigDirectory','LicenseType', 'LicenseCode', 'CustomerAccountID')
update Lucity..CONNECTSTRINGS set CONN_SERVER = NULL, CONN_DB = NULL, CONN_USERID = NULL, CONN_PASSWORD = NULL, CONN_DISABLED = 0, CONN_COMPT = 1, CONN_PARMS = NULL