/* PERFORM A FIND & REPLACE ON "DATABASENAME" AND ENTER THE NAME OF THE EDEN DATABASE*/
/* IF THE CLIENT DOES NOT OWN WATER, THEN REMOVE THE WATER SECTION AT THE END OF THE SCRIPT*/

/*THIS SCRIPT WAS LAST MODIFIED 3/15/10 TO CHANGE THE WKMETER STORED PROC - NES*/

USE Lucity
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = 'DATABASE' AND name = N'LUCITY_PREVENT_DDL')
DISABLE TRIGGER [LUCITY_PREVENT_DDL] ON DATABASE
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_CUSTOMER]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_CUSTOMER
GO

CREATE VIEW dbo.EDEN_CUSTOMER
AS
SELECT     *
FROM         DATABASENAME.dbo.ESRCUSTR
GO
GRANT SELECT ON dbo.EDEN_CUSTOMER TO LUCITYREADERWRITER AS dbo

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_PROJNO]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_PROJNO
GO

CREATE VIEW dbo.EDEN_PROJNO
AS
SELECT     *
FROM         DATABASENAME.dbo.ESGBAPRV
GO
GRANT SELECT ON dbo.EDEN_PROJNO TO LUCITYREADERWRITER AS dbo

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_INVENTORY]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_INVENTORY
GO

CREATE VIEW dbo.EDEN_INVENTORY
AS
SELECT     *
FROM         DATABASENAME.dbo.ESGBAIWV
GO
GRANT SELECT ON dbo.EDEN_INVENTORY TO LUCITYREADERWRITER AS dbo

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_ACCTNO]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_ACCTNO
GO

CREATE VIEW dbo.EDEN_ACCTNO
AS
SELECT     *
FROM         DATABASENAME.dbo.ESGBAACV
GO
GRANT SELECT ON dbo.EDEN_ACCTNO TO LUCITYREADERWRITER AS dbo

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_PARCADDCUST]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_PARCADDCUST
GO


CREATE VIEW dbo.EDEN_PARCADDCUST
AS
SELECT     PARC_ID, RTRIM(LTRIM(apn)) as apn, parc_addr1, parc_addr2, RTRIM(LTRIM(parc_city)) AS parc_city, RTRIM(LTRIM(parc_state)) AS parc_state, RTRIM(LTRIM(parc_zip)) 
                      AS parc_zip, parc_street_no, RTRIM(LTRIM(parc_pref_dir)) AS parc_pref_dir, RTRIM(LTRIM(parc_street_name)) AS parc_street_name, 
                      RTRIM(LTRIM(parc_street_type)) AS parc_street_type, RTRIM(LTRIM(parc_suff_dir)) AS parc_suff_dir, RTRIM(LTRIM(ub_acct_no)) AS ub_acct_no, 
                      RTRIM(LTRIM(ub_last_name)) AS ub_last_name, RTRIM(LTRIM(ub_first_name)) AS ub_first_name, RTRIM(LTRIM(ub_home_phone)) AS ub_home_phone, 
                      RTRIM(LTRIM(ub_work_phone)) AS ub_work_phone, RTRIM(LTRIM(ub_cell_phone)) AS ub_cell_phone, RTRIM(LTRIM(ub_alt_phone)) AS ub_alt_phone
FROM         DATABASENAME.dbo.eslpaucv
GO
GRANT SELECT ON dbo.EDEN_PARCADDCUST TO LUCITYREADERWRITER AS dbo

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_PARCADDMETER]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_PARCADDMETER
GO

CREATE VIEW dbo.EDEN_PARCADDMETER
AS
SELECT     PARC_ID, RTRIM(LTRIM(apn)) AS apn, parc_addr1, parc_addr2, RTRIM(LTRIM(parc_city)) AS parc_city, RTRIM(LTRIM(parc_state)) AS parc_state, 
                      RTRIM(LTRIM(parc_zip)) AS parc_zip, parc_street_no, RTRIM(LTRIM(parc_pref_dir)) AS parc_pref_dir, RTRIM(LTRIM(parc_street_name)) 
                      AS parc_street_name, RTRIM(LTRIM(parc_street_type)) AS parc_street_type, RTRIM(LTRIM(parc_suff_dir)) AS parc_suff_dir, 
                      RTRIM(LTRIM(meter_number)) AS meter_number, METER_ID, meter_loc_id, RTRIM(LTRIM(meter_type_code)) AS meter_type_code, meter_type_desc, 
                      use_type_code, use_type_desc
