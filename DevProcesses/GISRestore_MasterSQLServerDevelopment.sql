/*This script shouldn't need to be updated with each release.  It is always pointing to the same LucityGISDev gdb and services.*/

UPDATE GISCONN SET 
GCONN_DB = 'LucityGISDev', 
GCONN_SERVER = 'LCT-ARCSRV-02\SQLEXPRESS', 
GCONN_INSTANCE = 'sde:sqlserver:LCT-ARCSRV-02\SQLEXPRESS',
GCONN_UID = 'GISAdmin',
GCONN_PW = 'Admin2017!'
WHERE GCONN_ID = 1;

UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Park/MapServer' WHERE GSER_LABEL = 'LucityGIS_Park';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Facilities/MapServer' WHERE GSER_LABEL = 'LucityGIS_Facilities';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Sewer/MapServer' WHERE GSER_LABEL = 'LucityGIS_Sewer';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Storm/MapServer' WHERE GSER_LABEL = 'LucityGIS_Storm';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Street/MapServer' WHERE GSER_LABEL = 'LucityGIS_Street';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Traffic/MapServer' WHERE GSER_LABEL = 'LucityGIS_Traffic';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_ROW/MapServer' WHERE GSER_LABEL = 'LucityGIS_ROW';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Water_Dist/MapServer' WHERE GSER_LABEL = 'LucityGIS_Water_Dist';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Water_Raw/MapServer' WHERE GSER_LABEL = 'LucityGIS_Water_Raw';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Water_Recycled/MapServer' WHERE GSER_LABEL = 'LucityGIS_Water_Recycled';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Parcels/MapServer' WHERE GSER_LABEL = 'LucityGIS_Parcels';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_Redlining/FeatureServer' WHERE GSER_LABEL = 'LucityGIS_Redlining';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGIS_Imagery/ImageServer' WHERE GSER_LABEL = 'LucityGIS_Imagery';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGIS_LandBase/MapServer' WHERE GSER_LABEL = 'LucityGIS_LandBase';

UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_All_Editable/MapServer' WHERE GSER_LABEL = 'LucityGIS_All_Editable';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/LucityGISDev/LucityGIS_GISTasks_Editable/MapServer' WHERE GSER_LABEL = 'LucityGIS_GISTasks_Editable';

UPDATE GISMAPSERV SET GSER_URL = 'https://utility.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer' WHERE GSER_LABEL = 'DefaultGeometryService';
UPDATE GISMAPSERV SET GSER_URL = 'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer' WHERE GSER_LABEL = 'EsriWorldLocator';
UPDATE GISMAPSERV SET GSER_URL = 'https://arcgis.mylucity.net/server/rest/services/Utilities/PrintingTools/GPServer/Export%20Web%20Map%20Task' WHERE GSER_LABEL = 'DefaultPrintingService';

UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'TRUE' WHERE SYSSET_NAME = 'SpatialEnabled';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'TRUE' WHERE SYSSET_NAME = 'UseFeatureServiceForUpdates';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = NULL WHERE SYSSET_NAME = 'DefaultBaseMap';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = NULL WHERE SYSSET_NAME = 'DefaultMobileBaseMap';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 3419 WHERE SYSSET_NAME = 'OperationalWKID';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'EsriWorldLocator' WHERE SYSSET_NAME = 'DefaultGeocodeService';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'LucityGIS_LandBase' WHERE SYSSET_NAME = 'MaintenanceZoneServiceName';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'Maintenance Zones' WHERE SYSSET_NAME = 'MaintenanceZoneLayer';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'ZONE' WHERE SYSSET_NAME = 'MaintenanceZoneField';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'LucityGIS_LandBase' WHERE SYSSET_NAME = 'AlternateZoneServiceName';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'Special Districts' WHERE SYSSET_NAME = 'AlternateZoneLayer';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'DIST_CD' WHERE SYSSET_NAME = 'AlternateZoneField';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'tags: lucity, lucity_eval' WHERE SYSSET_NAME = 'GISPortalSearch';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'tags: lucity_basemap' WHERE SYSSET_NAME = 'GISPortalBasemapSearch';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = '3z4ECJOg4sqgjKjz' WHERE SYSSET_NAME = 'GISPortalClientID';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'TRUE' WHERE SYSSET_NAME = 'GISPortalEnabled';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = 'https://www.arcgis.com' WHERE SYSSET_NAME = 'GISPortalBaseURL';
UPDATE SYSTEMSETTINGS SET SYSSET_VALUE = '53PW7Esq9rERkspc' WHERE SYSSET_NAME = 'GISPortalOrgId';

INSERT INTO GISVIEW (MV_NAME, MV_DESC, MV_PORTALID, MV_MOD_BY, MV_MOD_DT, MV_MOD_TM, MV_CRT_BY, MV_CRT_DTTM, MV_POPUP)
VALUES ('Trace', 'Map containing sewer, storm, and water features', 'f8243fa511dd4947bc765691d1cecdca', 'EricD', GetDate(), GetDate(), 'EricD', GetDate(), 1);

INSERT INTO GISVIEW (MV_NAME, MV_DESC, MV_MOD_BY, MV_MOD_DT, MV_MOD_TM, MV_CRT_BY, MV_CRT_DTTM, MV_MAP_ID, MV_POPUP)
VALUES ('LucityMap_Sewer', 'GIS View containing a Lucity Webmap- LucityGIS_Sewer','EricD', GetDate(), GetDate(), 'EricD', GetDate(), 4, 1);


