
-- Please replace company : affected_UG and UserID : affected_UserID before run below script

ALTER SESSION SET CURRENT_SCHEMA = DGBWEB;

select /*insert*/ * from ACCOUNTPRODUCTSETTINGS  where Usergroup = '<usergroup>';
select /*insert*/ * from ACCOUNTPRODUCTSETTINGSMAINT  where Usergroup = '<usergroup>';

select /*insert*/ * from ACCTORCOMPBYACTIONXREFINST  where Usergroup = '<usergroup>' and userid = '<USERID>';
select /*insert*/ * from ACCTORCOMPBYACTIONXREFTMPL  where Usergroup = '<usergroup>' and userid = '<USERID>';

SELECT /*insert*/ * FROM usergroup where Usergroup = '<usergroup>';
SELECT /*insert*/ * FROM usergroupmaint where Usergroup = '<usergroup>';

SELECT /*insert*/ * FROM ENTITLEMENTSPERGROUP where Usergroup = '<usergroup>';
SELECT /*insert*/ * FROM ENTITLEMENTSPERGROUPMAINT where Usergroup = '<usergroup>';
 
SELECT /*insert*/ * FROM users where Usergroup = '<usergroup>' and userid in ('<USERID>');
SELECT /*insert*/ * FROM usersmaint where Usergroup = '<usergroup>' and userid in ('<USERID>');
 
select /*insert*/ * from userroles  where Usergroup = '<usergroup>' and userid in ('<USERID>');
select /*insert*/ * from userrolesmaint  where Usergroup = '<usergroup>' and userid in ('<USERID>');
                         
select /*insert*/ * from roles  where Usergroup = '<usergroup>';
select /*insert*/ * from rolesmaint  where Usergroup = '<usergroup>';

select /*insert*/ * from enterpriseaccount where Usergroup = '<usergroup>';
select /*insert*/ * from enterpriseaccountmaint where Usergroup = '<usergroup>';

select /*insert*/ * from USERPRODUCTSETTINGS where Usergroup = '<usergroup>';
select /*insert*/ * from USERPRODUCTSETTINGSMAINT where Usergroup = '<usergroup>';

select /*insert*/ * from restrictions  where Usergroup = '<usergroup>' and roleid in(select roleid from userroles where usergroup = '<usergroup>' and userid in ('<USERID>'));
select /*insert*/ * from restrictionsmaint  where Usergroup = '<usergroup>' and roleid in(select roleid from userroles where usergroup = '<usergroup>' and userid in ('<USERID>'));

select /*insert*/ * from dataentrestrictions  where Usergroup = '<usergroup>' and roleid in(select roleid from userroles where usergroup = '<usergroup>' and userid in ('<USERID>'));
select /*insert*/ * from dataentrestrictionsmaint  where Usergroup = '<usergroup>' and roleid in(select roleid from userroles where usergroup = '<usergroup>' and userid in ('<USERID>'));

select /*insert*/ * from entitlements  where Usergroup = '<usergroup>' and roleid in(select roleid from userroles where usergroup = '<usergroup>' and userid in ('<USERID>'));
select /*insert*/ * from entitlementsmaint  where Usergroup = '<usergroup>' and roleid in(select roleid from userroles where usergroup = '<usergroup>' and userid in ('<USERID>'));

select /*insert*/ * from dataentattrvalues  where Usergroup = '<usergroup>' and roleid in(select roleid from userroles where usergroup = '<usergroup>' and userid in ('<USERID>'));
select /*insert*/ * from dataentattrvaluesmaint  where Usergroup = '<usergroup>' and roleid in(select roleid from userroles where usergroup = '<usergroup>' and userid in ('<USERID>'));

SELECT /*insert*/ * FROM ACCOUNTCODES where Usergroup = '<usergroup>';
SELECT /*insert*/ * FROM ACCOUNTCODESMAINT where Usergroup = '<usergroup>';

