--Sandeep-2_DBIQ-E _Admin_CompanySetup_And_Corresponding_DBTables
SELECT * FROM USERGROUPMAINT  where enteredbytimestamp is not null ORDER BY ENTEREDBYTIMESTAMP DESC;
SELECT * FROM USERGROUP  where enteredbytimestamp is not null ORDER BY ENTEREDBYTIMESTAMP DESC; -- once approved the company
-- We do not have paymentscommonmaint tables for payments
-- We have mAINT for only reference data
select * from usergroupmaint where usergroup='TESTNBUG'; --companyId = Usergroup in db, For company usergroup is the main table
-- The bank code is actual bank and the corresponding account number -- When we using the account number always need to use bank code while testing ACCOUNTFILTER [bankcode-AccountNumber]
select * from usergroup where usergroup='TESTNBUG'; -- once approved the company

--To check entitlements at company level
    select * from entitlementspergroupmaint where usergroup='TESTNBUG';
    select * from entitlementspergroup where usergroup='TESTNBUG'; -- once approved the comapny
    select * from products where productcode='RTGS'; --typecode is the important one
    select * from types where typecode='FEDWIRE' AND productcode='RTGS' AND functioncode='INST'; -- We can find types of wire & Fuhnctions (INST means actual payment & TMPL means template)
    select * from applicationresources where productcode='RTGS' AND code='RTGS.type.fedwire'; --The actual strings that we can see on the UI
-- If we add "Wire - Federal Tax Wire" on entitlements
    select * from types where typecode='FEDTAX' AND productcode='RTGS' AND functioncode='INST';
    select * from applicationresources where productcode='RTGS' AND code='RTGS.type.fedtax';
-- If we add "ACH-Payrolle" on entitlements
    select * from types where typecode='BDACHP' AND productcode='USACH' AND functioncode='BATCH';
    select * from applicationresources where productcode='USACH' AND code='ACH.payroll';
-- If we add "E-Z Deposit" on entitlements --Added SSO just link to external app without any password
    select * from types where typecode='RDCTYPC' AND productcode='SSOOUT' AND functioncode='MAINT';
    select * from applicationresources where productcode='SSOOUT' AND code='type.RDCTYPC';
    
-- 'Primary Adminstration Contact info' will be stored in productsettings tables
    select * from rtgsusergroupmaint where usergroup='TESTNBUG';
    select * from rtgsusergroup where usergroup='TESTNBUG'; -- once approved the company
    select * from usergroupproductsettingsmaint where usergroup='TESTNBUG';
    select * from usergroupproductsettings where usergroup='TESTNBUG';-- once approved the company
    
-- Client Account settings:
    -- Real time services -> It will check current balances
    select * from enterpriseaccountmaint where usergroup='TESTNBUG'; --ACCOUNTFILTER [bankcode-AccountNumber]
    select * from enterpriseaccount where usergroup='TESTNBUG'; -- once approved the comapny
    select * from accountcodesmaint where usergroup='TESTNBUG'; --Entitlements for Accounts
    select * from accountcodes where usergroup='TESTNBUG'; -- once approved the comapny
    
--Bank setup and related tables
    select * from bank; -- Will find all bank related info like ABA,Account
    select * from intsortcode; -- will find branches for the bank
    
-- Tokencomments [Need to know]

