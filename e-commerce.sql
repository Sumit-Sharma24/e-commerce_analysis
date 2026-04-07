-- creating the database
create database e_commerce;

use e_commerce;

-- analyze the data
desc customers;
desc orders;
desc products;
desc order_details;

-- top 3 cities with highest customers
with city_ranking as (
	select
	location,
	count(customer_id) as number_of_customers,
	dense_rank() over(order by count(customer_id) desc) as ranking
	from customers
	group by location
)
select
location,
number_of_customers
from city_ranking
where ranking <= 3;

-- order frequency count -> how many customers do how many orders
with orders_count as (
	select
	customer_id,
	count(order_id) as total_orders
	from orders
    group by customer_id
)
select
total_orders as NumberOfOrders,
count(customer_id) as CustomerCount
from orders_count
group by total_orders
order by NumberOfOrders asc;

-- identify products where the average purchase quantity per order is 2
select
product_id,
avg(quantity) as AvgQuantity,
sum(quantity * price_per_unit) as TotalRevenue
from order_details
group by product_id
having avg(quantity) = 2
order by TotalRevenue desc;

-- unique number of customers purchasing from each product category
select
category,
count(distinct customer_id) as unique_customers
from orders as o
join order_details as od
on o.order_id = od.order_id
join products as p
on od.product_id = p.product_id
group by category
order by unique_customers desc;

-- month-on-month growth trends
with total_sales as (
	select
	date_format(order_date, '%Y-%m') as Month,
	sum(total_amount) as TotalSales
	from orders
	group by date_format(order_date, '%Y-%m')
)
select
*,
round(((TotalSales - lag(TotalSales) over(order by Month asc))/lag(TotalSales) over(order by Month asc)) * 100, 2) as PercentChange
from total_sales;

-- average order value changes month-on-month
with avg_sales as (
	select
	date_format(order_date, '%Y-%m') as Month,
	round(avg(total_amount), 2) as AvgOrderValue
	from orders
	group by date_format(order_date, '%Y-%m')
)
select
*,
round(((AvgOrderValue - lag(AvgOrderValue) over(order by Month asc))), 2) as ChangeInValue
from avg_sales;

-- identify products with the fastest turnover rates
select
product_id,
count(*) as SalesFrequency
from orderdetails
group by product_id
order by SalesFrequency desc
limit 5;

-- low engagement products
with finding_unique_customers as (
    select
    p.product_id,
    p.name,
    count(distinct c.customer_id) as UniqueCustomerCount
    from customers as c
    join orders as o
    on c.customer_id = o.customer_id
    join order_details as od
    on o.order_id = od.order_id
    join products as p
    on od.product_id = p.product_id
    group by p.product_id,
    p.name
)
select
*
from finding_unique_customers
where UniqueCustomerCount < 0.4 * (select count(customer_id) from customers);

-- customer acquisition trend
with first_order_date as (
    select
    customer_id,
    min(order_date) as first_purchase_date
    from orders
    group by customer_id
)
select
date_format(first_purchase_date, '%Y-%m') FirstPurchaseMonth,
count(customer_id) as TotalNewCustomers
from first_order_date
group by date_format(first_purchase_date, '%Y-%m')
order by FirstPurchaseMonth asc;

-- peak sales period identification
select
date_format(order_date, '%Y-%m') as Month,
sum(total_amount) as TotalSales
from orders
group by date_format(order_date, '%Y-%m')
order by TotalSales desc
limit 3;