FROM         DATABASENAME.dbo.eslpaumv
GO
GRANT SELECT ON dbo.EDEN_PARCADDMETER TO LUCITYREADERWRITER AS dbo

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_PARCADDOWN]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_PARCADDOWN
GO

CREATE VIEW dbo.EDEN_PARCADDOWN
AS
SELECT     PARC_ID, RTRIM(LTRIM(apn)) AS apn, parc_addr1, parc_addr2, RTRIM(LTRIM(parc_city)) AS parc_city, RTRIM(LTRIM(parc_state)) AS parc_state, 
                      parc_zip, parc_street_no, RTRIM(LTRIM(parc_pref_dir)) AS parc_pref_dir, RTRIM(LTRIM(parc_street_name)) AS parc_street_name, 
                      RTRIM(LTRIM(parc_street_type)) AS parc_street_type, RTRIM(LTRIM(parc_suff_dir)) AS parc_suff_dir, RTRIM(LTRIM(owner_last_name)) 
                      AS owner_last_name, RTRIM(LTRIM(owner_first_name)) AS owner_first_name, RTRIM(LTRIM(owner_phone)) AS owner_phone, owner_addr1, 
                      owner_addr2, owner_city, owner_state, owner_zip
FROM         DATABASENAME.dbo.eslpaoav
GO
GRANT SELECT ON dbo.EDEN_PARCADDOWN TO LUCITYREADERWRITER AS dbo


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[eslparcr]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.eslparcr
GO

CREATE VIEW dbo.eslparcr
AS
SELECT     *
FROM         DATABASENAME.dbo.eslparcr
GO
GRANT SELECT ON dbo.eslparcr TO LUCITYREADERWRITER AS dbo


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[esusvlor]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.esusvlor
GO

CREATE VIEW dbo.esusvlor
AS
SELECT     *
FROM         DATABASENAME.dbo.esusvlor
GO
GRANT SELECT ON dbo.esusvlor TO LUCITYREADERWRITER AS dbo


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[esuservd]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.esuservd
GO

CREATE VIEW dbo.esuservd
AS
SELECT     *
FROM         DATABASENAME.dbo.esuservd
GO
GRANT SELECT ON dbo.esuservd TO LUCITYREADERWRITER AS dbo




IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[esuacctr]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.esuacctr
GO

CREATE VIEW dbo.esuacctr
AS
SELECT     *
FROM         DATABASENAME.dbo.esuacctr
GO
GRANT SELECT ON dbo.esuacctr TO LUCITYREADERWRITER AS dbo




IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[esucustj]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.esucustj
GO

CREATE VIEW dbo.esucustj
AS
SELECT     *
FROM         DATABASENAME.dbo.esucustj
GO
GRANT SELECT ON dbo.esucustj TO LUCITYREADERWRITER AS dbo




IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[esqcustr]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.esqcustr
GO

CREATE VIEW dbo.esqcustr
AS
SELECT     *
FROM         DATABASENAME.dbo.esqcustr
GO
GRANT SELECT ON dbo.esqcustr TO LUCITYREADERWRITER AS dbo




IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[esladdrj]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.esladdrj
GO

CREATE VIEW dbo.esladdrj
AS
SELECT     *
FROM         DATABASENAME.dbo.esladdrj
GO
GRANT SELECT ON dbo.esladdrj TO LUCITYREADERWRITER AS dbo


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[esladdrr]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.esladdrr
GO

CREATE VIEW dbo.esladdrr
AS
SELECT     *
FROM         DATABASENAME.dbo.esladdrr
GO
GRANT SELECT ON dbo.esladdrr TO LUCITYREADERWRITER AS dbo



IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[eslstrtr]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.eslstrtr
GO

CREATE VIEW dbo.eslstrtr
AS
SELECT     *
FROM         DATABASENAME.dbo.eslstrtr
GO
GRANT SELECT ON dbo.eslstrtr TO LUCITYREADERWRITER AS dbo

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ESQCMODD]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.ESQCMODD
GO	

CREATE VIEW dbo.ESQCMODD
AS
SELECT     *
FROM         DATABASENAME.dbo.ESQCMODD
GO
GRANT SELECT ON dbo.ESQCMODD TO LUCITYREADERWRITER AS dbo

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ESLOWNRR]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.ESLOWNRR
GO

CREATE VIEW dbo.ESLOWNRR
AS
SELECT     *
FROM         DATABASENAME.dbo.ESLOWNRR
GO
GRANT SELECT ON dbo.ESLOWNRR TO LUCITYREADERWRITER AS dbo


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_ACTIVECUST]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_ACTIVECUST
GO