--Sandeep-3
--Usercreation_Entitlements_Restrictions_CorrespondingDB
    --At company level:   
        select * from usergrouprestrictionsmaint where usergroup='TESTNBUG';
        select * from usergrouprestrictions where usergroup='TESTNBUG'; -- once approved the company
    --Account level & Account levels does not exceed comapany limits
    -- -> These will appliy only for APPROVE payments
    -- -> For individual there is no VALAUE_Date under DEPENDENCYCOLUMN2 but RESTRICTIONTYPE in ('GrpRTGSDayLimit','GrpWiresDayLimit') is based on value_Date.
        select * from accountrestrictionsmaint where usergroup='TESTNBUG';
        select * from accountrestrictions where usergroup='TESTNBUG'; -- once approved the company
        select * from restrictiontypes; -- reference table for restrictiontypes
        select * from applicationresources where code='restriction.batchLimit'; -- To find the definition of the description from above table
    -- LegacysystemsId [Reporting module]
        -- -> It is a specific ID that stored into the system that is used to load legacy reports. The cust may have report from external reports those reports will exports on DGB system
    -- User creation
        --> under 'Assign Payments Permiissions', the field "Must select beneficiaries from contact center" means 'Do you wnat to force the user to select the beneficiary from a list'
            --Step 1: Related to DEFINE USERS
            select * from usersmaint where usergroup='TESTNBUG';
            select * from users where usergroup='TESTNBUG';
            -- Step 2: Relatedto  SET PERMISSIONS
            select * from entitlementsmaint where usergroup='TESTNBUG'; -- We will not find userid and will get roleid here for the usergroup and userid is connected to roleid
            select * from rolesmaint where usergroup='TESTNBUG'; 
            select * from userrolesmaint where usergroup='TESTNBUG'; -- Role and userid will map here
                select * from entitlementsmaint where usergroup='TESTNBUG' and roleid in  (select roleid from userrolesmaint where usergroup='TESTNBUG' and userid='USER1'); -- BAsed on ENTRYMETHOD(0-Freeform,1-Template,2-Repetitive/Scheduled(Not use),3-Import) we need to find
                select * from entitlementsmaint where usergroup='TESTNBUG' and roleid in  (select roleid from userrolesmaint where usergroup='TESTNBUG' and userid='USER1') and typecode='FEDWIRE' and entrymethod=3; -- To get know user permission based on ACTIONMODE (Values MANAGE=DEL,INSERT,MODIFY)
                select * from applicationresources where code='restriction.batchLimit'; -- To find the definition of the description for the column TYPECODE
            -- Step 3: Related to ASSIGN ACCOUNTS 
                select * from dataentattrvalues where usergroup='TESTNBUG' and roleid in  (select roleid from userrolesmaint where usergroup='TESTNBUG' and userid='USER1');
            -- Step 3: Related to APPLY APPROVAL LIMITS
                select * from restrictions where usergroup='TESTNBUG' and roleid in  (select roleid from userrolesmaint where usergroup='TESTNBUG' and userid='USER1') and restrictiontype like '%Limit%'; -- Under wires (AUTO APPROVE, APPROVE OWN will be considered as a restrictions) and will find here based on column VALUE1
                
--Sandeep 4- 20210527 
                -- Client UI_WireCreation_Approval_Extraction_event_EventMonitor_MQ
            select * from users; -- To  get password
            update usersmaint set password='D7AAD510E04666D7878BB444FBF28A9839B9332C57EC92D03987BF85E0FA6588', salt='B13FD222ACAFAEC4641CF15CB435540A' where userid in ('USER2') and usergroup='TESTNBUG';
            update users set password='D7AAD510E04666D7878BB444FBF28A9839B9332C57EC92D03987BF85E0FA6588', salt='B13FD222ACAFAEC4641CF15CB435540A' where userid in ('USER2') and usergroup='TESTNBUG';
            commit;
            --If we get an error "Type Save Service Operation Failed Due to Action Error. Password is not allowed for SSO ID." please update password to NULL
            update usersmaint set password= NULL, salt= NULL where userid in ('USER2') and usergroup='TESTNBUG';
            update users set password=NULL, salt=NULL where userid in ('USER2') and usergroup='TESTNBUG';
            commit;
            
            --Related WIRE Payment
                select * from paymentscommon pc where usergroup='TESTNBUG'; -- For domestic-wire, the credit and debit amount will be same
                select r.* from paymentscommon pc join rtgs r on pc.tnum=r.tnum where pc.usergroup='TESTNBUG';-- To find beneficiary details
                select r.* from paymentscommon pc join rtgs r on pc.tnum=r.tnum join paymentsconsolidated pct on pc.tnum=pct.tnum where pc.usergroup='TESTNBUG'; -- To get above tables data in consolidated table
                select * from messagelog where traceid='985' order by 1 desc;-- tnum(1141833,1141832) 985 is the event number "MTS-Payment Extractor JDMP"
                select * from dgbweb.messagelog where message_id >= (select max(message_id) - 1000000 from dgbweb.messagelog) order by 1 desc;
                

