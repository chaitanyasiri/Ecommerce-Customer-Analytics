-- ============================================================
-- E-COMMERCE CUSTOMER ANALYTICS
-- SQL / MySQL ANALYSIS
-- ============================================================

-- Database
CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;


-- ============================================================
-- 1. DATASET OVERVIEW
-- ============================================================

SELECT COUNT(*) AS total_records
FROM ecommerce;


-- Check distinct customers and orders
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce;


-- ============================================================
-- 2. DATA QUALITY CHECKS
-- ============================================================

-- Check NULL values
SELECT
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(revenue_inr IS NULL) AS missing_revenue,
    SUM(order_date IS NULL) AS missing_order_date
FROM ecommerce;


-- Check duplicate Order IDs
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM ecommerce
GROUP BY order_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(revenue_inr), 2) AS total_revenue,
    ROUND(
        SUM(revenue_inr) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM ecommerce;


-- ============================================================
-- 4. REVENUE BY CUSTOMER SEGMENT
-- ============================================================

SELECT
    customer_segment,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(revenue_inr), 2) AS revenue
FROM ecommerce
GROUP BY customer_segment
ORDER BY revenue DESC;


-- ============================================================
-- 5. REVENUE BY PRODUCT CATEGORY
-- ============================================================

SELECT
    product_category,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(revenue_inr), 2) AS revenue
FROM ecommerce
GROUP BY product_category
ORDER BY revenue DESC;


-- ============================================================
-- 6. REGIONAL PERFORMANCE
-- ============================================================

SELECT
    region,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(revenue_inr), 2) AS revenue
FROM ecommerce
GROUP BY region
ORDER BY revenue DESC;


-- ============================================================
-- 7. SALES CHANNEL PERFORMANCE
-- ============================================================

SELECT
    sales_channel,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(revenue_inr), 2) AS revenue,
    ROUND(
        SUM(revenue_inr) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM ecommerce
GROUP BY sales_channel
ORDER BY revenue DESC;


-- ============================================================
-- 8. ORDER STATUS ANALYSIS
-- ============================================================

SELECT
    order_status,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(revenue_inr), 2) AS revenue
FROM ecommerce
GROUP BY order_status
ORDER BY orders DESC;


-- ============================================================
-- 9. NEW VS RETURNING CUSTOMERS
-- ============================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM ecommerce
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN 'New Customer'
        WHEN order_count > 1 THEN 'Returning Customer'
    END AS customer_type,
    COUNT(*) AS customers
FROM customer_orders
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'New Customer'
        WHEN order_count > 1 THEN 'Returning Customer'
    END
ORDER BY customers DESC;


-- ============================================================
-- 10. TOP 10 CUSTOMERS BY REVENUE
-- ============================================================

SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(revenue_inr), 2) AS total_revenue
FROM ecommerce
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 11. CUSTOMER REVENUE RANKING
-- ============================================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(revenue_inr) AS total_revenue
    FROM ecommerce
    GROUP BY customer_id
)

SELECT
    customer_id,
    ROUND(total_revenue, 2) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank;


-- ============================================================
-- 12. CUSTOMER VALUE SEGMENTATION
-- ============================================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(revenue_inr) AS total_revenue
    FROM ecommerce
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN total_revenue >= 100000 THEN 'High Value Customer'
        WHEN total_revenue >= 50000 THEN 'Medium Value Customer'
        ELSE 'Low Value Customer'
    END AS customer_value_segment,
    COUNT(*) AS customers,
    ROUND(SUM(total_revenue), 2) AS revenue
FROM customer_revenue
GROUP BY
    CASE
        WHEN total_revenue >= 100000 THEN 'High Value Customer'
        WHEN total_revenue >= 50000 THEN 'Medium Value Customer'
        ELSE 'Low Value Customer'
    END
ORDER BY revenue DESC;


-- ============================================================
-- 13. MONTHLY REVENUE TREND
-- ============================================================

SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    DATE_FORMAT(order_date, '%Y-%m') AS month_name,
    ROUND(SUM(revenue_inr), 2) AS monthly_revenue
FROM ecommerce
GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    DATE_FORMAT(order_date, '%Y-%m')
ORDER BY year, month;


-- ============================================================
-- 14. MONTH-OVER-MONTH REVENUE CHANGE
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(revenue_inr) AS revenue
    FROM ecommerce
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        LAG(revenue) OVER (ORDER BY month),
        2
    ) AS previous_month_revenue,
    ROUND(
        (
            revenue -
            LAG(revenue) OVER (ORDER BY month)
        )
        /
        NULLIF(
            LAG(revenue) OVER (ORDER BY month),
            0
        ) * 100,
        2
    ) AS mom_growth_percentage
FROM monthly_revenue
ORDER BY month;


-- ============================================================
-- 15. TOP PRODUCT CATEGORIES BY REVENUE
-- ============================================================

WITH category_revenue AS (
    SELECT
        product_category,
        SUM(revenue_inr) AS revenue
    FROM ecommerce
    GROUP BY product_category
)

SELECT
    product_category,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS category_rank
FROM category_revenue
ORDER BY category_rank;


-- ============================================================
-- 16. REGION REVENUE CONTRIBUTION
-- ============================================================

WITH region_revenue AS (
    SELECT
        region,
        SUM(revenue_inr) AS revenue
    FROM ecommerce
    GROUP BY region
)

SELECT
    region,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue /
        SUM(revenue) OVER () * 100,
        2
    ) AS revenue_contribution_percentage
FROM region_revenue
ORDER BY revenue DESC;


-- ============================================================
-- 17. HIGH-VALUE CUSTOMERS
-- ============================================================

SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(revenue_inr), 2) AS total_revenue
FROM ecommerce
GROUP BY customer_id
HAVING SUM(revenue_inr) >= 100000
ORDER BY total_revenue DESC;


-- ============================================================
-- 18. CUSTOMERS WITH HIGH PURCHASE FREQUENCY
-- ============================================================

SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(SUM(revenue_inr), 2) AS revenue
FROM ecommerce
GROUP BY customer_id
HAVING COUNT(DISTINCT order_id) >= 5
ORDER BY order_count DESC, revenue DESC;


-- ============================================================
-- 19. PAYMENT METHOD ANALYSIS
-- ============================================================

SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(revenue_inr), 2) AS revenue
FROM ecommerce
GROUP BY payment_method
ORDER BY revenue DESC;


-- ============================================================
-- 20. BUSINESS SUMMARY
-- ============================================================

SELECT
    'E-Commerce Customer Analytics' AS analysis,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(revenue_inr), 2) AS total_revenue,
    ROUND(
        SUM(revenue_inr) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM ecommerce;
