SELECT * FROM superstore.orders AS o ;
SELECT * FROM superstore.customers AS c ;
SELECT * FROM superstore.products AS p ;

-- number of customers
SELECT COUNT(DISTINCT o.customer_id) AS no_of_customers
FROM orders AS o ;

-- number of products sold
SELECT COUNT(DISTINCT p.product_id) AS no_of_products
FROM products AS p;

-- earliest and latest dates
SELECT MAX(o.order_date ) AS  last_order_date, MIN(o.order_date ) AS first_order_date
FROM orders AS o ;

-- adding a cost column
ALTER TABLE orders 
ADD COLUMN COGS NUMERIC(10,2);

-- updating costs column
UPDATE orders AS o
SET COGS = o.sales - o.profit;

-- aggregates per year
SELECT 
	EXTRACT (YEAR FROM o.order_date) AS years,
	SUM(o.sales ) AS total_sales, 
	SUM(o.cogs) AS total_cost,
	SUM(o.qty ) AS total_qty_ordered, 
	AVG(o.discount_percent ) avg_discount, 
	SUM(o.profit ) AS total_profit,
  	(SUM(profit) / SUM(sales)) * 100 AS profit_margin_percent
FROM orders AS o
GROUP BY EXTRACT (YEAR FROM o.order_date)
ORDER BY EXTRACT (YEAR FROM o.order_date);

-- YoY variance
WITH yearly_sales AS (
  -- First, calculate total sales for each year
  SELECT EXTRACT(YEAR FROM order_date) AS sales_year, SUM(sales) AS total_sales
  FROM orders AS o
  GROUP BY sales_year
)
SELECT sales_year, total_sales,
  -- Use LAG to get the total sales from the previous year
  LAG(total_sales, 1) OVER (ORDER BY sales_year) AS previous_year_sales,
  -- Calculate the variance and percentage
  total_sales - LAG(total_sales, 1) OVER (ORDER BY sales_year) AS sales_variance,
  ((total_sales - LAG(total_sales, 1) OVER (ORDER BY sales_year)) / LAG(total_sales, 1) OVER (ORDER BY sales_year)) * 100 AS sales_variance_percent
FROM yearly_sales
ORDER BY sales_year;

-- Analyze by Region
SELECT
  c.region,
  SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2017 THEN sales ELSE 0 END) AS sales_2017,
  SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2018 THEN sales ELSE 0 END) AS sales_2018,
  SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2019 THEN sales ELSE 0 END) AS sales_2019
FROM  orders AS o
JOIN customers AS c 
ON o.customer_id = c.customer_id
GROUP BY region
ORDER BY sales_2017 DESC;

-- Analyze by Product Category
SELECT 
	p.category, 
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2017 THEN sales ELSE 0 END) AS sales_2017,
  	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2018 THEN sales ELSE 0 END) AS sales_2018,
  	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2019 THEN sales ELSE 0 END) AS sales_2019
FROM orders AS o
JOIN products AS p 
ON o.product_id = p.product_id 
GROUP BY p.category
ORDER BY sales_2017 DESC;

-- Sub category analysis
SELECT 
	p.sub_category, 
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2017 THEN sales ELSE 0 END) AS sales_2017,
  	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2018 THEN sales ELSE 0 END) AS sales_2018,
  	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2019 THEN sales ELSE 0 END) AS sales_2019
FROM orders AS o
JOIN products AS p 
ON o.product_id = p.product_id 
GROUP BY p.sub_category
ORDER BY sales_2017 DESC;

-- Analyze by Customers
SELECT 
	c.customer_name,
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2014 THEN sales ELSE 0 END) AS sales_2014,
    SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2015 THEN sales ELSE 0 END) AS sales_2015,
    SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2016 THEN sales ELSE 0 END) AS sales_2016,
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2017 THEN sales ELSE 0 END) AS sales_2017,
  	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2018 THEN sales ELSE 0 END) AS sales_2018,
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2019 THEN sales ELSE 0 END) AS sales_2019
FROM orders AS o 
JOIN customers AS c 
ON c.customer_id  = o.customer_id
GROUP BY c.customer_name
ORDER BY sales_2017 DESC
LIMIT 20;

-- gross profit margin
SELECT ( SUM(sales) - SUM(cogs) )/SUM(sales) *100 AS gross_profit_margin
FROM orders AS o;

-- net profit after discount
SELECT SUM(o.profit) AS total_profit, SUM(o.profit) - SUM(o.sales * o.discount_percent) AS net_profit_after_discount
FROM orders AS o;

-- discount percentage
SELECT SUM(o.sales * o.discount_percent) / SUM(o.sales) * 100 AS average_discount_rate
FROM orders AS o;

-- net_profit_after_discount
SELECT
	SUM(o.sales) AS revenue,
    SUM(o.profit) AS total_profit,
    SUM(o.sales * o.discount_percent) AS total_discount_amount,
    SUM(o.profit) - SUM(o.sales * o.discount_percent) AS net_profit_after_discount
FROM orders AS o;
-- Total discounts ($322,582.24) are greater than the total profit ($286,397.79), leading to a net loss of -$36,184.45.

-- net_profit discount by product category
SELECT
	p.category,
	SUM(o.sales) AS revenue,
    SUM(o.profit) AS total_profit,
    SUM(o.sales * o.discount_percent) AS total_discount_amount,
    SUM(o.profit) - SUM(o.sales * o.discount_percent) AS net_profit_after_discount
FROM orders AS o
JOIN products AS p
ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY net_profit_after_discount;

-- by sub_categories
SELECT
    p.sub_category,
    SUM(o.profit) AS total_profit,
    SUM(o.sales * o.discount_percent) AS total_discount_amount,
    SUM(o.profit) - SUM(o.sales * o.discount_percent) AS net_profit_after_discount
FROM orders AS o
JOIN products AS p
ON p.product_id = o.product_id
WHERE p.category = 'Furniture'
GROUP BY p.sub_category
ORDER BY net_profit_after_discount;