-- Legal Administration [Need to know] -> separate column for this on DB
-- Strikes on users table, we did not check
-- Sample view & Bank confirmed response
-- Extract event & underlying view

        
--Sandeep 5- 20210531 - Mqlog_MQExplorer_MQQueueDefinitions_Events_JDMPConfigFiles_Mappers -- Only below will happen at HUB
    select * from events where scheduled=1;
    select * from mqlog where traceid = ANY (985,945) order by 1 desc; -- Log that conatins all messages that are written into a queue , 945-response loader & 985- extractor -- Always in EASTERN
            -- Take ACTIONTYPE read one and copy the MESSAGE and try to put TNUM number and PUT the message like "*ACK00000000001141832         1810050116968" on MQJ WIRE.OUTGOING.RESPONSE 
            -- To find exact queue name  for this queue"Q_FEDMTSEXTRACTQ" is need to download MQAdmin.scp file from winscp opt/bt/hub/DGB/jms/. There we will get all actual queues configured on MQJExplorer.
    select pc.* from paymentscommon pc join rtgs r on pc.tnum=r.tnum join paymentsconsolidated pct on pc.tnum=pct.tnum where pc.usergroup='TESTNBUG'; -- To get TNUM & status of the event & check the status Bank Received
    select r.* from paymentscommon pc join rtgs r on pc.tnum=r.tnum where pc.usergroup='TESTNBUG';
    select * from paymentscommon where tnum =1141832; -- To find the type of wire
    
    select * from messagelog where traceid='985' order by 1 desc;
    select * from events where id='985'; -- It contains all data related to events in the system ->  PROCESSINGMODE=1 means it will run once a day[Need to read for more info about EVENTS PROCESSINGMODE]
    select * from holidaycalendar; --when we setup event we can refer Holiday core data here
    select * from javaevents where code='MTSFEDS'; -- To find main class from the parameters and definition of the event 
        -- We will find JDMP file "jdmpConfig_MTSPaymentExtractor.xml" here
        -- Path to find "jdmpConfig_MTSPaymentExtractor.xml" -> /opt/bt/hub/DGB/classes/com/bottomline/webseries/hub/conf "
    select * from rtgscombinedview; -- Underlying view of the event to pickup payment-> As soon as you created a payment and approved it this event view pick thay payment up and that status of the payment will be relaesed.
        -- We will get mapper "mapper_MTSPaymentExtractorIn" from the file "jdmpConfig_MTSPaymentExtractor.xml" and will need to see the view
        --Scenario like -> We might get issues  where we have an approved payment but it's not being sent out. So, when that happens we need to come here . It's is same for all JDMP events. We have to come here find out what view it is and figure the JCODE and find the JDMP config file and find the mapper within that.
        -- We will find the actual queue name from the file "MQAdmin.scp" from Winscp ''
        -- For the extractor "jdmpConfig_MTSPaymentExtractor.xml", input is view "mapper_MTSPaymentExtractorIn" and for the ResponseLoadrer (945) "jdmpConfig_MTSResponseLoader.xml" , input is MQ
		--/opt/bt/hub/DGB5/classes/com/bottomline/webseries/hub/con
    select * from eventtracking; -- Event monitor will looks this table toget EVENTTRACKING definitions
    
