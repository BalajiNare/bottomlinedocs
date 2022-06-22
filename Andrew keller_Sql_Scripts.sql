[02:45 am] Keller, Andrew
    
-CUT off time is 4pm as reported by customer.
--She can see payment but the customer cannot (as it is in IC status).
--Company ID experiencing the issue: 461964878
--Last successful attempt: was for $274,387.48 Entered on 6/29. This worked in May
-- TNUM 2869125
-- last_action_time 29-JUN-21 15:43:02
-- CREDIT_CURRENCY = BGN
-- DEBIT_CURRENCY = USD
-- ENTERED_BY = ANCILLARE5
select PC.TNUM, PC.status,PC.transaction_amount, PC.ENTERED_BY,PC.Approved_by_1,PC.approved_timestamp_1,
PC.credit_currency, PC.debit_currency, pc.modified_by, pc.modified_by_name,
pc.last_action_time,pc.modified_timestamp,pc.cutoff_time,pc.effectivedate,
pc.usergroup, PC.type,PC.subtype,PC.product,PC.template_max_currency, PC.value_date,pc.companyname,
PC.* from dgbweb.paymentscommon PC where 
pc.type =  'INTL'
and pc.usergroup = '461964878'
and PC.CREDIT_CURRENCY = 'BGN'
and PC.ENTERED_BY = 'ANCILLARE5'
--and PC.tnum = '2869125'
--PC.transaction_amount = '274387.48'
order by PC.tnum desc
;


-- "BOTH" seems like the value to use
select * from DGBWEB.currency 
where tradable is not null
order by code asc;
--where code = 'BGN';



-- last_action_time of tnum in dgbweb.paymentscommon was '29-JUN-21 15:43:02' EST
-- so search dgbweb.messagelog
SELECT MESSAGE_ID,userid, LOGTIME,--SOURCE, SEVERITY, LOGTIME,
TO_CHAR((LOGTIME - INTERVAL '4' HOUR), 'DD-Mon-YYYY HH:MI:SS AM') "logtimeEST",
traceinfo,message,traceid  FROM DGBWEB.MESSAGELOG
WHERE MESSAGE_ID>(SELECT MAX(MESSAGE_ID)-900000 FROM DGBWEB.MESSAGELOG)
and source = 'APP'
and USERID = 'ANCILLARE5'
and traceinfo not like '%jasperReports/%'
and traceinfo not like '%outboundSSO/%'
-- adjust the time to 11:43:02 in messagelog
-- big window to start 
--and LOGTIME BETWEEN '29-JUN-21 08:00:00' AND '29-JUN-21 20:00:00'
-- adjusted time window
and LOGTIME BETWEEN '29-JUN-21 15:30:00' AND '29-JUN-21 15:59:00'
and message not like '%HTTP response code: 304.'
and message not like '%HTTP response code: 429.'
and message not like 'Warning - UserGroup Value replaced with the Users%'
order by message_id ASC;


-- last_action_time of tnum in dgbweb.paymentscommon was '29-JUN-21 15:43:02' EST
-- Error from Fulton (that user 'ANCILLARE5') at 29-Jun-2021 11:33:36 AM EST
-- /dgb/rest/rate/getIndicativeRate java.sql.SQLException: Missing IN or OUT parameter at index:: 3
-- Params: [RTGS, INST]
-- of course this fails as typecode isn't passed in
Select * from dgbweb.CustomTypeProcessors where ProductCode = 'RTGS' and FunctionCode = 'INST' and TypeCode = ?



-- Should have been INTL for last param TypeCode = 'INTL'
-- Params: [RTGS, INST, INTL]
Select * from dgbweb.CustomTypeProcessors where ProductCode = 'RTGS' and FunctionCode = 'INST' and TypeCode = 'INTL';






​[02:47 am] Keller, Andrew
    The sqls were to find the payment and current info about it based on what we knew (amount, date, type etc) and then based on when it was last touched perhaps we could find helpful info in dgbweb.messagelog (one you wade thru all the noise and focus on the right time frame - once adjusted for EST from DST)
<https://teams.microsoft.com/l/message/19:11ecf2773c124d16be7ac2d022f8d7a1@thread.tacv2/1625087723778?tenantId=e89cb837-f118-407d-98fe-4c32b11a8ab9&amp;groupId=2dc91476-fb11-411d-a489-356ebed1e5f7&amp;parentMessageId=1625087706991&amp;teamName=Banking Production Support&amp;channelName=General&amp;createdTime=1625087723778>



I was working on some SQL with John R and Will comparing and contrasting dgbweb.messagelog vs dgbweb.mqlog queries and performance. Here is what we came up with. 

