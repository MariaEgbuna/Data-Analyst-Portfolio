SELECT * FROM superstore.orders AS o ;
SELECT * FROM superstore.customers AS c ;
SELECT * FROM superstore.products AS p ;

-- INITIAL OVERVIEW

-- KEY METRICS
SELECT 
	SUM(o.sales) AS revenue,
	SUM(o.profit) AS total_profit,
	COUNT(DISTINCT o.customer_id) AS no_of_customers,
	COUNT(DISTINCT o.product_id) AS no_of_products,
	SUM(o.qty ) AS total_qty_ordered
FROM orders AS o;

-- ADDING A COST COLUMN
ALTER TABLE orders 
ADD COLUMN COGS NUMERIC(10,2);

-- UPDATING COSTS COLUMN
UPDATE orders AS o
SET COGS = o.sales - o.profit;

-- YOY VARIANCE
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

-- REGIONAL SALES ACROSS YEARS
SELECT
  ca.region,
  SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2014 THEN sales ELSE 0 END) AS sales_2014,
  SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2015 THEN sales ELSE 0 END) AS sales_2015,
  SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2016 THEN sales ELSE 0 END) AS sales_2016,
  SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2017 THEN sales ELSE 0 END) AS sales_2017,
  SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2018 THEN sales ELSE 0 END) AS sales_2018,
  SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2019 THEN sales ELSE 0 END) AS sales_2019
FROM  orders AS o
JOIN customer_addresses AS ca
ON o.customer_id = ca.customer_id
GROUP BY region;

-- YEARLY SALES BY PRODUCT CATEGORY
SELECT 
	p.category,
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2014 THEN sales ELSE 0 END) AS sales_2014,
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2015 THEN sales ELSE 0 END) AS sales_2015,
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2016 THEN sales ELSE 0 END) AS sales_2016,
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2017 THEN sales ELSE 0 END) AS sales_2017,
  	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2018 THEN sales ELSE 0 END) AS sales_2018,
  	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2019 THEN sales ELSE 0 END) AS sales_2019
FROM orders AS o
JOIN products AS p 
ON o.product_id = p.product_id 
GROUP BY p.category;

-- CUSTOMER YEARLY SALES SUMMARY
SELECT 
	c.customer_name,
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2014 THEN sales ELSE 0 END) AS sales_2014,
    SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2015 THEN sales ELSE 0 END) AS sales_2015,
    SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2016 THEN sales ELSE 0 END) AS sales_2016,
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2017 THEN sales ELSE 0 END) AS sales_2017,
  	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2018 THEN sales ELSE 0 END) AS sales_2018,
	SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2019 THEN sales ELSE 0 END) AS sales_2019,
	SUM(sales) AS revenue
FROM orders AS o 
JOIN customers AS c 
ON c.customer_id  = o.customer_id
GROUP BY c.customer_name
ORDER BY revenue DESC
LIMIT 10;

-- PROFITABILITY INSIGHTS

-- KEY METRICS
SELECT 
	SUM(o.profit) AS total_profit,
	SUM(o.sales * o.discount_percent) / SUM(o.sales) * 100 AS average_discount_rate,
	SUM(o.profit) - SUM(o.sales * o.discount_percent) AS net_profit_after_discount,
	(SUM(sales) - SUM(cogs) )/SUM(sales) *100 AS gross_profit_margin
FROM orders AS o;

-- YEARLY PROFIT, NET PROFIT
SELECT 
	TO_CHAR (o.order_date, 'YYYY') AS years,
	(SUM(sales) - SUM(cogs) )/SUM(sales) *100 AS gross_profit_margin,
	SUM(o.profit) AS total_profit, SUM(o.profit) - SUM(o.sales * o.discount_percent) AS net_profit_after_discount,
	SUM(o.sales * o.discount_percent) / SUM(o.sales) * 100 AS average_discount_rate
FROM orders AS o
GROUP BY years
ORDER BY years;

-- PRODUCT CATEGORY PERFORMANCE METRICS
SELECT
	p.category,
	SUM(o.sales) AS revenue,
    SUM(o.profit) AS total_profit,
    SUM(o.sales * o.discount_percent) / SUM(o.sales) * 100 AS average_discount_rate,
    SUM(o.sales * o.discount_percent) AS total_discount_amount,
    SUM(o.profit) - SUM(o.sales * o.discount_percent) AS net_profit_after_discount
FROM orders AS o
JOIN products AS p
ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY net_profit_after_discount;

-- FURNITURE DISCOUNT IMPACT ANALYSIS BY SUB-CATEGORY
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