--Sandeep 6 20210601 _ ACHCompany_ACHPaymenttypes_EntitleUsersWithACHComp
    -- Automatic clearing house (ACH) -> Slower process & less expansive compared to Wires
    -- Real Time Gross Settlements (RTGS)
    -- ACH - 2 types -> 
        -- Coorporate collection -> pulling money from account
        -- C
     select * from entitlementspergroupmaint where usergroup='TESTNBUG';
     -- NACHA Pass Through Settings -> We can import the file instead of typing in everything
     select * from achusergroupmaint where usergroup='TESTNBUG';
     select * from usergroupproductsettingsmaint where usergroup='TESTNBUG';
     -- To use ACH, you need to register and get a company Id(10 digit code). An identification code that is provided to the business and they have to use that to make payments.
     select * from achcompanylistmaint where usergroup='TESTNBUG'; -- To get all info related to Client ACH company
     select * from bank;
     select * from ach_comp_basetypemaint where compinfo_id= (select ID from achcompanylistmaint where usergroup='TESTNBUG'); -- Will find all paymenttypes that we entitled
     select * from ach_comp_clientnamemaint where basetype_id in (select id from ach_comp_basetypemaint where compinfo_id= (select ID from achcompanylistmaint where usergroup='TESTNBUG')); -- We can see the details displaying on UI here
     -- Limits:
     select * from usergrouprestrictionsmaint where usergroup='TESTNBUG'; -- Company level
     select * from accountrestrictionsmaint where usergroup='TESTNBUG'; -- account level
     -- Permissions
     select typecode from entitlements where usergroup='TESTNBUG' and roleid in (select roleid from userroles where usergroup='TESTNBUG' and userid='USER2')
     -- AND typecode='INST';
     --and entrymethod=0
     and productcode='USACH'  group by typecode
     ;
     
     select * from roles where  usergroup='TESTNBUG';
    select * from userroles where  usergroup='TESTNBUG';
    -- Assigned Accounts
    select * from dataentattrvaluesmaint where usergroup='TESTNBUG' and roleid in (select roleid from userroles where usergroup='TESTNBUG' and userid='USER2');
    select * from ach_comp_clientnamemaint where basetype_id in (select id from ach_comp_basetypemaint where compinfo_id= (select ID from achcompanylistmaint where usergroup='TESTNBUG'));
    --limits and autoapprove/ approve own
        select * from RESTRICTIONSMAINT where usergroup = 'TEAMINDUG' 
        and roleid in (select roleid from userroles where usergroup = 'TEAMINDUG' and userid = 'USER02')
        and restrictiontype like '%Limit%'






--John Rosky:
Able to reproduce the issue:

select tnum,last_action_time, transaction_amount, credit_amount, credit_currency, debit_amount, debit_currency, type_description
from DGBWEB.paymentscommon where usergroup = 'ATEXCOMP'
and last_action_time > '20-MAY-21 00:00:00'
order by last_action_time asc;

Using part of the Payments List View SQL to triage:

select pc.usergroup, pc.tnum, pcl.tnum, egr.tnum, pc.status, pc.type, pc.transaction_amount, pcl.cmb_transaction_amount, pc.value_date,
pcl.cmb_credit_amount, pcl.cmb_debit_amount, pc.*
FROM paymentscommon PC , PaymentsConsolidated PCL , RTGS EGR
WHERE PC.STATUS NOT IN ('MF')
AND PC.TNum = PCL.TNum
AND PC.TNum = EGR.TNum(+)
AND PC.usergroup = 'ATEXCOMP'
AND pc.approved_by_1 = 'CHAVEZDO'
AND TRUNC(PC.last_action_time) >= '22-MAY-21'
ORDER BY pc.last_action_time;

-- SQL for finding the bad templates. Most of which were updated after being migrated.
select ps.tnum, ps.usergroup, ps.type, t.template_code, pct.debit_account_number, pct.debit_amount from payschedule ps, rtgstemplate t, paymentscommontemplate pct
where ps.tnum = t.tnum
and t.tnum = pct.tnum
and pct.tnum = ps.tnum
and ps.modified_by is null
and pct.scheduled is not null
and pct.status='AP';
--issue is mudified_by is somehow getting set to null

payments not sending, real time calls failing. Believe it to be datapower. Cesar informed me as he needs to drop his kids off. On bridge with comerica now Twilio:

select * from DGBIPLAT.generated_otp order by create_date desc;

To merge the roleid to one:
[04:43 pm] Holland, Sue
    DBPS-29743
​[04:43 pm] Holland, Sue
    https://jira.bottomline.tech/browse/NH-140666


SF-07968811- SEV3 | Fulton Production | Marketing Information Request - Active Accounts in BOSS (September 2021)
SELECT DISTINCT  
P.GROUPNAME AS COMPANY_NAME,  
L.USERGROUP AS TAX_ID_NUMBER,  
E.ACCOUNTNUM AS ACCOUNT_NUMBER,  
e.accounttype as account_type  