-- Classic dgbweb.messagelog select (- 100,000 rows of the PK message_id)
-- but dgbweb.messagelog is partitioned by LOGTIME
-- from Andrew K 7/6/21
-- 39,279,736 rows in CNB as of 7/6/21
SELECT ML.MESSAGE_ID, ML.LOGTIME, -- ML.LOGTIME is GMT and needs EST-DST conv
TO_CHAR((ML.LOGTIME - INTERVAL '4' HOUR), 'DD-Mon-YYYY HH:MI:SS AM') "logtimeEST-4",ML.traceid,
ML.*  FROM DGBWEB.MESSAGELOG ML
WHERE ML.MESSAGE_ID>(SELECT MAX(MESSAGE_ID)-200000 FROM DGBWEB.MESSAGELOG)
-- adjust between if needed for GMT below,  0800-100hrs EST
-- and ML.logtime between '06-Jul-2021 12:00:00' and '06-Jul-2021 14:00:00'
order by ML.message_id DESC;

 


 

-- Classic dgbweb.mqlog select (- 100,000 rows of the PK)
-- but dgbweb.mqlog is NOT partitioned by actiontimestamp at this time
-- Andrew K 7/6/21
-- this SQL used PK (by index row id) but is still a bit costly with 
-- "RANGE SCAN DESCENDING" on the actiontimestamp (already EST?) col but much better than 
-- if you didn't first use the id col (PK) in where clause
-- this would be faster if we created an index on actiontimestamp col
-- or used actiontimestamp col as a partition key (which would make it a partition index)
-- select count(*) from DGBWEB.mqlog; -- 9,624,822 rows in CNB as of 7/6/21
SELECT MQ.ID,mq.actiontimestamp,MQ.*
-- actiontimestamp is already EST btw (least for CNB)
FROM DGBWEB.mqlog MQ
-- adjust the 100,000 if you want to go back farther in time
WHERE ID>(SELECT MAX(ID)-100000 FROM DGBWEB.MQLOG)
--  after you used the PK above now you can add actiontimestamp to where clause
-- add between 7/6/21 from 0930 to 1000hrs EST if needed but does slow things down a bit (5+ seconds)
and mq.actiontimestamp between '06-JUL-21 09:30:00' and '06-JUL-21 10:00:00'
-- or better yet ditch actiontimestamp col and do a range of the PK ID
-- like this and it won't matter how far back you go with ID > <
--MQ.ID >= '6000000' and MQ.ID <= '6100000'
order by MQ.id DESC;


-- Helpful SQL on GV$SESSION_LONGOPS ( any sql >= 7 seconds) that all our "named" users have access to
-- This sql will show currently "Executing..." SQLs at the top of the output
-- Then followed by any non DGB schema users like your named user you are logged into SQL developer with
-- Then ordered by execution time highest to lowest
-- Andrew Keller 7/6/21 v1.00
SELECT L1.sid ||':'|| L1.serial# "session-sid:serial#",L1.username, L1.sql_id, L1.inst_id "rac_node",
L1.SQL_PLAN_OPTIONS ||':'|| L1.opname ||' '|| L1.target "operationalInfoAndTarget"
,L1.sofar "workSoFar", L1.totalwork,
DECODE(L1.totalwork-L1.sofar,0,'Completed','Executing...') as "sql_status",
L1.elapsed_seconds,to_char(L1.elapsed_seconds/60,'99999.99') "orELAPSED_MINUTES", L1.TIME_REMAINING "estSecondsRemaining",
L1.start_time, L1.last_update_time
FROM GV$SESSION_LONGOPS L1,
 (-- sid, serial# makes for unique session executing sql
  SELECT distinct sid, serial#
  FROM GV$SESSION_LONGOPS
  ) SQ1