CREATE VIEW dbo.EDEN_ACTIVECUST
AS
SELECT     dbo.esqcustr.CUST_ID, dbo.esqcustr.LAST_NAME, dbo.esqcustr.FIRST_NAME, dbo.esqcustr.BUS_NAME, dbo.esqcustr.EMAIL_ADDRESS, 
                      dbo.esqcustr.SPOUSE_LAST_NAME, dbo.esqcustr.SPOUSE_FIRST_NAME, dbo.esqcustr.PRIM_ADDR_CODE_ID AS ADDR_ID, 
                      dbo.esqcustr.ACTIVE_FLAG, dbo.esqcustr.HOME_PHONE, dbo.esqcustr.CELL_PHONE, dbo.esqcustr.ALT_PHONE, dbo.esqcustr.WORK_PHONE, 
                      dbo.esqcustr.STAT_CODE, dbo.esuacctr.ACCT_NO, dbo.esuacctr.ACCT_TYPE, dbo.esucustj.ACCT_ID AS ACCT_ID
FROM         dbo.esqcustr INNER JOIN
                      dbo.esucustj ON dbo.esqcustr.CUST_ID = dbo.esucustj.CUST_ID INNER JOIN
                      dbo.esuacctr ON dbo.esucustj.ACCT_ID = dbo.esuacctr.ACCT_ID
WHERE     (dbo.esuacctr.STAT_PRIORITY < 4)


GO
GRANT SELECT ON dbo.EDEN_ACTIVECUST TO LUCITYREADERWRITER AS dbo




IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_ACTIVECUSTOWN]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_ACTIVECUSTOWN
GO

CREATE VIEW dbo.EDEN_ACTIVECUSTOWN
AS
SELECT     *
FROM         (SELECT     'cust' RECORD_TYPE, EDEN_ACTIVECUST.CUST_ID AS CUST_ID, LAST_NAME, FIRST_NAME,EMAIL_ADDRESS, 
                      	SPOUSE_LAST_NAME, SPOUSE_FIRST_NAME, BUS_NAME,  HOME_PHONE, WORK_PHONE,CELL_PHONE, ALT_PHONE, 0 ADDR_ID
FROM         EDEN_ACTIVECUST LEFT OUTER JOIN ESQCMODD ON EDEN_ACTIVECUST.CUST_ID = ESQCMODD.CUST_ID AND ESQCMODD.MODULE_ABBR = 'ub' 
UNION        SELECT     'owner' RECORD_TYPE, ESLOWNRR.OWN_ID, ESLOWNRR.LNAME, ESLOWNRR.FNAME,'' EMAIL_ADDRESS,'' SPOUSE_LAST_NAME,'' SPOUSE_FIRST_NAME, '' BUS_NAME, ESLOWNRR.OWN_PHONE, '' WORK_PHONE, '' CELL_PHONE, '' ALT_PHONE, ESLOWNRR.ADDR_ID
FROM         ESLOWNRR) DERIVEDTBL

GO
GRANT SELECT ON dbo.EDEN_ACTIVECUSTOWN TO LUCITYREADERWRITER AS dbo



IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_PARCADDCUSTOWN]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_PARCADDCUSTOWN
GO

CREATE VIEW dbo.EDEN_PARCADDCUSTOWN
AS
SELECT     *
FROM         (SELECT     *
                       FROM          EDEN_PARCADDCUST
                       UNION
                       SELECT     eslparcr.PARC_ID, LTRIM(RTRIM(eslparcr.APN)) AS APN, LTRIM(RTRIM(PA.MAIN_ADDR_DISP)) AS PARC_ADDR1, 
                                             LTRIM(RTRIM(PA.ADDR_2)) AS PARC_ADDR2, LTRIM(RTRIM(PS.CITY)) AS PARC_CITY, LTRIM(RTRIM(PS.STATE)) AS PARC_STATE, 
                                             LTRIM(RTRIM(PA.ZIP)) AS PARC_ZIP, PA.STREET_NO AS PARC_STREET_NO, LTRIM(RTRIM(PS.PREF_DIR)) AS PARC_PREF_DIR, 
                                             LTRIM(RTRIM(PS.STREET_NAME)) AS PARC_STREET_NAME, LTRIM(RTRIM(PS.STREET_TYPE)) AS PARC_STREET_TYPE, 
                                             LTRIM(RTRIM(PS.SUFF_DIR)) AS PARC_SUFF_DIR, '' AS UB_ACCT_NO, PO.LNAME AS UB_LAST_NAME, PO.FNAME AS UB_FIRST_NAME, 
                                             PO.OWN_PHONE AS UB_HOME_PHONE, '' AS UB_WORK_PHONE, '' AS UB_CELL_PHONE, '' AS UB_ALT_PHONE
                       FROM         eslparcr LEFT OUTER JOIN
                                             esladdrj PAJ ON PAJ.JOIN_ID = eslparcr.PARC_ID AND PAJ.REL_TYPE = 'P' AND PAJ.PRIME_ADDR = 'Y' LEFT OUTER JOIN
                                             esladdrr PA ON PA.ADDR_ID = PAJ.ADDR_ID LEFT OUTER JOIN
                                             eslstrtr PS ON PS.STREET_ID = PA.STREET_ID LEFT OUTER JOIN
                                             ESLOWNRR PO ON PO.ADDR_ID = PA.ADDR_ID) DERIVEDTBL