WITH RECS AS (Select id  from ACH_COMPINFO where USERGROUP='<usergroup>')
(select ACH_COMPINFO_DEL from (select 'DELETE FROM ACH_COMPINFO WHERE ID = ''' ||R.id ||''';' AS ACH_COMPINFO_DEL  FROM RECS R));

WITH RECS AS (Select id  from ACH_COMPINFOMAINT where USERGROUP='<usergroup>')
(select ACH_COMPINFOMAINT_DEL from (select 'DELETE FROM ACH_COMPINFOMAINT WHERE ID = ''' ||R.id ||''';' AS ACH_COMPINFOMAINT_DEL  FROM RECS R));

WITH RECS AS (Select *  from ACH_COMP_BASETYPE where COMPINFO_ID IN (Select ID from ACH_COMPINFO where USERGROUP='<usergroup>'  ))
(select ACH_COMP_BASETYPE_DEL from (select 'DELETE FROM ACH_COMP_BASETYPE WHERE ID = ''' ||R.id ||''';' AS ACH_COMP_BASETYPE_DEL  FROM RECS R));

WITH RECS AS (Select id  from ACH_COMP_BASETYPEMAINT where COMPINFO_ID IN (Select ID from ACH_COMPINFO where USERGROUP='<usergroup>'  ))
(select ACH_COMP_BASETYPEMAINT_DEL from (select 'DELETE FROM ACH_COMP_BASETYPEMAINT WHERE ID = ''' ||R.id ||''';' AS ACH_COMP_BASETYPEMAINT_DEL  FROM RECS R));

WITH RECS AS (Select id  from ACH_COMP_CLIENTNAME where USERGROUP='<usergroup>')
(select ACH_COMP_CLIENTNAME_DEL from (select 'DELETE FROM ACH_COMP_CLIENTNAME WHERE ID = ''' ||R.id ||''';' AS ACH_COMP_CLIENTNAME_DEL  FROM RECS R));

WITH RECS AS (Select id  from ACH_COMP_CLIENTNAMEMAINT where USERGROUP='<usergroup>')
(select ACH_COMP_CLIENTNAMEMAINT_DEL from (select 'DELETE FROM ACH_COMP_CLIENTNAMEMAINT WHERE ID = ''' ||R.id ||''';' AS ACH_COMP_CLIENTNAMEMAINT_DEL  FROM RECS R));

WITH RECS AS (Select compinfo_id  from ACH_COMP_FILEIMPORT where COMPINFO_ID IN (select ID from ach_compinfo where usergroup = '<usergroup>'))
(select ACH_COMP_FILEIMPORT_DEL from (select 'DELETE FROM ACH_COMP_FILEIMPORT WHERE compinfo_id = ''' ||R.compinfo_id ||''';' AS ACH_COMP_FILEIMPORT_DEL  FROM RECS R));

WITH RECS AS (Select compinfo_id  from ACH_COMP_FILEIMPORTMAINT where COMPINFO_ID IN (select ID from ACH_COMPINFOMAINT where usergroup = '<usergroup>'))
(select ACH_COMP_FILEIMPORTMAINT_DEL from (select 'DELETE FROM ACH_COMP_FILEIMPORTMAINT WHERE compinfo_id = ''' ||R.compinfo_id ||''';' AS ACH_COMP_FILEIMPORTMAINT_DEL  FROM RECS R));

Select /*insert*/ *  from ACH_COMPINFO where USERGROUP='<usergroup>' ;
Select /*insert*/ * from ACH_COMPINFOMAINT where USERGROUP='<usergroup>' ;--
SELECT /*insert*/ * FROM ACH_COMP_BASETYPE WHERE COMPINFO_ID IN (Select ID from ACH_COMPINFO where USERGROUP='<usergroup>'  ) order by id;
SELECT /*insert*/  * FROM ACH_COMP_BASETYPEMAINT WHERE COMPINFO_ID IN (Select ID from ACH_COMPINFOMAINT where USERGROUP='<usergroup>') order by id desc;
SELECT /*insert*/ * FROM ACH_COMP_CLIENTNAME where USERGROUP='<usergroup>'  ;--
SELECT /*insert*/ * FROM ACH_COMP_CLIENTNAMEMAINT where USERGROUP='<usergroup>';--
SELECT /*insert*/ * FROM ach_comp_fileimport where COMPINFO_ID IN (select ID from ach_compinfo where usergroup = '<usergroup>');
SELECT /*insert*/ * FROM ach_comp_fileimportMAINT where COMPINFO_ID IN (select ID from ACH_COMPINFOMAINT where usergroup = '<usergroup>');

Select /*insert*/ * from rtgsusergroup Where usergroup = '<usergroup>' ;
Select /*insert*/ * from achusergroup Where usergroup = '<usergroup>' ;
Select /*insert*/ * from clmusergroup Where usergroup = '<usergroup>' ;
Select /*insert*/ * from transferusergroup Where usergroup = '<usergroup>' ;
Select /*insert*/ * from LOANUSERGROUP Where usergroup = '<usergroup>' ;
Select /*insert*/ * from STOPUSERGROUP Where usergroup = '<usergroup>' ;
Select /*insert*/ * from CMUSERGROUP Where usergroup = '<usergroup>' ;
Select /*insert*/ * from BPAYUSERGROUP Where usergroup = '<usergroup>' ;
Select /*insert*/ * from RISKUSERGROUP Where usergroup = '<usergroup>' ;
Select /*insert*/ * from ADMINUSERGROUP Where usergroup = '<usergroup>' ;
Select /*insert*/ * from PAYMODEUSERGROUP Where usergroup = '<usergroup>' ;
Select /*insert*/ * from RTPUSERGROUP Where usergroup = '<usergroup>' ;
Select /*insert*/ * from USERGROUPPRODUCTSETTINGS Where usergroup = '<usergroup>' ;
Select /*insert*/ * from USERGROUPRESTRICTIONS Where usergroup = '<usergroup>' ;
Select /*insert*/ * from LBE_USERGROUP_PREF Where usergroup = '<usergroup>' ;
Select /*insert*/ * from LBE_USERGROUP_LBXPERM Where usergroup = '<usergroup>' ;
Select /*insert*/ * from GIRUSERGROUP Where usergroup = '<usergroup>' ;
SELECT /*insert*/ * FROM USERGROUPATTRIBUTES where Usergroup = '<usergroup>';
SELECT /*insert*/ * FROM LEGACYSYSTEMIDS where Usergroup = '<usergroup>';

select /*insert*/ * from RTGSUSERGROUPmaint Where usergroup = '<usergroup>' ; 
Select /*insert*/ * from achusergroupmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from clmusergroupmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from transferusergroupmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from LOANUSERGROUPmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from STOPUSERGROUPmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from CMUSERGROUPmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from BPAYUSERGROUPmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from RISKUSERGROUPmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from ADMINUSERGROUPmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from PAYMODEUSERGROUPmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from RTPUSERGROUPmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from USERGROUPPRODUCTSETTINGSmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from USERGROUPRESTRICTIONSmaint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from LBE_USERGROUP_PREF_maint Where usergroup = '<usergroup>' ;
Select /*insert*/ * from LBE_USERGROUP_LBXPERM_maint Where usergroup = '<usergroup>' ;
SELECT /*insert*/ * FROM USERGROUPATTRIBUTESMAINT where Usergroup = '<usergroup>';
SELECT /*insert*/ * FROM LEGACYSYSTEMIDSMAINT where Usergroup = '<usergroup>';

select /*insert*/ * from GIRUSERGROUPPREF Where usergroup = '<usergroup>' ;
select /*insert*/ * from GIRUSERGROUPPREFMAINT Where usergroup = '<usergroup>' ;

select /*insert*/ * from RDCUSERGROUP Where usergroup = '<usergroup>' ;
select /*insert*/ * from RDCUSERGROUPMAINT Where usergroup = '<usergroup>' ;

select /*insert*/ * from IMAGECODES Where usergroup = '<usergroup>' ;
select /*insert*/ * from IMAGECODESmaint Where usergroup = '<usergroup>' ;

select /*insert*/ * from ACCOUNTRESTRICTIONS where Usergroup = '<usergroup>' and accountnum like '%15004246106486%';
select /*insert*/ * from ACCOUNTRESTRICTIONSMAINT where Usergroup = '<usergroup>' and accountnum like '%15004246106486%';
--select /*insert*/ * from TEMPLATEACCOUNTRESTRICTIONS where accountnum like '%15004246106486%';
select /*insert*/ * from STATS_PERMISSIONS_ACCOUNT where Usergroup = '<usergroup>';
select /*insert*/ * from STATS_MARKETSEGMENT_ACCOUNT where Usergroup = '<usergroup>';