WHERE ( SQ1.sid = L1.sid and SQ1.serial# = L1.serial#)
-- add this next line in if you just want stuff executed against DGBWEB. schema by any user
-- and L1.target like 'DGBWEB.%'
order by DECODE(L1.totalwork-L1.sofar,0,'Completed','Executing...') desc,
case when (L1.username not in ('DGBWEB','DGBADMIN','DGBIPLAT','SYS' )) then L1.username end asc,
L1.elapsed_seconds desc, 1;

[07:20 pm] Keller, Andrew
    Regarding date/time output formatting to get correct output based on your timezone
​[07:20 pm] Keller, Andrew
    
-- From Andrew Keller and Will Allen
-- 7/21/21
-- SQL to show how date/time columns are stored in DB and how to 
-- convert things to EST for example while monitoring or working a ticket
-- Oracle stores dates (included the time) in UTC then ouputs things based on 
-- the timezone of the DB server instance
-- Here is an example of something that runs all the time and would have a current time to experiment with
-- Like Nacha pre-extract event 703 that runs every minute
-- so I put that at the top output. 
-- The event E.TIMEZONEID column is configued in the event for scheduling purposes (start,stop times etc)
--
select E.ID, E.NAME,E.TIMEZONEID "eventTimeZoneForScheduling",E.lastsuccess "lastsuccessAsStored/Displayed",
TO_CHAR((E.lastsuccess - INTERVAL '4' HOUR), 'DD-Mon-YYYY HH:MI:SS AM') "lastsuccessConvertedEST", 
DBTIMEZONE "oracleDBTIMEZONE",sysdate "oracleSysdate",E.* 
from dgbweb.events E 
where E.scheduled = 1
and E.lastsuccess is not null
ORDER BY decode(E.ID,703,1),E.lastsuccess desc


-- and for output date formatting (results of your select) you can do the follow
-- set NLS_DATE_FORMAT for your session which will output all dates that way
-- You can also set sql developer preferences to do the same thing btw
-- like chaning DD-MON-YYYY to MM/DD/YY for your session
alter SESSION set NLS_DATE_FORMAT = 'MM/DD/YY HH24:MI:SS';


-- Alter session set time_zone has no effect on the event SQL output above
-- You can clearly see what the DB server instance is set to and what
-- your session to that server is set to
-- ALTER SESSION SET TIME_ZONE is not useful in this case
SELECT DBTIMEZONE, SESSIONTIMEZONE, CURRENT_TIMESTAMP from dual;
       -04:00       -07:00            21-JUL-21   04.11.35.285218000 PM -07:00


ALTER SESSION SET TIME_ZONE = '-07:00'; 


-- Now my sql dev seesion is: -07:00
SELECT DBTIMEZONE, SESSIONTIMEZONE, CURRENT_TIMESTAMP from dual;
       -04:00       -07:00            21-JUL-21   04.11.35.285218000 PM -07:00


-- put it back to what it was for your session (sql developer)
ALTER SESSION SET TIME_ZONE = '-04:00';


SELECT DBTIMEZONE, SESSIONTIMEZONE, CURRENT_TIMESTAMP from dual;
       -04:00       -04:00           21-JUL-21 07.13.12.017072000 PM -04:00




[Yesterday 11:32 pm] Keller, Andrew
    SQL of the Day?.... This one to help for those long running BAI current day PagerDuty alerts (namely for Frost but others like BBVA too)
​[Yesterday 11:32 pm] Keller, Andrew
   -- Simple Sql to find BAI Current Day (event 43) start and stop info
-- Andrew Keller 7/29/21 v 1.100
-- start and completed times related to PagerDuty
-- alerts saying they are long running (which is > 30 minutes?)
-- 99.9% of the time they are just long running for one reason or another
-- Like it is a bigger file and/or the system is busier than normal
-- or shared resources are being overly consumed
-- and these reasons are common and haven't yet been addressed/mitigatd
-- for some customers. Namely Frost and sometimes BBVA
-- As long as the files complete within the hour and they don't pile up
-- Which you can/should check out and for event 43 Bai Current Day
-- is /opt/bt/hub/bankdata/load/bai/ on the HUB01 VM's NFS "bankdata"
-- mount point shared with HUB02 in case of failover
SELECT MESSAGE_ID, TRACEID,SEVERITY,
-- use 5 for DST
TO_CHAR((LOGTIME - INTERVAL '4' HOUR), 'DD-Mon-YYYY HH:MI:SS AM') "logtimeEST",
MESSAGE,
TRACEINFO FROM DGBWEB.MESSAGELOG
WHERE MESSAGE_ID>(SELECT MAX(MESSAGE_ID)-100000 FROM DGBWEB.MESSAGELOG)
and traceid in ('43')
and source = 'HUB'
-- comment this out for all messagelog activity for event 43
and (message like 'Starting BAI load %' or message like 'Completed BAI load %')
order by message_id DESC;


SQL for finding the bad templates. Most of which were updated after being migrated.



select ps.tnum, ps.usergroup, ps.type, t.template_code, pct.debit_account_number, pct.debit_amount from payschedule ps, rtgstemplate t, paymentscommontemplate pct
where ps.tnum = t.tnum
and t.tnum = pct.tnum
and pct.tnum = ps.tnum
and ps.modified_by is null
and pct.scheduled is not null
and pct.status='AP';

issue is mudified_by is somehow getting set to null



--I can find a sql that shows the number of scheduled payments that went out today etc.
--join the 4 tables 
SELECT
P.tnum, P.type, P.status, pcdt.cmb_template_desciption "sched_template_used"
-- p.entrymethod, p.createdfrom
, P.transaction_amount


[01/10 07:26 pm] Keller, Andrew
    
-- Partition SQLs
-- Andrew Keller 10/1/21
-- get info on all partitions for DGBWEB schema
-- things like partition type: daily or every 14 days etc
-- you normally see: GIRBALANCEDETAILBASE, GIRTRANSACTIONDETAILBASE and MESSAGELOG tables
select AP.owner, AP.table_name,AP.interval,AP.* from ALL_PART_TABLES AP where OWNER like '%WEB%';


-- Get list of partitions and their info
-- ordered by partition_position 
-- latest partition has the highest partition_position value
-- which in this case would be top row of the sql output
SELECT P.PARTITION_NAME,P.partition_position,P.num_rows,P.high_value,
P.*
FROM ALL_TAB_PARTITIONS P
WHERE TABLE_OWNER = 'DGBWEB'
AND TABLE_NAME = 'MESSAGELOG'
order by P.partition_position desc;


-- Best SQL to latest/current partition name for dgbweb.messagelog
select A.owner,A.object_name,A.subobject_name "currentPartitionName",
to_char(A.created,'MM-DD-YY HH24:MI:SS') "dateCreated"
--, A.*
from all_objects A
where A.owner = 'DGBWEB'
and A.object_name = 'MESSAGELOG' 
and A.object_type='TABLE PARTITION'
and A.created = (select MAX(B.created) from all_objects B where B.owner = A.owner and B.object_name = A.object_name and B.object_type = A.object_type)
ORDER BY A.created desc;



-- latest partition for 10/1/21 is SYS_P22164 which was created on 09-30-21 20:00:00
select * from dgbweb.messagelog
partition(SYS_P22164) 
--where lower(message) like '%exception in postproc run%'
--and traceid = '45'
order by message_id desc;


-- partition from 9/30/21
select * from dgbweb.messagelog
partition(SYS_P22134) 
--where lower(message) like '%exception in postproc run%'
--and traceid = '45'
order by message_id desc;

Macing system:
select * from web.macexcludes;
select * from web.producttables;

Need to discuss with sue regarding MACING




https://www.sqlshack.com/different-ways-to-sql-delete-duplicate-rows-from-a-sql-table/

Here are the sqls for the lower cost and perhaps handier version of the dgbweb.messagelog queries we use.
I know it is a bit cryptic but if you try them out and use the F10 (execution plan) in SQL Developer I think you will be able to figure out what works best. 
I tried to give examples or what is best when the dgbweb.messagelog table is partitioned -use LOGTIME column with "between keyword" (which is most envs) 
and when it is not (then use the message_id PK) or you could try using both LOGTIME and message_id.  
 

-- Andrew Keller 11-11-21
-- Sql based on the improved dgbweb.messagelog queries so DB perf doesn't suffer by searching messagelog via full table scans like it used to
-- but this time to limit the query to the smallest number of partitions based on partition key
-- and in this example only query for rows since midnight UTC (-5 EST-DST at this time -4 EST) to the current db time of db sysdate value
-- You can also search back N days too by a quick tweak for general realtime troubleshooting. 
-- I'm sure we could also tweak that inner select further for the last N hour(s) 
-- of the current day since midnight too
-- messagelog is now partitioned daily by LOGTIME for all hosted customers (the Primary Key index across all partitions is still the message_id column)
-- as messagelog table is given a new partition each day
-- that way you don't have to guess on what to put in for the minus value of that inner select (-50000):
-- which may be too little (not finding what you are looking for), depending over verboseness/activity 
-- or too much (causing you to find a re-alert on something again)
-- traditionally we used: WHERE MESSAGE_ID>(SELECT MAX(MESSAGE_ID)-50000 FROM DGBWEB.MESSAGELOG)
select M.message_id, M.logtime,severity,M.source,TO_CHAR(( M.LOGTIME - INTERVAL '5' HOUR), 'DD-MON-YY HH24:MI:SS') "dateEST-DST", M.traceid, M.message
--, sysdate
--, M.*
FROM DGBWEB.MESSAGELOG M
-- between midnight UTC and now UTC
--(SELECT MIN(MESSAGE_ID) FROM DGBWEB.MESSAGELOG where LOGTIME BETWEEN to_date(trunc(sysdate),'DD-MON-YY HH24:MI:SS') AND to_date(sysdate,'DD-MON-YY HH24:MI:SS') )
-- between 7 days ago and now for testing (just remove the -7) to get since midnight today for monitor
--WHERE M.MESSAGE_ID > (SELECT MIN(MESSAGE_ID) FROM DGBWEB.MESSAGELOG where LOGTIME BETWEEN to_date(trunc(sysdate-7),'DD-MON-YY HH24:MI:SS') AND to_date(sysdate-7,'DD-MON-YY HH24:MI:SS') )
-- since midnight last night. You can always test this inner select by itself to get the massage_id value and then review the time of that row
-- DB cost 23,636
-- WHERE  M.MESSAGE_ID > (SELECT MIN(MESSAGE_ID) FROM DGBWEB.MESSAGELOG where LOGTIME BETWEEN to_date(trunc(sysdate),'DD-MON-YY HH24:MI:SS') AND to_date(sysdate,'DD-MON-YY HH24:MI:SS') )
-- DB cost 275 This example, using the partition key LOGTIME with between is even lower  than above PK message_id
WHERE  M.LOGTIME BETWEEN to_date(trunc(sysdate),'DD-MON-YY HH24:MI:SS') AND to_date(sysdate,'DD-MON-YY HH24:MI:SS')
-- adjust these additional filters as needed
--and M.severity = 'ERROR'
--and M.source = 'HUB'
order by M.message_id desc;

 

-- testing the result of that inner select by iteslf to get the starting point of the query > message_id
-- if using: WHERE  M.MESSAGE_ID > (SELECT MIN(MESSAGE_ID) FROM DGBWEB.MESSAGELOG where LOGTIME BETWEEN to_date(trunc(sysdate),'DD-MON-YY HH24:MI:SS') AND to_date(sysdate,'DD-MON-YY HH24:MI:SS') )
-- 90170535    11-NOV-21 00:00:00
-- select * from dgbweb.messagelog where message_id = '90170535';

set serveroutput on;
DECLARE
    lv_first PLS_INTEGER;
    lv_mid PLS_INTEGER;
    lv_last PLS_INTEGER;
    lv_flag BOOLEAN;
    lv_actiontimestamp mqlog.actiontimestamp%TYPE;
    lv_query mqlog.actiontimestamp%TYPE;

BEGIN
    lv_query := '20-AUG-21 00:00:00';
    select min(ID) into lv_first from mqlog;
    select max(ID) into lv_last from mqlog;
    lv_flag := FALSE;

    WHILE(lv_first <= lv_last) LOOP
        BEGIN
            lv_mid := (lv_first + lv_last) / 2;
            select actiontimestamp into lv_actiontimestamp from mqlog where ID = lv_mid;
            IF(lv_actiontimestamp = lv_query)
            THEN
                dbms_output.put('actiontimestamp ' || lv_query || ' found @ ID ');
                dbms_output.put_line(lv_mid);
                lv_flag := TRUE;
                EXIT;
            END IF;

            IF(lv_actiontimestamp > lv_query)
            THEN
                lv_last := lv_mid -1;
            ELSE
                lv_first := lv_mid + 1;
            END IF;
        END;
        --dbms_output.put_line(lv_mid);
    END LOOP;

    IF(NOT lv_flag)
    THEN
        dbms_output.put_line('exact time not found, nearest match is ' || lv_mid);
    END IF;

END;

Here are the sqls to find DGBA or DGBC user logins between two date/times:
 
-- Andrew Keller 12/13/21
-- Find DGBA login date/time via dgbadmin.userlog table
select userid,LOGTIME "logtimeUTC",TO_CHAR((LOGTIME - INTERVAL '5' HOUR), 'DD-Mon-YYYY HH:MI:SS') "logtimeEST+5" from dgbadmin.userlog
-- For example: 2300hrs on 12/6/21 to 2345hrs on 12/6/21
where LOGTIME BETWEEN to_date('06-DEC-21 23:00:00','DD-MON-YY HH24:MI:SS') AND to_date('06-DEC-21 23:45:00','DD-MON-YY HH24:MI:SS')
order by LOGTIME asc ;

 -- Andrew Keller 12/13/21
 -- Find DGBC login date/time via dgbweb.userlog table
 select userid,LOGTIME "logtimeUTC",TO_CHAR((LOGTIME - INTERVAL '5' HOUR), 'DD-Mon-YYYY HH:MI:SS AM') "logtimeEST+5" from dgbweb.userlog
 -- Find logins over the last 5 minutes
 where LOGTIME BETWEEN to_date(sysdate - INTERVAL '5' MINUTE,'DD-MON-YY HH24:MI:SS') AND to_date(sysdate,'DD-MON-YY HH24:MI:SS')
 order by LOGTIME desc ;
 
Here are the sqls Ankita and I were working on for on-prem M&T to troubleshoot some Alert issues.  Some fun and helpful stuff in the sqls. Save them for an "alert" raining/snowy day. 
 

-- SQL #1 to help find recent Incoming Wire alerts that were recently created or changed
-- in the last N days - currently set to last 5 days
-- For M&T ticket 08148354
-- Andrew Keller 1/7/22
select A.alertid, A.alertname,A.subject,A.product, A.type,A.alertclass,A.usergroup, A.userid,A.last_executed_time,A.entered_timestamp,A.changetime,A.sqlstatement
, A.* 
from dgbweb.alerts A 
where upper(A.alertname) like '%INCOMING WIRE%' 
-- filter it down event further if possible based on output
--and A.product = 'GIR'
--and A.type = 'WIREALRT'
--and A.usergroup in ('BVBITEC')
-- and A.userid in('BVBITEC1')
--and A.alertclass = 'LOAD'
and ( trunc(A.last_executed_time) >= trunc(sysdate-5) or A.entered_timestamp >= trunc(sysdate-5) or A.changetime >= trunc(sysdate-5) )
order by A.alertid desc;

 


-- SQL #2 to help find recent Incoming Wire alert emails that were recently created
-- in the last N days - currently set to last 5 days
-- For M&T ticket 08148354
-- Andrew Keller 1/7/22
select E.id, E.alertid, E.subject,E.enteredtimestamp, E.status "paymentStatus", E.recipient, E.usergroup
--, E.* 
from dgbweb.emailmessage E 
where ( E.enteredtimestamp >= trunc(sysdate-5) )
and upper(E.subject) like '%INCOMING WIRE%' 
--and E.usergroup in ('BDEAMCN')
order by E.id desc;

 

-- SQL #3 to help find recent Incoming Wire alert emails that were recently created but count and group them 
-- in the last N days - currently set to last 5 days
-- For M&T ticket 08148354
-- Andrew Keller 1/7/22
select E.alertid, E.subject,trunc(E.enteredtimestamp) "enteredtimestamp", E.status "paymentStatus", E.usergroup,count(*) "count"
--, E.* 
from dgbweb.emailmessage E 
where ( E.enteredtimestamp >= trunc(sysdate-5) )
and upper(E.subject) like '%INCOMING WIRE%' 
-- filter further if needed
--and E.usergroup in ('BDEAMCN')
--and E.alertid in ('4632')
group by E.alertid,  E.subject,trunc(E.enteredtimestamp),E.alerttype, E.status, E.usergroup
order by 3;

 


-- SQL #4 to help find recent Incoming Wire alert emails that were recently created but count and group them by Subject
-- in the last N days - currently set to last 5 days
-- For M&T ticket 08148354
-- Andrew Keller 1/7/22
select E.subject,trunc(E.enteredtimestamp) "enteredtimestamp", E.status "paymentStatus",count(*) "count"
from dgbweb.emailmessage E 
where ( E.enteredtimestamp >= trunc(sysdate-5) )
and upper(E.subject) like '%INCOMING WIRE%' 
-- filter further if needed
--and E.usergroup in ('BDEAMCN')
--and E.alertid in ('4632')
group by E.subject,trunc(E.enteredtimestamp),E.alerttype, E.status
order by 2;

 

-- SQL #5 to help find recent Incoming Wire alert emails that were recently created and sent out via iPlat email_alert table
-- joining the web.alerts table
-- in the last N days - currently set to last 5 days
-- For M&T ticket 08148354
-- Andrew Keller 1/7/22
select EA.id "iplatID", EA.corelation_id "iPlatAlertID", a.alertname, a.alertid "alertsID"
,EA.alert_type,EA.status,EA.status_message,EA.status_date,EA.user_group, EA.user_name,EA.subject
--,EA.*
from dgbiplat.email_alert  EA, dgbweb.alerts A
where 
-- corelation_id = alertid so joinon that
EA.corelation_id = A.alertid
and upper(A.alertname) like '%INCOMING WIRE%' 
and ( EA.status_date >= trunc(sysdate-5) )
--and EA.status != 2
--and EA.user_group in ('CTCONCOL')
--and EA.user_name in ('MARTHA')
order by EA.status_date desc;

 

-- SQL #6 to help find recent Incoming Wire alert emails that were recently created and sent out via iPlat email_alert table
-- joining the web.alerts table. Same as above but group and count them up by alertid, status, date and user_group
-- in the last N days - currently set to last 5 days
-- For M&T ticket 08148354
-- Andrew Keller 1/7/22
select a.alertname, a.alertid
,EA.status,EA.status_message,trunc(EA.status_date),EA.user_group, count(*)
from dgbiplat.email_alert  EA, dgbweb.alerts A
where 
-- corelation_id = alertid so joinon that
EA.corelation_id = A.alertid
and upper(A.alertname) like '%INCOMING WIRE%' 
and ( EA.status_date >= trunc(sysdate-5) )
--and EA.status != 2
--and EA.user_group in ('CTCONCOL')
--and EA.user_name in ('MARTHA')
group by  a.alertname, a.alertid,EA.status,EA.status_message,trunc(EA.status_date),EA.user_group
order by 5 desc;

SF-06026115 SEV 3 | Frost Bank | Production | Error during ACH Template upload in afternoon

Hi Steve and Balaji,

I was looking at this ticket and I was going thru all imports (via the "QEVENTS" table - which saves the last 90 days worth of user imports) from that user (YADRIANO - who was the prominent user with the problem), similar to what file names "ACH*.DAT" were problematic before when you reported the issue (from the attached screenshots), over the last 90 days.

I'm not finding any import failures and/or resulting notifications from failed ACH imports from that user YADRIANO.

Is it possible that the issue is resolved?

thanks
-Andrew Keller
Bottomline Support



-- last import failure notifications for this user with ACH*.DAT files was April 2020
--7700 39127 YADRIANO CORPORATESOL 7700 CORPORATESOL YADRIANO ACHBOMDD000000000806.DAT 09-APR-20 03:08:59 2 154 39127 FILEIMPORT_CSV
--7698 38284 YADRIANO CORPORATESOL 7698 CORPORATESOL YADRIANO ACHCAMDD000002213.DAT 09-APR-20 03:08:59 2 154 38284 FILEIMPORT_CSV

select N.id,N.qeventid, N.userid, N.usergroup
,N.* from dgbweb.NOTIFICATIONS N
where upper(filename) like '%ACH%.DAT%'
and N.qeventstatus != '0'
and N.userid = 'YADRIANO'
order by N.id desc;


-- Old qevents rows > 90 days are pruged per the qevent purge event (event 110 which last ran 03-JAN-22)

Nothing but sucessful qevent imports for this user are captured in the last 90 days of qevents

-- For userid: YADRIANO
select Q.id, q.enteredtime,q.userid, q.state,q.status
, REGEXP_SUBSTR(substr(q.parameters,instr(q.parameters,'UserFilename=')+ length('UserFilename=')),'[^|]+',1,1) "myFile"
,Q.*
from dgbweb.qevents Q
where
Q.userid = 'YADRIANO'
-- didn't find any qevent failures in last 90 days for YADRIANO/'%ACH%.DAT%'
--and Q.status != '0'
and upper(parameters) like '%ACH%.DAT%'
order by Q.id desc;

SQL of the day. This one helps you find working email alerts (by name/last 5 days of alerts) as to use that info to help figure out why other similar alerts aren't working (in case the admin user screwed up the alert definition or we saved a un-validated alert - known bug ) and you aren't finding a corresponding exception in the messagelog table (sql exceptions in the traceinfo column etc)  that explains the issue as it could be that the alert is well-formed but never gets triggered based on how you defined it in admin (picked wrong alert type etc). Often by comparing a known working alert you have a better chance of creating another alert that will also work.
 
-- SQL to help find and count the email alerts of a certain name (%INCOMING%WIRE%)
-- by type that are working
-- and successfully sending emails with particular subject to particular recipients (usergroup/userid) by date
-- over the last 5 days
-- Andrew Keller 1/17/22 for M&T ticket 08148354
-- where email alerts aren't being sent for some users
-- This output will show you what email alerts are working and if the alert you are
-- troubleshooting doesn't show in the output of thise sql you can check messagelog for errors and compare it
-- to an alert (from this output list) in admin tool that does work and look for
-- reasons why one alert works and another doesn't. Compare problem email alert to one that works!
select EA.user_group,EA.user_name,a.alertname, a.alertid,a.type
,EA.status,EA.status_message,trunc(EA.status_date) "sent_date"
,count(*) "OKemailMsgCount",EM.subject,EM.recipient
from dgbiplat.email_alert EA, dgbweb.alerts A,dgbweb.emailmessage EM
-- M&T schema names
--from intplat.email_alert EA, web.alerts A,web.emailmessage EM
where
-- Join in subject, usergroup and alertid
EA.subject = A.subject
and EA.user_group = A.usergroup
and A.alertid = EM.alertid
and EA.user_group = EM.usergroup
-- alerts of a certain name like
and upper(A.alertname) like '%INCOMING%WIRE%'
and ( trunc(EA.status_date) >= trunc(sysdate-5) )
and ( trunc(EM.enteredtimestamp) >= trunc(sysdate-5) )
-- if you are looking alert emails for a particular usergroup, uncomment next line
-- and (EA.user_group = '1218032098')
-- if you are looking for a particular usergroup/userid uncomment next line
-- and (EA.user_group = '1218032098' and EA.user_name = 'BRENDA123')
group by EA.user_group,EA.user_name,a.alertname, a.alertid,a.type,EA.status,EA.status_message,trunc(EA.status_date),EM.subject,EM.recipient
order by trunc(EA.status_date) desc;

08166250 frost issue, users unable to access reset password link and so they are unable to create payments. 
[Yesterday 10:37 PM] Keller, Andrew
    here is the messagelog sql to look for any failure trends on  just "/dgb/rest/userSelfService/" since Friday

Which includes:
/dgb/rest/userSelfService/changePassword
/dgb/rest/userSelfService/resetPassword

But it seems like people screw up their password change or reset all the time and there doesn't seem to be a trend of it happening more than normal?

SELECT MESSAGE_ID, SOURCE, severity, LOGTIME,TO_CHAR((LOGTIME - INTERVAL '5' HOUR), 'DD-Mon-YYYY HH:MI:SS AM') "logtimeEST"
,traceinfo,message,traceid,trace  FROM DGBWEB.MESSAGELOG
WHERE MESSAGE_ID>(SELECT MAX(MESSAGE_ID)-700000 FROM DGBWEB.MESSAGELOG)
and source != 'HUB'
and severity = 'ERROR'
and traceinfo like '/dgb/rest/userSelfService/%'
order by message_id asc;

I was looking thru Frost messagelog table (which is insanely busy and verbose with tons of ERRORs 24/7 = bad thing in general) and it is very very very hard to find anything meaningful. But in case it helps someone here is my messagelog SQL with all my filters of all the noise.
 
SELECT MESSAGE_ID, MESSAGE,LOGTIME,TO_CHAR((LOGTIME - INTERVAL '5' HOUR), 'DD-Mon-YYYY HH:MI:SS AM') "logtimeEST",TRACEID,SEVERITY,SOURCE,
TRACEINFO FROM DGBWEB.MESSAGELOG
WHERE MESSAGE_ID>(SELECT MAX(MESSAGE_ID)-800000 FROM DGBWEB.MESSAGELOG)
and severity = 'ERROR'
and upper(message) not like '%COOKIE%' and message not like '%304%' and message not like '%429%'  and message not like '%401%'
and message not like '%Error code null%' and upper(message) not like '%LOGON%'
and message not like 'Error termingating active TPV sessions' and message not like 'Exception in SystemAlerts processLoadAlerts()'
and message not like 'User authorization is failed' and message not like 'Exception decrypting data%'
and message not like 'changePassword - the Security Token is missing.' and message not like 'Error code 100: Authentication Failed.'
and message not like 'inquiryUtils.getInquiryModel.nogridmodel0' and message not like '%INSERT INTO IMAGEVIEWAUDIT%'
and message not like 'Exception java.lang.NullPointerException thrown while generating filter in java.lang.NullPointerException'
and message not like 'Account Not Found%' and message not like 'Error code 11%'
--and upper(message) like '%CONNECTION%'
-- very numerous: Read time out after 5000 millis
and traceinfo not like '/dgb/rest/balanceAndTransaction/getCurrentAccountBalances%'
and traceinfo not like '%getOutputStream()%'
and message not like 'Message Producer Service Exception%' and message not like '%CamelRedelivered=false%'
and message not like 'Exception during validation of field: VALUE_DATE%' and traceinfo not like '/dgb/rest/batch/totals/getBatchTotals java.sql.SQLSyntaxErrorException: ORA-00904: "ORIGCURRENCYCODE": invalid identifier%'
and traceinfo not like '/dgb/rest/profileService/getProfile' and message not like 'Request to refresh the session failed'
and upper(message) not like '%SESSION%' and message not like '%CamelRedeliveryCounter%'
and source != 'HUB'
order by message_id DESC;

How to take thread dump:
-> Need to logun with DGB user:
/usr/bin/jstack -l 89308 > jstack_89308.out -> TO get the thread dump

jstack -l 89308 > jstack_89308.out



ps -ef | grep java | grep DGB | grep -v grep | grep ADMIN

[DGB@us00vlhub00013 AKA dgb-pr-fi9218-hub01 ~]$ ps -ef | grep java | grep DGB | grep -v grep | grep -v weblogic

[DGB@us00vlhub00013 AKA dgb-pr-fi9218-hub01 ~]$ ps -ef | grep java | grep DGB | grep -v grep | grep -v weblogic | wc -l



Script to generate results without SQL:

awk -F "," '/Client Account Name/{usergroup=substr($1,11,8); accountnum=substr($1,31,9); split($10,a,"->"); split(a[1],b,":"); print usergroup, accountnum,b[2] '} export_1.csv

Script to generate results with SQL:
awk -F "," '/Client Account Name/{usergroup=substr($1,11,8); accountnum=substr($1,31,9); split($10,a,"->"); split(a[1],b,":"); printf "INSERT INTO ORIGNAME_TEMP VALUES (\047%s\047, \047%s\047, \047%s\047);\n" ,usergroup, accountnum,b[2] '} export_1.csv