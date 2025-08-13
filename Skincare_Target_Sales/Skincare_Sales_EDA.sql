-- SKINCARE TARGET ANALYSIS

-- Key Metrics

-- Total Revenue (2022-2024)
SELECT SUM(st.sales) AS revenue
FROM skincare_target AS st;

-- Total Qty Sold (2022-2024)
SELECT SUM(st.qty) AS qty_sold
FROM skincare_target AS st;


-- SALES PERFORMANCE

-- Year over Year Sales Variance
WITH annual_sales AS (
  SELECT TO_CHAR(st.order_date, 'YYYY') AS years, 
  SUM(st.sales) AS yearly_revenue
  FROM skincare_target AS st
  GROUP BY TO_CHAR(st.order_date, 'YYYY')
)
SELECT 
	annual_sales.years, 
	annual_sales.yearly_revenue,
  	LAG(yearly_revenue, 1) OVER (ORDER BY years) AS previous_year_sales,
  	yearly_revenue - LAG(yearly_revenue, 1) OVER (ORDER BY years) AS sales_variance,
  ((yearly_revenue - LAG(yearly_revenue, 1) OVER (ORDER BY years)) / LAG(yearly_revenue, 1) OVER (ORDER BY years)) * 100 AS sales_variance_percent
FROM annual_sales
ORDER BY years;

-- Monthly Sales Trend (2022-2024)
SELECT 
	TO_CHAR(st.order_date, 'MM') AS months,
	SUM(CASE WHEN TO_CHAR(st.order_date, 'YYYY') = '2022' THEN st.sales ELSE 0 END) AS sales_2022,
	SUM(CASE WHEN TO_CHAR(st.order_date, 'YYYY') = '2023' THEN st.sales ELSE 0 END) AS sales_2023,
	SUM(CASE WHEN TO_CHAR(st.order_date, 'YYYY') = '2024' THEN st.sales ELSE 0 END) AS sales_2024
FROM skincare_target AS st
GROUP BY months
ORDER BY months;


-- CUSTOMER INSIGHTS

-- Key Metrics

-- Total Number of Customers 
SELECT COUNT(DISTINCT st.customer_id) AS customer_count
FROM skincare_target AS st;

-- Customers per year
SELECT TO_CHAR(st.order_date, 'YYYY') AS years, 
  	COUNT(DISTINCT st.customer_id) AS customer_count
FROM skincare_target AS st
GROUP BY years
ORDER BY years;

-- Customers lost across the years
WITH yearly_customers AS (
    SELECT
        TO_CHAR(st.order_date, 'YYYY') AS years,
        COUNT(DISTINCT st.customer_id) AS customer_count
    FROM skincare_target AS st
    GROUP BY years
)
SELECT
    years, customer_count,
    LAG(customer_count, 1) OVER (ORDER BY years) AS previous_year_customers,
    customer_count - LAG(customer_count, 1) OVER (ORDER BY years) AS customer_change
FROM yearly_customers
ORDER BY years;

-- Top 10 customers by total sales
SELECT DISTINCT st.customer_id, SUM(st.qty) AS qty_bought, SUM(st.sales) AS total_sales
FROM skincare_target AS st
GROUP BY st.customer_id
ORDER BY total_sales DESC
LIMIT 10;

-- Which product category do the top customers buy the most?
SELECT st.customer_id, st.segment, st.category, SUM(st.qty) AS total_qty_bought
FROM skincare_target AS st
WHERE st.customer_id IN ('SP-20620102', 'KN-1645082', 'EH-1376527')
GROUP BY st.customer_id, st.segment, st.category
ORDER BY st.customer_id, total_qty_bought DESC;

-- Segments with the highest sales
SELECT st.segment, SUM(st.sales) AS revenue
FROM skincare_target AS st
GROUP BY st.segment
ORDER BY revenue DESC;


-- PROFIT ANALYSIS

-- Key Metrics

-- Total Profit
SELECT SUM(st.profit) AS profit
FROM skincare_target AS st;

-- Total COGS
SELECT SUM(st.cogs) AS cogs
FROM skincare_target AS st;

-- Gross Profit Margin
SELECT (SUM(sales) - SUM(cogs) )/SUM(sales) *100 AS gross_profit_margin
FROM skincare_target AS st;

-- Avg Discount Gross Margin
SELECT SUM(st.sales * st.discount_percent) / SUM(st.sales) * 100 AS avg_discount_rate
FROM skincare_target AS st;

-- Net profit after discount
SELECT SUM(st.profit) - SUM(st.sales * st.discount_percent) AS net_profit_after_discount
FROM skincare_target AS st;

-- YoY revenue, profit, number of products sold, avg_discount, and net profit afer discounts
SELECT 
	TO_CHAR(st.order_date, 'YYYY') AS years,
	SUM(st.sales) AS revenue,
	SUM(st.profit) AS profit,
	SUM(st.sales * st.discount_percent) / SUM(st.sales) * 100 AS avg_discount,
	SUM(st.profit) - SUM(st.sales * st.discount_percent) AS net_profit_after_discount
