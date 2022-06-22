
-- Please replace company : affected_UG and UserID : affected_UserID before run below script

ALTER SESSION SET CURRENT_SCHEMA = DGBWEB;

select /*insert*/ * from ACCOUNTPRODUCTSETTINGS  where Usergroup = 'MCILHENY';
select /*insert*/ * from ACCOUNTPRODUCTSETTINGSMAINT  where Usergroup = 'MCILHENY';

select /*insert*/ * from ACCTORCOMPBYACTIONXREFINST  where Usergroup = 'MCILHENY' and userid = 'MCILHENYNAN';
select /*insert*/ * from ACCTORCOMPBYACTIONXREFTMPL  where Usergroup = 'MCILHENY' and userid = 'MCILHENYNAN';

SELECT /*insert*/ * FROM usergroup where Usergroup = 'MCILHENY';
SELECT /*insert*/ * FROM usergroupmaint where Usergroup = 'MCILHENY';

SELECT /*insert*/ * FROM ENTITLEMENTSPERGROUP where Usergroup = 'MCILHENY';
SELECT /*insert*/ * FROM ENTITLEMENTSPERGROUPMAINT where Usergroup = 'MCILHENY';
 
SELECT /*insert*/ * FROM users where Usergroup = 'MCILHENY' and userid in ('MCILHENYNAN');
SELECT /*insert*/ * FROM usersmaint where Usergroup = 'MCILHENY' and userid in ('MCILHENYNAN');
 
select /*insert*/ * from userroles  where Usergroup = 'MCILHENY' and userid in ('MCILHENYNAN');
select /*insert*/ * from userrolesmaint  where Usergroup = 'MCILHENY' and userid in ('MCILHENYNAN');
                         
select /*insert*/ * from roles  where Usergroup = 'MCILHENY';
select /*insert*/ * from rolesmaint  where Usergroup = 'MCILHENY';

select /*insert*/ * from enterpriseaccount where Usergroup = 'MCILHENY';
select /*insert*/ * from enterpriseaccountmaint where Usergroup = 'MCILHENY';

select /*insert*/ * from USERPRODUCTSETTINGS where Usergroup = 'MCILHENY';
select /*insert*/ * from USERPRODUCTSETTINGSMAINT where Usergroup = 'MCILHENY';

select /*insert*/ * from restrictions  where Usergroup = 'MCILHENY' and roleid in(select roleid from userroles where usergroup = 'MCILHENY' and userid in ('MCILHENYNAN'));
select /*insert*/ * from restrictionsmaint  where Usergroup = 'MCILHENY' and roleid in(select roleid from userroles where usergroup = 'MCILHENY' and userid in ('MCILHENYNAN'));

select /*insert*/ * from dataentrestrictions  where Usergroup = 'MCILHENY' and roleid in(select roleid from userroles where usergroup = 'MCILHENY' and userid in ('MCILHENYNAN'));
select /*insert*/ * from dataentrestrictionsmaint  where Usergroup = 'MCILHENY' and roleid in(select roleid from userroles where usergroup = 'MCILHENY' and userid in ('MCILHENYNAN'));

select /*insert*/ * from entitlements  where Usergroup = 'MCILHENY' and roleid in(select roleid from userroles where usergroup = 'MCILHENY' and userid in ('MCILHENYNAN'));
select /*insert*/ * from entitlementsmaint  where Usergroup = 'MCILHENY' and roleid in(select roleid from userroles where usergroup = 'MCILHENY' and userid in ('MCILHENYNAN'));

select /*insert*/ * from dataentattrvalues  where Usergroup = 'MCILHENY' and roleid in(select roleid from userroles where usergroup = 'MCILHENY' and userid in ('MCILHENYNAN'));
select /*insert*/ * from dataentattrvaluesmaint  where Usergroup = 'MCILHENY' and roleid in(select roleid from userroles where usergroup = 'MCILHENY' and userid in ('MCILHENYNAN'));

