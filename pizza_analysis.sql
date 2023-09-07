set global max_allowed_packet=1073741824;
set global sql_mode='TRADITIONAL,ALLOW_INVALID_DATES,ONLY_FULL_GROUP_BY';
SET GLOBAL CONNECT_TIMEOUT=288000;
SET GLOBAL WAIT_TIMEOUT=288000;
SET GLOBAL INTERACTIVE_TIMEOUT=288000;
CREATE SCHEMA practice_pizza_sales_analysis;
use practice_pizza_sales_analysis;
CREATE TABLE pizzas (
	pizza_id VARCHAR(14) NOT NULL, 
	pizza_type_id VARCHAR(12) NOT NULL, 
	size VARCHAR(3) NOT NULL, 
	price DECIMAL(38, 2) NOT NULL
);
 CREATE TABLE orders (
	order_id DECIMAL(38, 0) NOT NULL, 
	`date` DATE NOT NULL, 
	`time` TIME NOT NULL
);
CREATE TABLE order_details (
	order_details_id DECIMAL(38, 0) NOT NULL, 
	order_id DECIMAL(38, 0) NOT NULL, 
	pizza_id VARCHAR(14) NOT NULL, 
	quantity DECIMAL(38, 0) NOT NULL
);
CREATE TABLE `practice_pizza_sales_analysis`.`pizza_types` (
  `pizza_type_id` VARCHAR(300) NOT NULL,
  `name` VARCHAR(300) NULL,
  `ingredients` VARCHAR(300) NULL,
  `category` VARCHAR(300) NULL,
  PRIMARY KEY (`pizza_type_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

load data infile 'orders.csv'
into table orders
fields terminated by ','
ignore 1 rows;
load data infile 'order_details.csv'
into table order_details
fields terminated by ','
ignore 1 rows;
load data infile 'pizzas.csv'
into table pizzas
fields terminated by ','
ignore 1 rows;
load data infile 'pizza_types.csv'
into table pizza_types
fields enclosed by'"'
ignore 1 rows;
SET SQL_SAFE_UPDATES = 0;
update pizza_types
set ingredients=SUBSTRING(ingredients, 2, LENGTH(ingredients));
select * from pizzas;
update pizza_types
set ingredients=SUBSTRING(ingredients, 1, LENGTH(ingredients)-1);
select *from order_details;
ALTER TABLE `practice_pizza_sales_analysis`.`order_details` 
ADD PRIMARY KEY (`order_details_id`);
ALTER TABLE `practice_pizza_sales_analysis`.`orders` 
ADD PRIMARY KEY (`order_id`);
ALTER TABLE `practice_pizza_sales_analysis`.`pizzas` 
ADD PRIMARY KEY (`pizza_id`);
/*Analysis of database*/
/*average customers per day*/
with dailycustomers AS (
select count(order_id),count(distinct(`date`)) 
from orders)
select count(order_id)/count(distinct(`date`)) as average
from orders,dailycustomers;
/*peak hours*/
Create view timezoneview as
Select order_id,`time`,(case 
when'00:00:00'<=`time`AND`time`<='00:59:59'then"12 to 1"
when'01:00:00'<=`time`AND`time`<='01:59:59'then"1 to 2"
when'02:00:00'<=`time`AND`time`<='02:59:59'then"2 to 3"
when'03:00:00'<=`time`AND`time`<='03:59:59'then"3 to 4"
when'04:00:00'<=`time`AND`time`<='04:59:59'then"4 to 5"
when'05:00:00'<=`time`AND`time`<='05:59:59'then"5 to 6"
when'06:00:00'<=`time`AND`time`<='06:59:59'then"6 to 7"
when'07:00:00'<=`time`AND`time`<='07:59:59'then"7 to 8"
when'08:00:00'<=`time`AND`time`<='08:59:59'then"8 to 9"
when'09:00:00'<=`time`AND`time`<='09:59:59'then"9 to 10"
when'10:00:00'<=`time`AND`time`<='10:59:59'then"10 to 11"
when'11:00:00'<=`time`AND`time`<='11:59:59'then"11 to 12"
when'12:00:00'<=`time`AND`time`<='12:59:59'then"12 to 13"
when'13:00:00'<=`time`AND`time`<='13:59:59'then"13 to 14"
when'14:00:00'<=`time`AND`time`<='14:59:59'then"14 to 15"
when'15:00:00'<=`time`AND`time`<='15:59:59'then"15 to 16"
when'16:00:00'<=`time`AND`time`<='16:59:59'then"16 to 17"
when'17:00:00'<=`time`AND`time`<='17:59:59'then"17 to 18"
when'18:00:00'<=`time`AND`time`<='18:59:59'then"18 to 19"
when'19:00:00'<=`time`AND`time`<='19:59:59'then"19 to 20"
when'20:00:00'<=`time`AND`time`<='20:59:59'then"20 to 21"
when'21:00:00'<=`time`AND`time`<='21:59:59'then"21 to 22"
when'22:00:00'<=`time`AND`time`<='22:59:59'then"22 to 23"
when'23:00:00'<=`time`AND`time`<='23:59:59'then"23 to 24"
END) as timezone
from orders;
/*Number_of_Pizzas_per_order*/
create view frequency_pizza as
select order_id,count(quantity) as pizzas_per_order
from order_details
group by order_id;
select pizzas_per_order,count(pizzas_per_order) as frequency_of_pizzas_per_order 
from frequency_pizza
group by pizzas_per_order
order by 2 desc;
select avg(pizzas_per_order) from frequency_pizza;
/*Best Sellers*/
select sum(sold_pizzas),pizza_types.`name` from pizza_types left join
(select order_details.pizza_id,pizzas.pizza_type_id, count(quantity) as sold_pizzas 
from order_details 
left join pizzas on order_details.pizza_id=pizzas.pizza_id
group by order_details.pizza_id
order by 3 desc) as quantity_sold 
on pizza_types.pizza_type_id=quantity_sold.pizza_type_id
group by `name`
order by 1 desc
limit 10;
/*Total_revenue_of_the_year*/
select sum(total_value) from 
(select quantity_sold, price, (quantity_sold*price) as total_value from (select pizza_id,count(quantity) as quantity_sold
from order_details
group by pizza_id)as pizzas_sold left join pizzas
on pizzas_sold.pizza_id=pizzas.pizza_id)as final;
/*Any_changes_on_menu_or_any_offers*/
select sum(sold_pizzas),pizza_types.`name` from pizza_types left join
(select order_details.pizza_id,pizzas.pizza_type_id, count(quantity) as sold_pizzas 
from order_details 
left join pizzas on order_details.pizza_id=pizzas.pizza_id
group by order_details.pizza_id
order by 3 desc) as quantity_sold 
on pizza_types.pizza_type_id=quantity_sold.pizza_type_id
group by `name`
order by 1
limit 5;