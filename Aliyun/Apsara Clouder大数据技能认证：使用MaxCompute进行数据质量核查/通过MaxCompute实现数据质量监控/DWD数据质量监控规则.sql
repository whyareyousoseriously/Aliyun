----����������ر����
drop table if exists DWD_DATA_CHECK_REPORT;
create table DWD_DATA_CHECK_REPORT(
	CHECK_RULE_ID STRING COMMENT '�˲�������',
	CHECK_RULE_NAME STRING COMMENT '�˲��������',
	CHECK_RULE_TYPE_NAME STRING COMMENT '�˲������������',
	CHECK_RULE_OWNER STRING COMMENT '������',
	CHECK_RULE_TABLE STRING COMMENT '���ݱ�',
	WARNING_TIME STRING COMMENT '�澯ʱ��',
	WARNING_CONTENT STRING COMMENT '�澯����'
)COMMENT '����������ر����'
PARTITIONED BY (
	DT STRING COMMENT 'ʱ�����'
);

----��������
vDate = $[yyyy-mm-dd-1]
vDay = $[yyyymmdd-1]
datetime=$[yyyy-mm-dd]
hour=$[hh24:mi:ss]

----�½���ʱ��1���ڴ�����������Ƿ�����澯
drop table if exists TMP_DWD_DATA_CHECK_REPORT_001_${vDay};
create table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}(
	CHECK_RULE_ID STRING COMMENT '�˲�������',
	WARNING_STATUS STRING COMMENT '�Ƿ�澯'
)COMMENT '����������ع���澯״̬';

----������ʱ��1��ع������check_001�Ƿ�澯
insert into table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}
select 'check_001',
	case when A.WARNING_CNT>0 then '1' else '0' end as WARNING_STATUS
from(select COUNT(1) WARNING_CNT
		from ODS_EBUSI_ORDERS
		where not(instr(ORDER_TIME,'-',1,1) = 5 and instr(ORDER_TIME,'-',1,2) = 8 and instr(ORDER_TIME,'-',1,3) = 0)
			or not(instr(ORDER_TIME,':',1,1) = 14 and instr(ORDER_TIME,':',1,2) = 17 and instr(ORDER_TIME,'-',1,3) = 0))as A
;

----������ʱ��1��ع������check_002�Ƿ�澯
insert into table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}
select 'check_002',
	case when B.WARNING_CNT>1 then '1' else '0' end as WARNING_STATUS
from(select SUM(WARNING_CNT) as WARNING_CNT
		from(SELECT CUSTOMER_ID,
						ORDER_TIME,
						COUNT(DISTINCT ORDER_ID) WARNING_CNT
					FROM ODS_EBUSI_ORDERS
					GROUP BY CUSTOMER_ID,
						ORDER_TIME
					HAVING COUNT(DISTINCT ORDER_ID) > 1)as A)AS B
;

----������ʱ��1��ع������check_003�Ƿ�澯
insert into table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}
select 'check_003',
	case when A.WARNING_CNT>1 then '1' else '0' end as WARNING_STATUS
from(SELECT count(1) as WARNING_CNT
		FROM ODS_EBUSI_CUSTOMERS A
			INNER JOIN ODS_EBUSI_DIM_PROVINCE B ON A.PROVINCE_ID = B.PROVINCE_ID
		WHERE A.PROVINCE_NAME <> B.PROVINCE_NAME)as A
;

----������ʱ��1��ع������check_004�Ƿ�澯
insert into table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}
select 'check_004',
	case when A.WARNING_CNT>1 then '1' else '0' end as WARNING_STATUS
from(SELECT count(1) as WARNING_CNT
		FROM ODS_EBUSI_DISPATCH A
			LEFT OUTER JOIN ODS_EBUSI_ORDERS B ON A.ORDER_ID=B.ORDER_ID
		WHERE B.ORDER_ID IS NULL)as A
;

----������ʱ��1��ع������check_005�Ƿ�澯
insert into table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}
select 'check_005',
	case when A.WARNING_CNT>1 then '1' else '0' end as WARNING_STATUS
from(SELECT count(1) as WARNING_CNT
		FROM ODS_EBUSI_CUSTOMERS A
 		WHERE A.GENDER IS NULL)as A
;

----������ʱ��1��ع������check_006�Ƿ�澯
insert into table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}
select 'check_006',
	case when A.WARNING_CNT>1 then '1' else '0' end as WARNING_STATUS
from(SELECT SUBSTR(ORDER_TIME,1,7),
			CUSTOMER_ID,
			COUNT(1) as WARNING_CNT
		FROM ODS_EBUSI_ORDERS A
		GROUP BY SUBSTR(ORDER_TIME,1,7),
			CUSTOMER_ID
		HAVING COUNT(1) > 10)as A
;

----����Ŀ����ر�����Ϣ
insert overwrite table DWD_DATA_CHECK_REPORT PARTITION(DT)
select A.CHECK_RULE_ID,	----'�˲�������',
	A.CHECK_RULE_NAME,	----'�˲��������',
	A.CHECK_RULE_TYPE_NAME,	----'�˲������������',
	A.CHECK_RULE_OWNER,	----'������',
	A.CHECK_RULE_TABLE,	----'���ݱ�',
	concat('${datetime}',' ','${hour}') as WARNING_TIME,	----'�澯ʱ��',
	concat('��ع���',A.CHECK_RULE_NAME,'���澯���ݣ�',A.CHECK_RULE_DESC,'�����¼ϵͳ���к˲飡') as WARNING_CONTENT,	----'�澯����'
	'${vDate}' as DT	----'ʱ�����'
from ODS_DATA_CHECK_RULE A
	inner join TMP_DWD_DATA_CHECK_REPORT_001_${vDay} B on A.CHECK_RULE_ID=B.CHECK_RULE_ID and B.WARNING_STATUS = '1'
;