FROM skincare_target AS st
GROUP BY TO_CHAR(st.order_date, 'YYYY')
ORDER BY TO_CHAR(st.order_date, 'YYYY');


-- SALES PERFORMANCE BY LOCATIONS

-- Key Metrics
SELECT COUNT(DISTINCT st.country) AS number_of_countries
FROM skincare_target AS st;

-- Top Countries with the most sales
SELECT st.country, SUM(st.sales) AS total_sales, SUM(st.qty) AS total_qty_bought
FROM skincare_target AS st
GROUP BY st.country
ORDER BY total_sales DESC
LIMIT 10;

-- Avg discount rate for the most profitable countries and their net profit after discount
SELECT 
	st.country, 
	SUM(st.sales) AS revenue, 
	SUM(st.profit) AS profit,
	SUM(st.qty) AS qty_sold,
	AVG(st.discount_percent) * 100 AS avg_discount_rate_percent,
	SUM(st.profit) - SUM(st.sales * st.discount_percent) AS net_profit_after_discount
FROM skincare_target AS st
GROUP BY st.country
ORDER BY net_profit_after_discount DESC
LIMIT 10;

-- Least profitable countries
SELECT 
	st.country, 
	SUM(st.sales) AS revenue, 
	SUM(st.profit) AS profit,
	SUM(st.qty) AS qty_sold,
	AVG(st.discount_percent) * 100 AS avg_discount_rate_percent,
	SUM(st.profit) - SUM(st.sales * st.discount_percent) AS net_profit_after_discount
FROM skincare_target AS st
GROUP BY st.country
ORDER BY net_profit_after_discount
LIMIT 10;


-- PRODUCT AND SUB-CATEGORY PERFORMANCE

-- Key Metrics

-- No of Products (2022-2024)
SELECT COUNT(DISTINCT st.product_name) AS no_of_products
FROM skincare_target AS st;

-- No of Orders (2022-2024)
SELECT COUNT(DISTINCT st.order_id) AS order_count
FROM skincare_target AS st;

-- Number of products sold per product categories
SELECT 
	st.category,
	SUM(CASE WHEN TO_CHAR(st.order_date, 'YYYY') = '2022' THEN st.qty ELSE 0 END) AS qty_sold_2022,
	SUM(CASE WHEN TO_CHAR(st.order_date, 'YYYY') = '2023' THEN st.qty ELSE 0 END) AS qty_sold_2023,
	SUM(CASE WHEN TO_CHAR(st.order_date, 'YYYY') = '2024' THEN st.qty ELSE 0 END) AS qty_sold_2024
FROM skincare_target AS st
GROUP BY st.category;

-- Best performing product categories
SELECT 
	st.category,
	SUM(st.sales) AS revenue,
	SUM(st.profit) AS profit,
	SUM(st.sales * st.discount_percent) / SUM(st.sales) * 100 AS avg_discount,
	SUM(st.profit) - SUM(st.sales * st.discount_percent) AS net_profit_after_discount
FROM skincare_target AS st
GROUP BY st.category
ORDER BY net_profit_after_discount DESC;

-- Net profits of product subcategories after discounts per year
SELECT
    st.subcategory,
    SUM(CASE WHEN TO_CHAR(st.order_date, 'YYYY') = '2022' THEN (st.profit) - (st.sales * st.discount_percent) ELSE 0 END) AS net_profit_2022,
    SUM(CASE WHEN TO_CHAR(st.order_date, 'YYYY') = '2023' THEN (st.profit) - (st.sales * st.discount_percent) ELSE 0 END) AS net_profit_2023,
    SUM(CASE WHEN TO_CHAR(st.order_date, 'YYYY') = '2024' THEN (st.profit) - (st.sales * st.discount_percent) ELSE 0 END) AS net_profit_2024
FROM skincare_target AS st
GROUP BY st.subcategory;

-- Checking every product sub-category metrics
SELECT
    st.subcategory,
    SUM(st.sales) AS revenue,
    SUM(st.profit) AS total_profit,
    SUM(st.sales * st.discount_percent) AS total_discount_amount,
    SUM(st.profit) - SUM(st.sales * st.discount_percent) AS net_profit_after_discount
FROM skincare_target AS st
GROUP BY st.subcategory
ORDER BY net_profit_after_discount;

-- Drilling through sub-categories in Home and accesories and hair care category department
SELECT
    st.subcategory,
    SUM(st.sales) AS revenue,
    SUM(st.profit) AS total_profit,
    SUM(st.qty) AS qty_sold,
    SUM(st.sales * st.discount_percent) AS total_discount_amount,
    SUM(st.profit) - SUM(st.sales * st.discount_percent) AS net_profit_after_discount
FROM skincare_target AS st
WHERE st.category = 'Home and Accessories' OR st.subcategory = 'Hair care'
GROUP BY st.subcategory
ORDER BY net_profit_after_discount;