-- CREATING A DATABASE
CREATE DATABASE sales;

-- USING THE DATABASE
USE sales;

-- CREATING A TABLE
CREATE TABLE retail_sales
(
transactions_id	INT PRIMARY KEY,
sale_date DATE,
sale_time TIME,
customer_id	INT,
gender VARCHAR(15),
age	INT,
category VARCHAR(255),
quantity INT,	
price_per_unit FLOAT,
cogs FLOAT,
total_sale FLOAT
);

-- LOOKING AT THE TABLE
SELECT * FROM retail_sales
LIMIT 5;

-- COUNTING THE ROWS
SELECT COUNT(*) FROM retail_sales;

-- SEEING NULL VALUES
SELECT * FROM retail_sales
WHERE transactions_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
OR age IS NULL
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;

-- DELETING NULL ROWS
DELETE FROM retail_sales
WHERE transactions_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
OR age IS NULL
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;

-- DATA EXPLORATION
-- HOW MANY SALES WE HAVE?
SELECT COUNT(*) AS total_sales 
FROM retail_sales;

-- HOW MANY UNIQUE CUSTOMERS DO WE HAVE?
SELECT COUNT(DISTINCT customer_id) AS total_customer 
FROM retail_sales;

-- HOW MANY CATEGORY DO WE HAVE?
SELECT COUNT(DISTINCT category) AS category 
FROM retail_sales;

SELECT DISTINCT category 
FROM retail_sales;

-- DATA ANALYSIS
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT * 
FROM retail_sales
WHERE category = 'Clothing' 
AND sale_date LIKE '2022-11%'
AND quantity >= 4;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category, 
SUM(total_sale) AS total_sales,
COUNT(*) as total_orders
FROM retail_sales
GROUP BY category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT ROUND(AVG(age),2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail_sales
WHERE total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT category,
gender,
COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY gender;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT year, 
month, 
ROUND(avg_sale,2)
FROM
(
SELECT
EXTRACT(YEAR FROM sale_date) AS year,
EXTRACT(MONTH FROM sale_date) AS month,
AVG(total_sale) AS avg_sale,
RANK() 
OVER(PARTITION BY EXTRACT(YEAR FROM sale_date)
ORDER BY AVG(total_sale) DESC) AS rnk
FROM retail_sales
GROUP BY YEAR, MONTH
) T
WHERE rnk = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT customer_id,
SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT CATEGORY, 
COUNT(DISTINCT customer_id) AS unique_customer
FROM retail_sales
GROUP BY 1;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
WITH hour_sale AS
(
SELECT *,
CASE 
WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
ELSE 'Evening'
END AS shift
FROM retail_sales
)
SELECT shift, COUNT(*) AS total_orders
FROM hour_sale
GROUP BY 1;

-- Q.11 Find total revenue and total profit
SELECT 
    SUM(total_sale) AS total_revenue,
    SUM(total_sale - cogs) AS total_profit
FROM retail_sales;

-- Q.12 Profit Margin
SELECT 
    ROUND(
        (SUM(total_sale - cogs) / SUM(total_sale)) * 100, 2) AS profit_margin_percent
FROM retail_sales;

-- Q.13 Monthly Revenue Trend
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    SUM(total_sale) AS monthly_revenue
FROM retail_sales
GROUP BY year, month
ORDER BY year, month;

-- Q.14 Best selling category by Revenue
SELECT category,
SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;

-- Q.15 Profit by Category
SELECT category,
SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;

-- Q.16 Average order value
SELECT 
ROUND(AVG(total_sale), 2) AS avg_order_value
FROM retail_sales;

-- Q.17 Repeated Customers
SELECT customer_id, 
COUNT(*) AS total_orders
FROM retail_sales
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY 2 DESC;

-- Q.18 Peak sale hour
SELECT 
EXTRACT(HOUR FROM sale_time) AS sale_hour,
SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY sale_hour
ORDER BY total_revenue DESC
LIMIT 1;

-- Q.19 Average spending by age group
SELECT 
CASE 
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 45 THEN '36-45'
    WHEN age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
END AS age_group,
ROUND(AVG(total_sale), 2) AS avg_spending
FROM retail_sales
GROUP BY age_group
ORDER BY avg_spending DESC;

-- Q.20 Year-over-year revenue growth
SELECT 
year,
SUM(total_sale) AS total_revenue,
LAG(SUM(total_sale)) OVER (ORDER BY year) AS prev_year_revenue,
ROUND(
    (SUM(total_sale) - LAG(SUM(total_sale)) OVER (ORDER BY year)) 
    / LAG(SUM(total_sale)) OVER (ORDER BY year) * 100,
    2
) AS yoy_growth_percent
FROM
(
    SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    total_sale
    FROM retail_sales
) t
GROUP BY year;

-- END OF PROJECT ANALYSIS