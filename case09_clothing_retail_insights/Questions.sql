select * from dt.sales;
select * from dt.product_details;

-- A. High Level Sales Analysis

-- 1. Total quantity sold for all products
SELECT SUM(qty) AS total_quantity_sold
FROM dt.sales;

-- 1. Total quantity sold for each product
SELECT product_id, product_name, SUM(qty) AS total_quantity_sold
FROM dt.product_details pd
JOIN dt.sales s ON pd.product_id = s.prod_id
GROUP BY product_id, product_name;

-- 2. Total generated revenue for all products before discounts
SELECT SUM(qty * price) AS total_revenue
FROM dt.sales;

-- 3. Total discount amount for all products
SELECT SUM(ROUND((qty * price) / CAST(100 AS FLOAT), 4) * discount) AS total_discount_amount
FROM dt.sales;

-- B. Transaction Analysis

-- 1. Number of unique transactions
SELECT COUNT(DISTINCT txn_id) AS unique_transactions
FROM dt.sales;

-- 2. Average unique products purchased in each transaction
SELECT AVG(uniq_product) AS average
FROM (
    SELECT txn_id, COUNT(DISTINCT prod_id) AS uniq_product
    FROM dt.sales
    GROUP BY txn_id
) t;

-- 3. 25th, 50th, and 75th percentile values for revenue per transaction
-- Note: SQL Server does not have a direct percentile function; this requires a custom approach
WITH t AS (
    SELECT txn_id, SUM((qty * price) - ((qty * price) / CAST(100 AS FLOAT) * discount)) AS revenue
    FROM dt.sales
    GROUP BY txn_id
),
ordered_revenue AS (
    SELECT revenue,
           NTILE(100) OVER (ORDER BY revenue) AS percentile
    FROM t
)
SELECT 
    MAX(CASE WHEN percentile <= 25 THEN revenue END) AS p25,
    MAX(CASE WHEN percentile <= 50 THEN revenue END) AS p50,
    MAX(CASE WHEN percentile <= 75 THEN revenue END) AS p75
FROM ordered_revenue;

-- 4. Average discount value per transaction
SELECT AVG(discount) AS average
FROM (
    SELECT txn_id, discount
    FROM dt.sales
    GROUP BY txn_id, discount
) t;

-- 5. Percentage split of transactions for members vs non-members
SELECT 
    ROUND(COUNT(DISTINCT CASE WHEN member = 1 THEN txn_id END) / CAST(COUNT(DISTINCT txn_id) AS FLOAT), 4) * 100 AS members,
    ROUND(COUNT(DISTINCT CASE WHEN member = 0 THEN txn_id END) / CAST(COUNT(DISTINCT txn_id) AS FLOAT), 4) * 100 AS non_members
FROM dt.sales;

-- 6. Average revenue for member and non-member transactions
SELECT 
    CASE member WHEN 1 THEN 'member transactions' ELSE 'non-member transactions' END AS transactions,
    AVG((qty * price) - ((qty * price) / CAST(100 AS FLOAT) * discount)) AS average_revenue
FROM dt.sales
GROUP BY member;

-- C. Product Analysis

-- 1. Top 3 products by total revenue before discount
SELECT TOP 3 s.prod_id, p.product_name, SUM(s.price * qty) AS total_revenue
FROM dt.sales s
JOIN dt.product_details p ON s.prod_id = p.product_id
GROUP BY prod_id, p.product_name
ORDER BY total_revenue DESC;

-- 2. Total quantity, revenue, and discount for each segment
SELECT 
    p.segment_id, segment_name, 
    SUM(qty) AS total_quantity,
    SUM((qty * s.price) - ((qty * s.price) / CAST(100 AS FLOAT) * discount)) AS total_revenue,
    SUM((qty * s.price) / CAST(100 AS FLOAT) * discount) AS total_discount,
    SUM(qty * s.price) AS total_amount
FROM dt.product_details p
JOIN dt.sales s ON p.product_id = s.prod_id
GROUP BY p.segment_id, segment_name;

-- 3. Top selling product for each segment
WITH t AS (
    SELECT 
        p.segment_id, segment_name, prod_id, product_name, SUM(qty) AS total_quantity,
        ROW_NUMBER() OVER (PARTITION BY segment_id ORDER BY SUM(qty) DESC) AS rn
    FROM dt.product_details p
    JOIN dt.sales s ON p.product_id = s.prod_id
    GROUP BY p.segment_id, segment_name, prod_id, product_name
)
SELECT segment_id, segment_name, product_name
FROM t
WHERE rn = 1;

