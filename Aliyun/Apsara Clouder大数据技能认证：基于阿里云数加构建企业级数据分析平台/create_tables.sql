--数据同步任务的目标表
--orders
drop table if exists orders;
create table orders (
  order_id bigint,
  customer_id bigint,
  product_id bigint,
  product_cnt bigint,
	order_amt decimal,
	shipping_type_id bigint,
  order_time datetime
) partitioned by (ds string);
--customers
drop table if exists customers;
create table customers (
  customer_id bigint,
  customer_name string,
  age bigint,
  gender bigint,
  city_id bigint,
  gen_date datetime
);
--stock
drop table if exists stock;
create table stock(
  storehouse_id bigint,
  product_id bigint,
  product_cnt bigint,
  update_time datetime
);

--dispatch
drop table if exists dispatch;
create table dispatch(
  dispatch_id bigint,
  order_id bigint,
  express_staff_id bigint,
  storehouse_id bigint,
  expect_time datetime,
  dispatch_time datetime
) partitioned by (ds string)
;

--dilivery
drop table if exists dilivery;
create table dilivery(
  dilivery_id bigint,
  dispatch_id bigint,
  dilivery_status_id bigint,
  update_time datetime
)partitioned by (ds string)
;

--dim_product
drop table if exists dim_product;
create table dim_product(
  product_id bigint,
  product_name string,
  price decimal,
  product_category_id bigint
);


--需要的汇总表
--	业务大盘
drop table if exists st_buzi_all;
create table st_buzi_all (
  buzi_date       datetime,
  order_cnt       bigint,
  total_amt       decimal,
  new_cust_cnt    bigint,
  curr_cust_cnt   bigint,
  stock_item_cnt  bigint,
  stock_amt       bigint,
  succ_sent_rate  decimal,
  sent_prd_cnt    bigint,
  ds string
);



