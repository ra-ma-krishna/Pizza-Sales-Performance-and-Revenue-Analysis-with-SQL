create database pizzahut;

use pizzahut;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);	


SELECT 
    *
FROM
    order_details;
SELECT 
    *
FROM
    orders;
SELECT 
    *
FROM
    pizza_types;
SELECT 
    *
FROM
    pizzas;
---------- Basic:
-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) Total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    FLOOR(SUM(p.price * o.quantity)) AS Total_revenue
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id;

-- Identify the highest-priced pizza.

SELECT 
    *
FROM
    pizzas
ORDER BY price DESC
LIMIT 1;

SELECT 
    t.name, p.price
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(o.order_details_id) AS count
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY count DESC
LIMIT 1;



-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    t.name, SUM(o.quantity) count
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types t ON p.pizza_type_id = t.pizza_type_id
GROUP BY 1
ORDER BY count DESC
LIMIT 5;



---------- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    t.category, SUM(o.quantity) AS Total_quantity
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
        JOIN
    pizza_types t ON p.pizza_type_id = t.pizza_type_id
GROUP BY t.category;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) order_count
FROM
    orders
GROUP BY 1
ORDER BY order_count DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_type_id) AS count
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(sum_quant) AS average
FROM
    (SELECT 
        o.order_date, SUM(d.quantity) AS sum_quant
    FROM
        order_details d
    JOIN orders o ON o.order_id = d.order_id
    GROUP BY o.order_date) AS quant
;

-- Determine the top 3 most ordered pizza types based on revenue.

select * from order_details;
select * from pizza_types;
select * from pizzas;

SELECT 
    t.name, FLOOR(SUM(p.price * o.quantity)) AS Revenue
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY t.name
ORDER BY price DESC
LIMIT 3;

--------- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.

select * from order_details;
select * from pizza_types;
select * from pizzas;

select 
  t.category, 
  (
    sum(o.quantity * p.price) / (
      select 
        floor(
          sum(o.quantity * p.price)
        ) 
      from 
        order_details o 
        join pizzas p on o.pizza_id = p.pizza_id
    ) * 100
  ) revenue_in_percent 
from 
  pizza_types t 
  join pizzas p on t.pizza_type_id = p.pizza_type_id 
  join order_details o on p.pizza_id = o.pizza_id 
group by 
  1;

  
  
SELECT 
  t.category, 
  (
    SUM(o.quantity * p.price) / (
      SELECT 
        round(
          (
            SUM(o.quantity * p.price)
          ), 
          2
        ) 
      FROM 
        order_details o 
        JOIN pizzas p ON o.pizza_id = p.pizza_id
    ) * 100
  ) AS revenue_in_percent 
FROM 
  pizza_types t 
  JOIN pizzas p ON t.pizza_type_id = p.pizza_type_id 
  JOIN order_details o ON p.pizza_id = o.pizza_id 
GROUP BY 
  t.category;



SELECT 
    t.category,
    ROUND((SUM(o.quantity * p.price) / (SELECT 
                    FLOOR(SUM(o.quantity * p.price))
                FROM
                    order_details o
                        JOIN
                    pizzas p ON o.pizza_id = p.pizza_id) * 100),
            2) AS revenue_in_percent
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY t.category;


-- Analyze the cumulative revenue generated over time.

select 
  order_date, 
  sum(revenue) over (
    order by 
      order_date
  ) as cum_revenue 
from 
  (
    select 
      orders.order_date, 
      sum(
        order_details.quantity * pizzas.price
      ) as revenue 
    from 
      order_details 
      join pizzas on order_details.pizza_id = pizzas.pizza_id 
      join orders on orders.order_id = order_details.order_id 
    group by 
      orders.order_date
  ) as sales;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    pizza_types.category,
    5 * ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                ),
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;