-- 4. Total quantity, revenue, and discount for each category
SELECT 
    p.category_id, p.category_name, 
    SUM(qty) AS total_quantity,
    SUM((qty * s.price) - ((qty * s.price) / CAST(100 AS FLOAT) * discount)) AS total_revenue,
    SUM((qty * s.price) / CAST(100 AS FLOAT) * discount) AS total_discount,
    SUM(qty * s.price) AS total_amount
FROM dt.product_details p
JOIN dt.sales s ON p.product_id = s.prod_id
GROUP BY p.category_id, p.category_name;

-- 5. Top selling product for each category
WITH t AS (
    SELECT 
        p.category_id, p.category_name, prod_id, product_name, SUM(qty) AS total_quantity,
        ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY SUM(qty) DESC) AS rn
    FROM dt.product_details p
    JOIN dt.sales s ON p.product_id = s.prod_id
    GROUP BY p.category_id, p.category_name, prod_id, product_name
)
SELECT category_id, category_name, product_name
FROM t
WHERE rn = 1;

-- 6. Percentage split of revenue by product for each segment
WITH t AS (
    SELECT 
        p.segment_id, segment_name, prod_id, product_name,
        SUM((qty * s.price) - ((qty * s.price) / CAST(100 AS FLOAT) * discount)) AS total_revenue_p,
        SUM(SUM((qty * s.price) - ((qty * s.price) / CAST(100 AS FLOAT) * discount))) OVER (PARTITION BY segment_id) AS total
    FROM dt.product_details p
    JOIN dt.sales s ON p.product_id = s.prod_id
    GROUP BY p.segment_id, segment_name, prod_id, product_name
)
SELECT segment_id, segment_name, product_name, ROUND((total_revenue_p / total), 4) * 100 AS percentage
FROM t;

-- 7. Percentage split of revenue by segment for each category
WITH t AS (
    SELECT 
        p.category_id, p.category_name, p.segment_id, p.segment_name,
        SUM((qty * s.price) - ((qty * s.price) / CAST(100 AS FLOAT) * discount)) AS total_revenue_p,
        SUM(SUM((qty * s.price) - ((qty * s.price) / CAST(100 AS FLOAT) * discount))) OVER (PARTITION BY category_id) AS total
    FROM dt.product_details p
    JOIN dt.sales s ON p.product_id = s.prod_id
    GROUP BY p.category_id, p.category_name, p.segment_id, p.segment_name
)
SELECT category_id, category_name, segment_name, ROUND((total_revenue_p / total), 4) * 100 AS percentage
FROM t;

-- 8. Percentage split of total revenue by category
WITH t AS (
    SELECT 
        category_id, category_name,
        SUM((qty * s.price) - ((qty * s.price) / CAST(100 AS FLOAT) * discount)) AS total_revenue
    FROM dt.product_details p
    JOIN dt.sales s ON p.product_id = s.prod_id
    GROUP BY category_id, category_name
)
SELECT category_name, ROUND((total_revenue / SUM(total_revenue) OVER ()), 4) * 100 AS Percentage
FROM t;

-- 9. Total transaction penetration for each product
SELECT 
    prod_id,
    COUNT(DISTINCT txn_id) / CAST((SELECT COUNT(DISTINCT txn_id) FROM dt.sales) AS FLOAT) * 100 AS penetration
FROM dt.sales
GROUP BY prod_id;

-- 10. Most common combination of at least 1 quantity of any 3 products in a single transaction
WITH t AS (
    SELECT txn_id, prod_id, SUM(qty) AS quan
    FROM dt.sales
    GROUP BY txn_id, prod_id
),
combinations AS (
    SELECT 
        t1.txn_id,
        t1.prod_id AS prod1, p1.product_name AS name1,
        t2.prod_id AS prod2, p2.product_name AS name2,
        t3.prod_id AS prod3, p3.product_name AS name3
    FROM t t1
    JOIN t t2 ON t1.txn_id = t2.txn_id AND t1.prod_id < t2.prod_id
    JOIN t t3 ON t2.txn_id = t3.txn_id AND t2.prod_id < t3.prod_id
    JOIN dt.product_details p1 ON t1.prod_id = p1.product_id
    JOIN dt.product_details p2 ON t2.prod_id = p2.product_id
    JOIN dt.product_details p3 ON t3.prod_id = p3.product_id
    WHERE t1.quan > 0 AND t2.quan > 0 AND t3.quan > 0
)
SELECT TOP 1 name1, name2, name3, COUNT(*) AS frequency
FROM combinations
GROUP BY name1, name2, name3
ORDER BY frequency DESC;