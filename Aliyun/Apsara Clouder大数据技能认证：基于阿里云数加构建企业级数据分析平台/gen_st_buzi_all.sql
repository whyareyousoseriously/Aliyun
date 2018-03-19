set odps.sql.allow.fullscan=true;
insert into table st_buzi_all
select /*+ mapjoin(t1,t3,t4,t5,t6,t7) */  '${yyyy_mm_dd} 00:00:00', COALESCE(order_cnt,0), COALESCE(total_amt,0), COALESCE(new_cust_cnt,0), COALESCE(curr_cust_cnt,0),
        COALESCE(stock_item_cnt,0), COALESCE(stock_amt,0), COALESCE(succ_sent_rate,0), COALESCE(sent_prd_cnt,0),'${bdp.system.bizdate}'
  from (select count(distinct order_id) as order_cnt, sum(order_amt) total_amt
          from orders where to_char(order_time,'yyyy-mm-dd') ='${yyyy_mm_dd}') t1
  inner join (select count(*) as new_cust_cnt from customers where  to_char(gen_date,'yyyy-mm-dd')='${yyyy_mm_dd}') t2
    on 1=1
  inner join (select count(*) as curr_cust_cnt from customers where to_char(gen_date,'yyyy-mm-dd')<='${yyyy_mm_dd}') t3
    on 1=1
  inner join (select sum(product_cnt) as stock_item_cnt from stock) t4
    on 1=1
  inner join (select sum(tt1.product_cnt*tt2.price) as stock_amt from stock tt1
               inner join dim_product tt2 on tt1.product_id=tt2.product_id) t5
    on 1=1
  inner join (select sum(case when tt1.update_time <=tt2.expect_time then 1 else 0 end )/(case when count(tt1.dispatch_id) = 0 then 1 else count(tt1.dispatch_id) end)  as succ_sent_rate
               from dilivery tt1
               inner join dispatch tt2
                 on tt1.dispatch_id = tt2.dispatch_id
              where to_char(tt1.update_time,'yyyy-mm-dd') = '${yyyy_mm_dd}') t6
    on 1=1
  inner join (select sum(product_cnt) as sent_prd_cnt
               from dilivery tt1
               inner join dispatch tt2
                 on tt1.dispatch_id = tt2.dispatch_id
               inner join orders tt3
                 on tt2.order_id=tt3.order_id
              where tt1.dilivery_status_id=1
                and to_char(tt1.update_time,'yyyy-mm-dd') = '${yyyy_mm_dd}') t7
    on 1=1
;

