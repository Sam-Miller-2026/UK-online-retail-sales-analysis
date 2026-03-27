-- ================================================
-- Online Retail Sales Analysis
-- Author: Sam Miller
-- Dataset: UCI Online Retail II (2009-2011)
-- Tool: MySQL Workbench 8.0
-- Database: retail_analysis
-- ================================================

-- DATABASE SETUP
CREATE DATABASE retail_analysis;
USE retail_analysis;

-- Create transactions table
CREATE TABLE transactions (
    Invoice VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate VARCHAR(50),
    Price DECIMAL(10,2),
    `Customer ID` VARCHAR(20),
    Country VARCHAR(100),
    Revenue DECIMAL(10,2),
    Month INT,
    Year INT,
    CustomerTier VARCHAR(20)
);

-- Create country to region lookup table
CREATE TABLE country_region (
    Region VARCHAR(100),
    Country VARCHAR(100)
);

-- Load data from CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Invoice, StockCode, Description, Quantity, InvoiceDate, 
Price, `Customer ID`, Country, Revenue, Month, Year, CustomerTier);

-- Region data
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/country_region.csv'
INTO TABLE country_region
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Region, Country);

-- Verify row count (expected: ~805,620)
SELECT COUNT(*) FROM transactions;
SELECT COUNT(*) FROM country_region;

-- ================================================
-- ANALYTICAL QUERIES
-- ================================================

-- Q1: High-level snapshot
-- What is the scale of this business?
SELECT
    COUNT(DISTINCT Invoice)         AS total_orders,
    COUNT(DISTINCT `Customer ID`)   AS unique_customers,
    ROUND(SUM(Revenue), 2)          AS total_revenue,
    ROUND(AVG(Revenue), 2)          AS avg_order_value
FROM transactions;



-- Q2: Monthly revenue trend
-- Is revenue growing year over year, and which months are strongest?

SELECT
    Year,
    Month,
    ROUND(SUM(Revenue), 2)          AS monthly_revenue,
    COUNT(DISTINCT Invoice)          AS order_count
FROM transactions
GROUP BY Year, Month
ORDER BY monthly_revenue DESC;



-- Q3: Product performance
-- Which products drive the most revenue?
-- Excluding non-product rows (Postage, Manual) from product analysis
-- These are operational entries, not sellable products

SELECT
	StockCode,
    Description,
    ROUND(SUM(Revenue),2) as total_revenue,
    SUM(Quantity) as total_units_sold,
    ROUND(AVG(price),2) as avg_price
FROM transactions
WHERE Description NOT IN ('Postage', 'Manual')
GROUP BY StockCode, DESCRIPTION
ORDER BY total_revenue DESC
LIMIT 20;



-- Q4: Geographic revenue breakdown
-- What share of revenue does each country contribute?

SELECT
    Country,
    ROUND(SUM(Revenue), 2)                  AS country_revenue,
    ROUND(
        SUM(Revenue) * 100.0 / SUM(SUM(Revenue)) OVER ()
    , 2)                                    AS pct_of_total
FROM transactions
GROUP BY Country
ORDER BY country_revenue DESC;



-- Q5: Regional performance
-- How does revenue break down by world region?

WITH cleaned_transactions AS (
    SELECT 
        TRIM(REPLACE(REPLACE(LOWER(Country), '\r', ''), '\n', '')) AS country,
        Revenue,
        Invoice,
        `Customer ID`
    FROM transactions
),
cleaned_country_region AS (
    SELECT 
        TRIM(REPLACE(REPLACE(LOWER(Country), '\r', ''), '\n', '')) AS country,
        Region
    FROM country_region
)
SELECT
    cr.Region,
    ROUND(SUM(t.Revenue), 2) AS regional_revenue,
    COUNT(DISTINCT t.Invoice) AS order_count,
    COUNT(DISTINCT t.`Customer ID`) AS customer_count
FROM cleaned_transactions t
JOIN cleaned_country_region cr 
  ON t.country = cr.Country
GROUP BY cr.Region
ORDER BY regional_revenue DESC;



-- Q6: Customer lifetime value
-- Who are the most valuable customers and how often do they buy?

SELECT
    `Customer ID`,
    COUNT(DISTINCT Invoice)             AS total_orders,
    ROUND(SUM(Revenue), 2)             AS lifetime_revenue,
    ROUND(AVG(Revenue), 2)             AS avg_order_value,
    COUNT(DISTINCT StockCode)           AS unique_products_bought
FROM transactions
GROUP BY `Customer ID`
ORDER BY lifetime_revenue DESC
LIMIT 50;



-- Q7: High volume, low value products
-- Which products sell a lot of units but generate little revenue?
-- These are candidates for pricing review or discontinuation.
-- Excluding non-product rows (Postage, Manual) from product analysis
-- These are operational entries, not sellable products

SELECT
    Description,
    SUM(Quantity)               AS units_sold,
    ROUND(SUM(Revenue), 2)     AS total_revenue,
    ROUND(AVG(Price), 2)       AS avg_price
FROM transactions
WHERE Description NOT IN ('Postage', 'Manual')
GROUP BY Description
HAVING SUM(Quantity) > 1000
   AND ROUND(AVG(Price), 2) < 1.00
ORDER BY units_sold DESC
LIMIT 20;



-- Q8: Month-over-month revenue trend
-- Is the business accelerating or decelerating each month?

WITH monthly as (
	SELECT
		Year,
        Month,
        ROUND(SUM(revenue),2) as monthly_revenue
	from transactions
    GROUP BY Year, Month
)
SELECT
    Year,
    Month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY Year, Month) AS prior_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY Year, Month)) * 100.0
        / LAG(monthly_revenue) OVER (ORDER BY Year, Month)
    , 1) AS mom_change_pct
FROM monthly
ORDER BY Year, Month;



-- Q9: Customer recency segmentation
-- Classify customers by how recently they purchased
-- relative to the last date in the dataset.

WITH last_purchase AS (
    SELECT
        `Customer ID`,
        MAX(InvoiceDate)                AS most_recent_purchase,
        ROUND(SUM(Revenue), 2)         AS lifetime_revenue,
        COUNT(DISTINCT Invoice)         AS total_orders
    FROM transactions
    GROUP BY `Customer ID`
),
dataset_end AS (
    SELECT MAX(InvoiceDate) AS end_date FROM transactions
)
SELECT
    lp.`Customer ID`,
    lp.most_recent_purchase,
    lp.lifetime_revenue,
    lp.total_orders,
    CASE
        WHEN DATEDIFF(de.end_date, lp.most_recent_purchase) <= 90
            THEN 'Active'
        WHEN DATEDIFF(de.end_date, lp.most_recent_purchase) <= 180
            THEN 'Lapsed'
        ELSE 'Churned'
    END AS customer_status
FROM last_purchase lp
CROSS JOIN dataset_end de
ORDER BY lp.lifetime_revenue DESC;



-- Q10: Best-selling product in each country
-- Which product generates the most revenue in each country?
-- Excluding non-product rows (Postage, Manual) from product analysis
-- These are operational entries, not sellable products

WITH product_by_country AS (
    SELECT
        Country,
        Description,
        ROUND(SUM(Revenue), 2)                                          AS revenue,
        RANK() OVER (PARTITION BY Country ORDER BY SUM(Revenue) DESC)   AS country_rank
    FROM transactions
    WHERE Description NOT IN ('Postage', 'Manual')
    GROUP BY Country, Description
)
SELECT
    Country,
    Description,
    revenue
FROM product_by_country
WHERE country_rank = 1
ORDER BY revenue DESC;