from ( select distinct usergroup from dgbweb.userlog where ( trunc(logtime-(4/24)) > add_months(trunc(sysdate, 'month'), -1) ) ) l 

INNER JOIN DGBWEB.USERGROUP U ON U.USERGROUP=L.USERGROUP  
INNER JOIN DGBWEB.ENTERPRISEACCOUNT E ON E.USERGROUP=L.USERGROUP  
inner join dgbweb.usergroup p on p.usergroup = l.usergroup  
order by l.usergroup asc;


SF-07968795- SEV3 | Fulton Production | Marketing Information Request - Active User List (September 2021)
SELECT /*+ use_hash(P,U,L) */
DISTINCT
P.GROUPNAME AS COMPANY_NAME,
L.USERGROUP AS TAX_ID_NUMBER,
U.USERNAME AS USER_NAME,
L.USERID AS USER_ID,
u.emailaddress AS EMAIL_ADDRESS
FROM DGBWEB.USERLOG L, DGBWEB.USERGROUP P, DGBWEB.USERS U
WHERE L.LOGTIME > trunc(to_date('01-SEP-21', 'DD-MON-YY'))
AND L.LOGTIME < trunc(to_date('05-OCT-21', 'DD-MON-YY'))
AND L.USERGROUP = U.USERGROUP
AND P.USERGROUP = U.USERGROUP
AND L.USERID = U.USERID
ORDER BY L.USERGROUP;


===================
SELECT sid, to_char(start_time,'hh24:mi:ss') stime, 
message,( sofar/totalwork)* 100 percent 
FROM v$session_longops
WHERE sofar/totalwork < 1;

You can check the long-running queries details like % completed and remaining time using the below query:
 SELECT SID, SERIAL#, OPNAME, CONTEXT, SOFAR, 
 TOTALWORK,ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE" 
 FROM V$SESSION_LONGOPS 
 WHERE OPNAME NOT LIKE '%aggregate%' 
       AND TOTALWORK != 0 
       AND SOFAR <> TOTALWORK;
TO find out sql_id for the above sid:
SQL> select sql_id from v$session where sid='&SID';

To find sql text for the above sql_id:
SQL> select sql_fulltext from V$sql where sql_id='bgf07y9xn8grx';

To find wait event of the query for which it is waiting for:
SQL>select sql_id, state, last_call_et, event, program, osuser from v$session where sql_id='&sql_id';


