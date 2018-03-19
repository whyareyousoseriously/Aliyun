----数据质量监控报告表
drop table if exists DWD_DATA_CHECK_REPORT;
create table DWD_DATA_CHECK_REPORT(
	CHECK_RULE_ID STRING COMMENT '核查规则编码',
	CHECK_RULE_NAME STRING COMMENT '核查规则名称',
	CHECK_RULE_TYPE_NAME STRING COMMENT '核查规则类型名称',
	CHECK_RULE_OWNER STRING COMMENT '负责人',
	CHECK_RULE_TABLE STRING COMMENT '数据表',
	WARNING_TIME STRING COMMENT '告警时间',
	WARNING_CONTENT STRING COMMENT '告警内容'
)COMMENT '数据质量监控报告表'
PARTITIONED BY (
	DT STRING COMMENT '时间分区'
);

----参数配置
vDate = $[yyyy-mm-dd-1]
vDay = $[yyyymmdd-1]
datetime=$[yyyy-mm-dd]
hour=$[hh24:mi:ss]

----新建临时表1用于存放数据质量是否产生告警
drop table if exists TMP_DWD_DATA_CHECK_REPORT_001_${vDay};
create table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}(
	CHECK_RULE_ID STRING COMMENT '核查规则编码',
	WARNING_STATUS STRING COMMENT '是否告警'
)COMMENT '数据质量监控规则告警状态';

----插入临时表1监控规则编码check_001是否告警
insert into table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}
select 'check_001',
	case when A.WARNING_CNT>0 then '1' else '0' end as WARNING_STATUS
from(select COUNT(1) WARNING_CNT
		from ODS_EBUSI_ORDERS
		where not(instr(ORDER_TIME,'-',1,1) = 5 and instr(ORDER_TIME,'-',1,2) = 8 and instr(ORDER_TIME,'-',1,3) = 0)
			or not(instr(ORDER_TIME,':',1,1) = 14 and instr(ORDER_TIME,':',1,2) = 17 and instr(ORDER_TIME,'-',1,3) = 0))as A
;

----插入临时表1监控规则编码check_002是否告警
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

----插入临时表1监控规则编码check_003是否告警
insert into table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}
select 'check_003',
	case when A.WARNING_CNT>1 then '1' else '0' end as WARNING_STATUS
from(SELECT count(1) as WARNING_CNT
		FROM ODS_EBUSI_CUSTOMERS A
			INNER JOIN ODS_EBUSI_DIM_PROVINCE B ON A.PROVINCE_ID = B.PROVINCE_ID
		WHERE A.PROVINCE_NAME <> B.PROVINCE_NAME)as A
;

----插入临时表1监控规则编码check_004是否告警
insert into table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}
select 'check_004',
	case when A.WARNING_CNT>1 then '1' else '0' end as WARNING_STATUS
from(SELECT count(1) as WARNING_CNT
		FROM ODS_EBUSI_DISPATCH A
			LEFT OUTER JOIN ODS_EBUSI_ORDERS B ON A.ORDER_ID=B.ORDER_ID
		WHERE B.ORDER_ID IS NULL)as A
;

----插入临时表1监控规则编码check_005是否告警
insert into table TMP_DWD_DATA_CHECK_REPORT_001_${vDay}
select 'check_005',
	case when A.WARNING_CNT>1 then '1' else '0' end as WARNING_STATUS
from(SELECT count(1) as WARNING_CNT
		FROM ODS_EBUSI_CUSTOMERS A
 		WHERE A.GENDER IS NULL)as A
;

----插入临时表1监控规则编码check_006是否告警
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

----插入目标表监控报告信息
insert overwrite table DWD_DATA_CHECK_REPORT PARTITION(DT)
select A.CHECK_RULE_ID,	----'核查规则编码',
	A.CHECK_RULE_NAME,	----'核查规则名称',
	A.CHECK_RULE_TYPE_NAME,	----'核查规则类型名称',
	A.CHECK_RULE_OWNER,	----'负责人',
	A.CHECK_RULE_TABLE,	----'数据表',
	concat('${datetime}',' ','${hour}') as WARNING_TIME,	----'告警时间',
	concat('监控规则：',A.CHECK_RULE_NAME,'，告警内容：',A.CHECK_RULE_DESC,'，请登录系统进行核查！') as WARNING_CONTENT,	----'告警内容'
	'${vDate}' as DT	----'时间分区'
from ODS_DATA_CHECK_RULE A
	inner join TMP_DWD_DATA_CHECK_REPORT_001_${vDay} B on A.CHECK_RULE_ID=B.CHECK_RULE_ID and B.WARNING_STATUS = '1'
;