SELECT /*insert*/ * FROM ACCOUNTCODES where Usergroup = 'MCILHENY';
SELECT /*insert*/ * FROM ACCOUNTCODESMAINT where Usergroup = 'MCILHENY';

WITH RECS AS (Select id  from ACH_COMPINFO where USERGROUP='MCILHENY')
(select ACH_COMPINFO_DEL from (select 'DELETE FROM ACH_COMPINFO WHERE ID = ''' ||R.id ||''';' AS ACH_COMPINFO_DEL  FROM RECS R));

WITH RECS AS (Select id  from ACH_COMPINFOMAINT where USERGROUP='MCILHENY')
(select ACH_COMPINFOMAINT_DEL from (select 'DELETE FROM ACH_COMPINFOMAINT WHERE ID = ''' ||R.id ||''';' AS ACH_COMPINFOMAINT_DEL  FROM RECS R));

WITH RECS AS (Select *  from ACH_COMP_BASETYPE where COMPINFO_ID IN (Select ID from ACH_COMPINFO where USERGROUP='MCILHENY'  ))
(select ACH_COMP_BASETYPE_DEL from (select 'DELETE FROM ACH_COMP_BASETYPE WHERE ID = ''' ||R.id ||''';' AS ACH_COMP_BASETYPE_DEL  FROM RECS R));

WITH RECS AS (Select id  from ACH_COMP_BASETYPEMAINT where COMPINFO_ID IN (Select ID from ACH_COMPINFO where USERGROUP='MCILHENY'  ))
(select ACH_COMP_BASETYPEMAINT_DEL from (select 'DELETE FROM ACH_COMP_BASETYPEMAINT WHERE ID = ''' ||R.id ||''';' AS ACH_COMP_BASETYPEMAINT_DEL  FROM RECS R));

WITH RECS AS (Select id  from ACH_COMP_CLIENTNAME where USERGROUP='MCILHENY')
(select ACH_COMP_CLIENTNAME_DEL from (select 'DELETE FROM ACH_COMP_CLIENTNAME WHERE ID = ''' ||R.id ||''';' AS ACH_COMP_CLIENTNAME_DEL  FROM RECS R));

WITH RECS AS (Select id  from ACH_COMP_CLIENTNAMEMAINT where USERGROUP='MCILHENY')
(select ACH_COMP_CLIENTNAMEMAINT_DEL from (select 'DELETE FROM ACH_COMP_CLIENTNAMEMAINT WHERE ID = ''' ||R.id ||''';' AS ACH_COMP_CLIENTNAMEMAINT_DEL  FROM RECS R));

WITH RECS AS (Select compinfo_id  from ACH_COMP_FILEIMPORT where COMPINFO_ID IN (select ID from ach_compinfo where usergroup = 'MCILHENY'))
(select ACH_COMP_FILEIMPORT_DEL from (select 'DELETE FROM ACH_COMP_FILEIMPORT WHERE compinfo_id = ''' ||R.compinfo_id ||''';' AS ACH_COMP_FILEIMPORT_DEL  FROM RECS R));

WITH RECS AS (Select compinfo_id  from ACH_COMP_FILEIMPORTMAINT where COMPINFO_ID IN (select ID from ACH_COMPINFOMAINT where usergroup = 'MCILHENY'))
(select ACH_COMP_FILEIMPORTMAINT_DEL from (select 'DELETE FROM ACH_COMP_FILEIMPORTMAINT WHERE compinfo_id = ''' ||R.compinfo_id ||''';' AS ACH_COMP_FILEIMPORTMAINT_DEL  FROM RECS R));

Select /*insert*/ *  from ACH_COMPINFO where USERGROUP='MCILHENY' ;
Select /*insert*/ * from ACH_COMPINFOMAINT where USERGROUP='MCILHENY' ;--
SELECT /*insert*/ * FROM ACH_COMP_BASETYPE WHERE COMPINFO_ID IN (Select ID from ACH_COMPINFO where USERGROUP='MCILHENY'  ) order by id;
SELECT /*insert*/  * FROM ACH_COMP_BASETYPEMAINT WHERE COMPINFO_ID IN (Select ID from ACH_COMPINFOMAINT where USERGROUP='MCILHENY') order by id desc;
SELECT /*insert*/ * FROM ACH_COMP_CLIENTNAME where USERGROUP='MCILHENY'  ;--
SELECT /*insert*/ * FROM ACH_COMP_CLIENTNAMEMAINT where USERGROUP='MCILHENY';--
SELECT /*insert*/ * FROM ach_comp_fileimport where COMPINFO_ID IN (select ID from ach_compinfo where usergroup = 'MCILHENY');
SELECT /*insert*/ * FROM ach_comp_fileimportMAINT where COMPINFO_ID IN (select ID from ACH_COMPINFOMAINT where usergroup = 'MCILHENY');

Select /*insert*/ * from rtgsusergroup Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from achusergroup Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from clmusergroup Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from transferusergroup Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from LOANUSERGROUP Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from STOPUSERGROUP Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from CMUSERGROUP Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from BPAYUSERGROUP Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from RISKUSERGROUP Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from ADMINUSERGROUP Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from PAYMODEUSERGROUP Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from RTPUSERGROUP Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from USERGROUPPRODUCTSETTINGS Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from USERGROUPRESTRICTIONS Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from LBE_USERGROUP_PREF Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from LBE_USERGROUP_LBXPERM Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from GIRUSERGROUP Where usergroup = 'MCILHENY' ;
SELECT /*insert*/ * FROM USERGROUPATTRIBUTES where Usergroup = 'MCILHENY';
SELECT /*insert*/ * FROM LEGACYSYSTEMIDS where Usergroup = 'MCILHENY';

select /*insert*/ * from RTGSUSERGROUPmaint Where usergroup = 'MCILHENY' ; 
Select /*insert*/ * from achusergroupmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from clmusergroupmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from transferusergroupmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from LOANUSERGROUPmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from STOPUSERGROUPmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from CMUSERGROUPmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from BPAYUSERGROUPmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from RISKUSERGROUPmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from ADMINUSERGROUPmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from PAYMODEUSERGROUPmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from RTPUSERGROUPmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from USERGROUPPRODUCTSETTINGSmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from USERGROUPRESTRICTIONSmaint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from LBE_USERGROUP_PREF_maint Where usergroup = 'MCILHENY' ;
Select /*insert*/ * from LBE_USERGROUP_LBXPERM_maint Where usergroup = 'MCILHENY' ;
SELECT /*insert*/ * FROM USERGROUPATTRIBUTESMAINT where Usergroup = 'MCILHENY';
SELECT /*insert*/ * FROM LEGACYSYSTEMIDSMAINT where Usergroup = 'MCILHENY';

select /*insert*/ * from GIRUSERGROUPPREF Where usergroup = 'MCILHENY' ;
select /*insert*/ * from GIRUSERGROUPPREFMAINT Where usergroup = 'MCILHENY' ;

select /*insert*/ * from RDCUSERGROUP Where usergroup = 'MCILHENY' ;
select /*insert*/ * from RDCUSERGROUPMAINT Where usergroup = 'MCILHENY' ;

select /*insert*/ * from IMAGECODES Where usergroup = 'MCILHENY' ;
select /*insert*/ * from IMAGECODESmaint Where usergroup = 'MCILHENY' ;

select /*insert*/ * from ACCOUNTRESTRICTIONS where Usergroup = 'MCILHENY' and accountnum like '%15004246106486%';
select /*insert*/ * from ACCOUNTRESTRICTIONSMAINT where Usergroup = 'MCILHENY' and accountnum like '%15004246106486%';
--select /*insert*/ * from TEMPLATEACCOUNTRESTRICTIONS where accountnum like '%15004246106486%';
select /*insert*/ * from STATS_PERMISSIONS_ACCOUNT where Usergroup = 'MCILHENY';
select /*insert*/ * from STATS_MARKETSEGMENT_ACCOUNT where Usergroup = 'MCILHENY';


