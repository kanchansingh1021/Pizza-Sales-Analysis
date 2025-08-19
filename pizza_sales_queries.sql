--KPIs
--total revenue generated from pizza sales.
alter table order_details alter column pizza_id varchar(50) 

select 
    round(sum(od.quantity*p.price),2) as totalrevenue 
	from order_details as od
    join pizzas as p
	on od.pizza_id=p.pizza_id;

--Average Order Value
select 
round(sum(od.quantity*p.price)/count(distinct od.order_id),2) as avg_order_value
from order_details od
join pizzas p
on od.pizza_id=p.pizza_id;

-- total pizza sold
select sum(quantity) as total_pizza_sold from order_details;

--total orders placed
select 
    count(order_id) as total_orders
from orders;

--Average Pizzas Per Order
select cast(sum(quantity) as decimal(10,2))/
cast(count(distinct order_id) as decimal(10,2)) as avg_pizza_per_order
from order_details;
-----------------------------------------------------------------------------

-- Charts Requirement

--1. Daily trend for total orders
select datename(dw,order_date)as order_day,
count(distinct order_id) as total_orders
from orders
group by datename(dw,order_date)

--2. Monthly trend for total orders
select datename(month,order_date) as order_month,
count(distinct order_id) as total_orders
from orders 
group by datename(month,order_date)

--3. Percentage of sales by pizza category
SELECT 
  pt.category,
  ROUND(SUM(od.quantity * p.price), 2) AS category_revenue,
  ROUND(
    SUM(od.quantity * p.price) * 100.0 /
    (SELECT SUM(od2.quantity * p2.price)
     FROM order_details od2
	 -- where month(order_date)=1
     JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id),
    2
  ) AS percentage_of_sales
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
-- where month(order_date)=1(perform necessary joins to join orders table)
GROUP BY pt.category
ORDER BY percentage_of_sales DESC;

--4. Percentage of Sales by Pizza size
select p.size,
round(sum(od.quantity*p.price),2) as size_category_revenue,
round(sum(od.quantity*p.price)*100/
(select sum(od2.quantity*p2.price)
from order_details od2
join pizzas p2 on od2.pizza_id=p2.pizza_id),2
) as sales_percentage
from order_details od
join pizzas p
on od.pizza_id=p.pizza_id
group by p.size
order by sales_percentage desc

--5. Top 5 Best Sellers by Revenue, Total Quantity and Total Orders
--by Revenue
select top 5 pt.name,sum(od.quantity*p.price) as Revenue
from order_details od
join pizzas p 
on od.pizza_id=p.pizza_id
join pizza_types pt 
on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by Revenue desc
-- by quantity
select top 5 pt.name,sum(od.quantity) as quantity
from order_details od
join pizzas p 
on od.pizza_id=p.pizza_id
join pizza_types pt 
on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by quantity desc
-- by total orders
select top 5 pt.name,count(distinct od.order_id) as total_orders
from order_details od
join pizzas p 
on od.pizza_id=p.pizza_id
join pizza_types pt 
on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by total_orders desc

--6. Bottom 5 Sellers by Revenue, Total Quantity and Total Orders
--by revenue
select top 5 pt.name,round(sum(od.quantity*p.price),2) as Revenue
from order_details od
join pizzas p 
on od.pizza_id=p.pizza_id
join pizza_types pt 
on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by Revenue
-- by quanitty
select top 5 pt.name,sum(od.quantity) as quantity
from order_details od
join pizzas p 
on od.pizza_id=p.pizza_id
join pizza_types pt 
on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by quantity 
-- by total orders
select top 5 pt.name,count(distinct od.order_id) as total_orders
from order_details od
join pizzas p 
on od.pizza_id=p.pizza_id
join pizza_types pt 
on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by total_orders



--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  --3)Identify the highest-priced pizza.

select pt.name,p.price
from pizza_types as pt
join pizzas as p
on p.pizza_type_id=pt.pizza_type_id
where p.price= (select max(price) from pizzas);

--alternate way using window function
select name,price 
from(
select pt.name,p.price,
rank() over(order by p.price desc) as price_rank
from pizza_types as pt 
join pizzas as p
on p.pizza_type_id=pt.pizza_type_id
) as ranked_pizzas
where price_rank=1

--4)Identify the most common pizza size ordered.

select top 1 p.size,
count(od.order_details_id) as order_count
from pizzas as p
join order_details as od
on p.pizza_id=od.pizza_id
group by p.size
order by order_count desc;

--List the top 5 most ordered pizza types along with their quantities.
select top 5 pt.name,
sum(od.quantity) as total_order
from order_details as od
join pizzas as p
on od.pizza_id=p.pizza_id
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by total_order desc

--Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category,
sum(od.quantity) as total_order
from order_details as od
join pizzas as p
on od.pizza_id=p.pizza_id
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.category

--Determine the distribution of orders by hour of the day.
select datepart(hour,order_time) as hour, 
count(order_id) as order_count
from orders
group by datepart(hour,order_time)

--Join relevant tables to find the category-wise distribution of pizzas.


--Group the orders by date and calculate the average number of pizzas ordered per day.
--Determine the top 3 most ordered pizza types based on revenue.

--Advanced:
--Calculate the percentage contribution of each pizza type to total revenue.
--Analyze the cumulative revenue generated over time.
--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select * from orders;
select *from order_details;  
select *from pizza_types;
select *from pizzas;
