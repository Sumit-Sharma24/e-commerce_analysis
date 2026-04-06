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

--