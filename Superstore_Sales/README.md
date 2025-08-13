# Superstore Sales Performance (2014-2019)

### Introduction
This project involved a comprehensive financial analysis of the Superstore dataset. The primary objective was to investigate the significant decline in sales observed during the final two years of the period.

---

### Tools Used
* **Excel**: For initial data preparation and cleaning.
* **PostgreSQL**: For database creation, data loading, and querying.
* **Power BI**: For data visualizations.

---

### Project Steps

The following steps were performed to clean the raw data and load it into a PostgreSQL database:

1.  **Data Cleaning & Segmentation:** The raw dataset was processed using **Power Query in Excel** to remove duplicates, standardize data, and split the information into four(4) logical sheets: `orders`, `products`, `customer_addresses`, and `customers`.
2.  **Database Creation:** A new database named `superstore` was created in **PostgreSQL**.
3.  **Data Loading:** The four cleaned Excel sheets were loaded as tables into the `superstore` database. The tables were named `orders`, `products`,  `customer_addresses`, and `customers` to reflect their contents.

---

### OVERVIEW

### Key Metrics:
* **Total Revenue** - $2,297,201.07
* **Total Profit** - $286,397.79
* **Total Cost** - $2,010,803.28
* **Product Count**  - 1,862
* **Total Qty Ordered** - 37,873
* **Total No of Customers Across the Years** - 793

#### YEARLY DEVIATION
```SQL
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
```
![YoY Sales Analysis](Images/YoY.png)

* **Growth Phase (2015-2017):** Sales grew steadily and rapidly. In 2015, sales more than doubled, showing a massive 108.48% year-over-year growth. Growth slowed to 51.96% in 2016 and further to 6.04% in 2017, but sales still reached their peak.
* **Decline Phase (2018-2019):** After 2017, the trend reversed dramatically. Sales saw a substantial drop of -24.32% in 2018. The decline accelerated into 2019, with sales plummeting by -73.05%, reaching their lowest point in the dataset.

#### REGIONAL SALES ACROSS THE YEARS
``` SQL
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
```
![Regional Sales Analysis](Images/Region.png)

* West: This region was the top performer in 2017 but saw the largest absolute sales drop, with a decrease of over $1,153,000 by 2019.
* South: This region experienced the most significant percentage decrease, with sales dropping by 73.1% from 2017 to 2019.
* East: While sales declined, the East region showed the most resilience, with the smallest absolute and percentage drop. Sales in this region only dropped by 5.5% between 2017 and 2018.
* Central: Sales in the Central region also declined substantially, dropping by 81.8% from 2017 to 2019.

####  TOP 10 CUSTOMER BY TOTAL REVENUE
``` SQL
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
```
![Top 20 Customers and their sales data](Images/Customers.png)

* **Significant Customer Churn:** Several key customers who had high sales in 2017, such as Sean Miller, Tamara Chand,
and  Adrian Barton, had little to no sales in the final years of the dataset. This indicates a significant loss of business from the most important clients.
* **Widespread Decline:** The trend is widespread, affecting most of the top 10 customers. The combined sales from these customers, which were substantial in the years prior, dropped precipitously, mirroring the overall company-wide trend.

---

### PROFITABILITY ANALYSIS

### KEY METRICS
* **Total Profit** - $286,397.79
* **Gross Profit Margin** - 12.46%
* **Avg Discount Rate** - 14.04%
* **Total Net Profit After Discount** - $(-36,184.45)

Discrepancies in core financial indicators reveal that while the company's gross profit margin is healthy, extensive high-volume discounting is negatively impacting the final net profit after discounts.
```SQL
SELECT 
	TO_CHAR (o.order_date, 'YYYY') AS years,
	(SUM(sales) - SUM(cogs) )/SUM(sales) *100 AS gross_profit_margin,
	SUM(o.profit) AS total_profit, SUM(o.profit) - SUM(o.sales * o.discount_percent) AS net_profit_after_discount,
	SUM(o.sales * o.discount_percent) / SUM(o.sales) * 100 AS average_discount_rate
FROM orders AS o
GROUP BY TO_CHAR (o.order_date, 'YYYY')
ORDER BY TO_CHAR (o.order_date, 'YYYY');
```
![Net profits after discount](Images/Net_Profit.png)

I decided to run further queries to find out which product categories have the highest discount rates and are contributing the most to this loss.

### PRODUCT CATEGORY PERFORMANCE METRICS
```SQL
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
```
![Breakdown of the profit and discount values by product_category](Images/Products_Check.png)
 
**Key Observations 💡**
* The **Furniture category** is the primary driver of the company's net loss, generating a total profit of $18,451.25.
* However, the total discount amount applied to this category was a massive $123,516.60.
* This disparity resulted in a net loss of -$105,065.35 for the furniture category alone.
* The Technology and Office Supplies categories are both profitable even after considering discounts. The net loss is entirely concentrated in the Furniture category.

### FURNITURE DISCOUNT IMPACT ANALYSIS
```
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
```
![Pinpointing the exact source of the losses](Images/Sub_Check.png)

The sub-category results reveal that most of these products were sold at a loss from the start.Tables and Bookcases are the biggest contributors to the losses within the Furniture category.

**Key Observations 🧐**
* The Tables sub-category has the highest total discount amount ($44,192.26) and a total negative profit of (-$17,725.59)
* Bookcases also have a negative profit before discounts (-$3,472.56), compounding the problem.
* Chairs show a profit before discounts ($26,590.15), but the heavy discounts ($49,814.82) turn it into a loss.
* Only Furnishings is profitable, both before and after discounts.

---

### Conclusion
The company's significant decline in sales and profitability is a result of two major, interconnected issues identified through a deep-dive analysis.

1. Profitability and Product Strategy
A detailed examination of sales and profit margins revealed that the Furniture category is the primary driver of the company’s net loss. Specifically, the analysis found that:
* Tables and Bookcases are fundamentally unprofitable products, as they are sold at a loss even before discounts.
* Chairs are made unprofitable due to an aggressive and unsustainable discounting strategy.

2. Widespread Customer Churn
A separate analysis of customer trends showed a critical loss of business from key customers. This widespread decline, which mirrored the overall company trend, was characterized by:
* Significant churn among key customers who had high sales in 2017 but had little to no sales in subsequent years.
* A precipitous drop in combined sales from the top 20 customers between 2017 and 2019.
* The positive sales trends from a few outlier customers were not enough to offset the overall decline.

---

### Recommendations

1. Product Strategy & Pricing
* Rethink Pricing for Tables and Bookcases: These products are sold at a loss before discounts. Conduct a full review of their pricing model and costs to determine if they can be made profitable. If not, consider phasing them out.
* Revise Discounting for Chairs: The current discounting strategy on chairs is unsustainable. I advise implementing a new policy that caps discounts to ensure a minimum profit margin is maintained.
* Leverage Profitable Products: Identify the profitable sub-categories like Furnishings and develop a strategy to increase sales of these items.

2. Customer Retention & Sales
* Investigate Customer Churn: Conduct an in-depth analysis or reach out to former high-volume customers to understand why they stopped purchasing. The insights gained can inform a new retention strategy.
* Implement a Customer Retention Plan: Focus sales efforts on retaining and growing relationships with the most valuable customers. Consider loyalty programs or dedicated account managers for key clients.
* Study Successful Outliers: Analyze the sales data and engagement patterns of the few customers who showed growth. Replicate the strategies that worked for them to re-engage other declining accounts.