GO
GRANT SELECT ON dbo.EDEN_PARCADDCUSTOWN TO LUCITYREADERWRITER AS dbo


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_WAREHOUSE]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_WAREHOUSE
GO

CREATE VIEW dbo.EDEN_WAREHOUSE
AS
SELECT     WHSE_ID, WHSE_CODE, WHSE_DESC
FROM         DATABASENAME.dbo.ESVWHSER
GO
GRANT SELECT ON dbo.EDEN_WAREHOUSE TO LUCITYREADERWRITER AS dbo


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_MLOCLOOKUPD]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_MLOCLOOKUPD
GO

CREATE VIEW dbo.EDEN_MLOCLOOKUPD
AS
SELECT MT_ID      AS GBA_UP_ID,
       MT_NUMBER  AS UP_NO,
       MT_ADR_BDG AS STREET_NO,
       MT_ADR_B2  AS STREET_FRACT,
       MT_ADR_PT  AS PREF_TYPE,
       MT_ADR_DIR AS PREF_DIR,
       MT_ADR_STR AS STREET_NAME,
       MT_ADR_TY  AS STREET_TYPE,
       MT_ADR_SFX AS SUFF_DIR,
       MT_APT_NO  AS ADDR_2,
       MT_LOCATE  AS LOC_DESC,
       MT_POSTAL  AS ZIP
FROM   WTMETER
GO
GRANT SELECT ON dbo.EDEN_MLOCLOOKUPD TO LUCITYREADERWRITER AS dbo


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[EDEN_WKMETER]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW dbo.EDEN_WKMETER
GO

CREATE VIEW EDEN_WKMETER
AS
SELECT RQ_ID, 
       RQ_NUMBER,
       RQ_STAT_CD,
       RQ_STAT_TY, 
       AS_LINK1, 
       AS_COMP_DT, 
       AS_MTRDEV, 
       AS_NEWMTR, 
       AS_CUR_RD1, 
       AS_CUR_RD2, 
       AS_CUR_RD3, 
       AS_NEW_RD1, 
       AS_NEW_RD2, 
       AS_NEW_RD3, 
       AS_MST_CD, 
       AS_MST_TY,
       AS_INV_ID AS GBA_UP_ID
FROM WKREQ LEFT OUTER JOIN 
	(SELECT AS_LINK1,
	   AS_COMP_DT, 
       AS_MTRDEV, 
       AS_NEWMTR, 
       AS_CUR_RD1, 
       AS_CUR_RD2, 
       AS_CUR_RD3, 
       AS_NEW_RD1, 
       AS_NEW_RD2, 
       AS_NEW_RD3, 
       AS_MST_CD, 
       AS_MST_TY ,  
       WO_MW_ID, 
       AS_INV_ID, 
       AS_CAT_INV FROM WKWOASSET 
       INNER JOIN WKORDER ON WKORDER.WO_ID = WKWOASSET.AS_WO_ID
       ) AS WORKORDERS 
	ON WORKORDERS.AS_INV_ID = WKREQ.RQ_INFR_ID 
	AND WORKORDERS.AS_CAT_INV = WKREQ.RQ_INV_ID AND
	WORKORDERS.WO_MW_ID = WKREQ.RQ_MW_ID
	
GO
GRANT SELECT ON dbo.EDEN_WKMETER TO LUCITYREADERWRITER AS dbo

IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = 'DATABASE' AND name = N'LUCITY_PREVENT_DDL')
ENABLE TRIGGER [LUCITY_PREVENT_DDL] ON DATABASE
GO