Alert: SF_08084759 - Closing Ledger alerts triggering sporadically (https://jira.bottomline.tech/browse/DBPS-33490)
Here's the query I created in order to verify if the alert should have been fired on a certain day for this particular alert: 
SELECT * FROM vgirbalancedetail GIRB, users U WHERE GIRB.UserGroup = U.UserGroup AND girebs_dataentitlementcheck ( u.userid, girb.usergroup, message_id) = 1 
AND bai_code = '015' AND post_date >= TRUNC (to_date('2021-11-30','YYYY-MM-DD') - 4) AND posted_flag = 'P' AND ( Upper(GIRB.ACCOUNTFILTER) IN ('MNTBANK-9875772643') )
 AND GIRB.AMOUNT > 1 AND GIRB.UserGroup = '444468523' ;
 
 
 [DGB@us01vldgbhub042 AKA dgb-dev7-fi4423-hub01 ~]$ cd bin
[DGB@us01vldgbhub042 AKA dgb-dev7-fi4423-hub01 bin]$ ls -lrt
total 1742796
-rwxr-x--- 1 DGB DGB       5031 Oct  1 19:20 EventMonitor_launch4j.xml
-rwxr-x--- 1 DGB DGB       3310 Oct  1 19:20 EventMonitor.ico
-rwxr-x--- 1 DGB DGB      30720 Oct  1 19:20 EventMonitor.exe
-rwxr-x--- 1 DGB DGB     239616 Oct  1 19:20 EventManager_x64.exe
-rwxr-x--- 1 DGB DGB     112536 Oct  1 19:20 EventManager-sunos-sparc
-rwxr-x--- 1 DGB DGB     111027 Oct  1 19:20 EventManager-linux-x86_64
-rwxr-x--- 1 DGB DGB     204800 Oct  1 19:20 EventManager.exe
-rwxr-x--- 1 DGB DGB     281540 Oct  1 19:20 EventManager-aix-powerpc
-rw-r----- 1 DGB DGB        420 Oct  1 19:20 BT.png
-rw-r----- 1 DGB DGB       1242 Oct  1 19:26 UninstallService.bat
-rw-r----- 1 DGB DGB       1660 Oct  1 19:26 InstallService.bat
-rwxr-x--- 1 DGB DGB      16048 Oct  1 19:26 EMControl.sh
-rw-r----- 1 DGB DGB        214 Oct  1 19:26 EMControl.bat
-rw-r----- 1 DGB DGB          6 Oct  1 19:54 EventManager.pid
-rw-r----- 1 DGB DGB          0 Oct 26 03:19 mqjms.log.0.lck
-rw-r----- 1 DGB DGB          0 Oct 26 03:19 mqjms.log.0.1.lck
-rw-r----- 1 DGB DGB     269586 Oct 26 23:56 mqjms.log.2.1
-rw-r----- 1 DGB DGB     269586 Oct 26 23:58 mqjms.log.1.1
-rw-r----- 1 DGB DGB     111006 Oct 26 23:58 mqjms.log.0.1
-rw-r----- 1 DGB DGB     275519 Oct 27 03:58 mqjms.log.2
-rw-r----- 1 DGB DGB     275519 Oct 27 03:58 mqjms.log.1
-rw-r----- 1 DGB DGB     192240 Oct 27 03:59 mqjms.log.0
-rw------- 1 DGB DGB 1179875845 Nov 24 06:53 java_pid60314.hprof
-rw------- 1 DGB DGB  602028234 Nov 24 14:00 java_pid60309.hprof
-rw-r----- 1 DGB DGB     267502 Dec  4 21:08 bt_hub.log
[DGB@us01vldgbhub042 AKA dgb-dev7-fi4423-hub01 bin]$ ./EMControl.sh status
Bottomline Technologies Event Manager is running (59997).
[DGB@us01vldgbhub042 AKA dgb-dev7-fi4423-hub01 bin]$ ./EMControl.sh
Usage: ./EMControl.sh { console | start | stop | restart | status | dump }
[DGB@us01vldgbhub042 AKA dgb-dev7-fi4423-hub01 bin]$ ./EMControl.sh restart
Stopping Bottomline Technologies Event Manager...
Waiting for Bottomline Technologies Event Manager to exit...
Waiting for Bottomline Technologies Event Manager to exit...
Waiting for Bottomline Technologies Event Manager to exit...
Waiting for Bottomline Technologies Event Manager to exit...
Waiting for Bottomline Technologies Event Manager to exit...
Stopped Bottomline Technologies Event Manager.
Starting Bottomline Technologies Event Manager...
[DGB@us01vldgbhub042 AKA dgb-dev7-fi4423-hub01 bin]$ ./EMControl.sh status
Bottomline Technologies Event Manager is running (146335).


SELECT * FROM DGBWEB.MESSAGELOG WHERE MESSAGE_ID>(SELECT MAX(MESSAGE_ID)-10000 FROM DGBWEB.MESSAGELOG) and traceid in ('675')or trace like 'Event: 675%' order by logtime desc;

Check/ Image Triage:
• Find where the Check Image requests are sent to -> Typically they are sent to the IPLAT.
o Open /opt/bt/weblogic/user_projects/domains/domain01/bt_custom/DGBC/applicationContext.properties
o Look for checkManagement.getImage , depositSlip or similar properties.
o Confirm if they are pointing to IPLAT.
o It will also tell which adaptor it is using.
• Confirm the usergroup/ check number/ Time of request from Fi
• Request for HAR file from user.
• Before a Check Image Request, the user will have to perform a Check Inquiry first.
o Check Inquiries are recorded on INQUIRYAUDITLOG / Product - CM / Type - CMINQ
o This will typically have the Check Details as well.
• On image request, the IMAGEVIEWAUDIT records the imageid that is used in the request for the check image.
o The imageid will match the image id in the iplat log.
• Search for the appropriate iplat adaptor for the request and response.