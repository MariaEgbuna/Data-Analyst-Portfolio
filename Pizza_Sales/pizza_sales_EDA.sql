-- BASIC ANALYSIS

-- Number of orders, Quanties sold, Total revenue
SELECT COUNT(*) AS order_count, SUM(ps.quantity) AS total_quanties_sold, SUM(ps.total_price) AS total_revenue
FROM pizza_sales AS ps;

-- Which pizza is the most ordered?
SELECT ps.pizza_name, COUNT(*) AS order_count
FROM pizza_sales AS ps
GROUP BY ps.pizza_name
ORDER BY order_count DESC
LIMIT 1;
-- 'The Classic Deluxe Pizza' is by far the most ordered pizza. This highlights its popularity and importance to the menu.

-- What is the most popular pizza size (M or L)?
SELECT ps.pizza_size, COUNT(*) AS order_count
FROM pizza_sales AS ps
GROUP BY ps.pizza_size
ORDER BY order_count DESC
LIMIT 1;
-- The most popular pizza size is Large (L).

-- What is the most popular pizza category (Classic, Veggie, Supreme)?
SELECT ps.pizza_category, COUNT(*) AS category_count
FROM pizza_sales AS ps
GROUP BY ps.pizza_category
ORDER BY category_count DESC;
-- The most popular pizza category is Classic.Use its popularity as a baseline to introduce new flavors that might appeal to the same customer segment.

-- Which pizza generates the highest revenue?
SELECT ps.pizza_name, SUM(ps.total_price) AS total_revenue
FROM pizza_sales AS ps
GROUP BY ps.pizza_name
ORDER BY total_revenue DESC;
-- Businesses should prioritize the availability and marketing of 'The Thai Chicken Pizza' as it directly impacts financial performance.

-- What is the average order value?
SELECT AVG(order_total) AS AOV
FROM 
( 
	SELECT ps.order_id, SUM(total_price) AS order_total
	FROM pizza_sales AS ps
	GROUP BY ps.order_id
) AS TotalPricePerOrder;
-- The average order value is approximately $38.31.

-- How does the revenue compare between different pizza categories?
SELECT ps.pizza_category, SUM(ps.total_price) AS revenue
FROM pizza_sales AS ps
GROUP BY ps.pizza_category;

-- Is there a preference for vegetarian or non-vegetarian pizzas?
-- Revenue Comparison
SELECT
  CASE
    WHEN pizza_category = 'Veggie' THEN 'Vegetarian'
    ELSE 'Non-Vegetarian'
  END AS pizza_type,
  SUM(ps.total_price) AS total_revenue
FROM pizza_sales AS ps
GROUP BY pizza_type
ORDER BY total_revenue DESC;

-- Quantity Comparison
SELECT
  CASE
    WHEN pizza_category = 'Veggie' THEN 'Vegetarian'
    ELSE 'Non-Vegetarian'
  END AS pizza_type,
  SUM(ps.quantity) AS total_quantity
FROM pizza_sales AS ps
GROUP BY pizza_type
ORDER BY total_quantity DESC;
-- There is a significant preference for non-vegetarian pizzas over vegetarian options, both in terms of total revenue generated and the total quantity sold. Non-vegetarian pizzas account for approximately 76% of the total revenue and about 76.5% of the total quantity sold.

-- How often do customers order more than one pizza at a time?
SELECT
	(SUM(CASE WHEN quantity > 1 THEN 1 ELSE 0 END)::NUMERIC / COUNT(*)) * 100 AS percentage_of_orders_with_multiple_pizzas
FROM pizza_sales;
-- Approximately 1.91% of the individual pizza entries in the dataset involve customers ordering more than one pizza at a time. This means that, for the vast majority of transactions (about 98.09%), customers are ordering a single pizza.

-- What is the price range of the pizzas sold?
SELECT
  MIN(unit_price) AS minimum_pizza_price,
  MAX(unit_price) AS maximum_pizza_price
FROM pizza_sales;
-- The price range of the pizzas sold is from $9.75 to $35.95

-- How does the unit price of pizzas vary across different sizes and categories?
SELECT ps.pizza_size, ps.pizza_category, AVG(ps.unit_price) AS average_unit_price
FROM pizza_sales AS ps
GROUP BY ps.pizza_size, ps.pizza_category
ORDER BY ps.pizza_size, average_unit_price;

-- ARE THERE ANY TIME PERIODS WITH UNUSUALLY HIGH OR LOW SALES?

-- Day with highest sales
SELECT
  ps.order_date,
  SUM(ps.total_price) AS daily_revenue
FROM pizza_sales AS ps
GROUP BY ps.order_date
ORDER BY daily_revenue DESC
LIMIT 1;
-- Highest Sales Day: 2015-11-27 (a Friday), with a revenue of $4422.45. This notably aligns with Black Friday, suggesting strong sales performance during major promotional events.

-- Day with lowest sales
SELECT
  ps.order_date,
  SUM(ps.total_price) AS daily_revenue
FROM pizza_sales AS ps
GROUP BY ps.order_date
ORDER BY daily_revenue
LIMIT 1;
--  Lowest Sales Day: 2015-03-22 (a Sunday), with a revenue of $1259.25. Sundays generally experience lower sales, and this particular date stands out as the lowest.

--  Month with Highest Sales
SELECT 
	TO_CHAR(ps.order_date, 'YYYY-MM') AS order_month,
 	SUM(ps.total_price) AS monthly_revenue
FROM pizza_sales AS ps
GROUP BY order_month
ORDER BY monthly_revenue DESC
LIMIT 1;
--Highest Sales Month: January 2015, with a total revenue of $71620.10. This might indicate a strong start to the year or post-holiday demand.

-- Month with lowest Sales
SELECT 
	TO_CHAR(ps.order_date, 'YYYY-MM') AS order_month,
 	SUM(ps.total_price) AS monthly_revenue
FROM pizza_sales AS ps
GROUP BY order_month
ORDER BY monthly_revenue
LIMIT 1;
-- Lowest Sales Month: December 2015, with a total revenue of $61058.10. This could be influenced by holiday season behaviors or closures.

-- Which days have the highest number of orders?
WITH DailyOrders AS (
    SELECT
        TO_CHAR(ps.order_date, 'Day') AS day_name,
        COUNT(ps.*) AS order_count,
        EXTRACT(DOW FROM ps.order_date) AS day_of_week_num
    FROM pizza_sales AS ps
    GROUP BY day_name, day_of_week_num
)
SELECT day_name, order_count
FROM DailyOrders
ORDER BY day_of_week_num;
-- Friday has the highest number of orders, followed closely by Saturday and Thursday. Sunday has the lowest number of orders

-- What are the peak order times for pizzas?
SELECT EXTRACT(HOUR FROM order_time) AS order_hour, COUNT(*) AS order_times
FROM pizza_sales AS ps
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY order_times DESC;
-- The peak order times are around 12PM (noon) and 1PM, followed by 6PM and 5PM. There's a significant drop in orders after 9PM, with very few orders in the early morning hours (9AM, 10AM). The pizza shop should ensure adequate staffing during these hours to handle the high volume of orders efficiently and maintain customer satisfaction.