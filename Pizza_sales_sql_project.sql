-- To create the database named pizzeria 
CREATE DATABASE pizzeria;

-- To use this database 
USE pizzeria;


-- 1.Retrieve the total number of orders placed.
SELECT 
    COUNT(orders_id) AS total_orders
FROM
    orders;
    

-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS total_revenue
FROM
    pizzas p
        INNER JOIN
    order_details o ON p.pizza_id = o.pizza_id;
    

-- 3. Identify the highest-priced pizza.
SELECT 
    MAX(price) AS expensive_pizza
FROM
    pizzas;

-- 4. Identify the most common pizza size ordered.
SELECT 
    pizza_type_id, COUNT(size) AS common_size
FROM
    pizzas
GROUP BY pizza_type_id
ORDER BY COUNT(size) DESC
LIMIT 3;


-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    p.pizza_type_id AS Pizza,
    COUNT(o.quantity) AS Ordered_Quantity
FROM
    order_details AS o
        INNER JOIN
    pizzas p ON o.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Intermediate:

--  1. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.name, SUM(od.quantity) AS Quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY 2 DESC
LIMIT 5	;





-- 2. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hours, COUNT(orders_id)
FROM
    orders
GROUP BY 1
ORDER BY 2 DESC;


-- 3.Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS Total_Types_of_Pizza
FROM
    pizza_types
GROUP BY 1;



-- 4.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    EXTRACT(DAY FROM o.order_date) AS Days,
    SUM(od.quantity) AS Quantity
FROM
    order_details AS od
        JOIN
    orders o ON od.order_id = o.orders_id
GROUP BY EXTRACT(DAY FROM o.order_date);


-- 5.Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    p.pizza_type_id AS PIZZA_TYPE,
    ROUND(SUM(p.price * od.quantity)) AS Revenue
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.pizza_type_id
ORDER BY Revenue DESC
LIMIT 3;


-- Advanced:
-- 1. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(p.price * od.quantity)) AS Revenue,
    CONCAT(ROUND((SUM(p.price * od.quantity) / (SELECT 
                            SUM(p.price * od.quantity)
                        FROM
                            pizzas AS p
                                JOIN
                            order_details AS od ON od.pizza_id = p.pizza_id)) * 100,
                    2),
            '%') AS Revenue_Percentage
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY Revenue DESC;




-- 2. Analyze the cumulative revenue generated over time.

SELECT order_date,
SUM(Revenue) OVER(ORDER BY order_date) as Cum_Revenue
FROM
(SELECT 
o.order_date AS Order_Date,
ROUND(SUM(p.price*od.quantity)) as Revenue
FROM orders AS o
	JOIN order_details AS od ON o.orders_id = od.order_id
    JOIN pizzas AS p ON p.pizza_id = od.pizza_id
GROUP BY Order_Date) as Revenue;



-- 3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category,name,Revenue,
RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS rn
FROM
(SELECT 
pt.category,
pt.name,
ROUND(SUM(p.price*od.quantity)) AS Revenue
FROM pizza_types AS pt
	JOIN pizzas AS p ON pt.pizza_type_id=p.pizza_type_id
    JOIN order_details AS od ON od.pizza_id=p.pizza_id
GROUP BY pt.category, pt.name
ORDER BY Revenue DESC LIMIT 3) as a;