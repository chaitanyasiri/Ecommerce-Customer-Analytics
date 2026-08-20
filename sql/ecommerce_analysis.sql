-- ============================================================
-- E-COMMERCE CUSTOMER ANALYTICS
-- SQL / MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce_analytics;

USE ecommerce_analytics;


-- ============================================================
-- 1. DATASET OVERVIEW
-- ============================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT Order_ID) AS total_orders,
    COUNT(DISTINCT Customer_id) AS total_customers
FROM ecommerce;


-- ============================================================
-- 2. DATA QUALITY CHECK
-- ============================================================

SELECT
    SUM(Order_ID IS NULL) AS missing_order_id,
    SUM(Order_date IS NULL) AS missing_order_date,
    SUM(Customer_id IS NULL) AS missing_customer_id,
    SUM(Order_total_INR IS NULL) AS missing_order_total,
    SUM(Product_category IS NULL) AS missing_product_category
FROM ecommerce;


-- ============================================================
-- 3. DUPLICATE CHECK
-- ============================================================

SELECT
    Order_ID,
    COUNT(*) AS duplicate_count
FROM ecommerce
GROUP BY Order_ID
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. CORE BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(DISTINCT Order_ID) AS total_orders,

    COUNT(DISTINCT Customer_id) AS total_customers,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS total_revenue,

    SUM(Quantity) AS total_quantity,

    ROUND(
        SUM(Order_total_INR)
        / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value

FROM ecommerce;


-- ============================================================
-- 5. CUSTOMER SEGMENT ANALYSIS
-- ============================================================

SELECT
    Customer_segment,

    COUNT(DISTINCT Customer_id) AS customers,

    COUNT(DISTINCT Order_ID) AS orders,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue,

    SUM(Quantity) AS quantity

FROM ecommerce

GROUP BY Customer_segment

ORDER BY revenue DESC;


-- ============================================================
-- 6. NEW VS RETURNING CUSTOMERS
-- ============================================================

WITH customer_orders AS (

    SELECT
        Customer_id,
        COUNT(DISTINCT Order_ID) AS order_count

    FROM ecommerce

    GROUP BY Customer_id
)

SELECT

    CASE
        WHEN order_count = 1
            THEN 'New Customer'

        WHEN order_count > 1
            THEN 'Returning Customer'
    END AS customer_type,

    COUNT(*) AS customers

FROM customer_orders

GROUP BY
    CASE
        WHEN order_count = 1
            THEN 'New Customer'

        WHEN order_count > 1
            THEN 'Returning Customer'
    END

ORDER BY customers DESC;


-- ============================================================
-- 7. PRODUCT CATEGORY ANALYSIS
-- ============================================================

SELECT
    Product_category,

    COUNT(DISTINCT Order_ID) AS orders,

    SUM(Quantity) AS quantity,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue

FROM ecommerce

GROUP BY Product_category

ORDER BY revenue DESC;


-- ============================================================
-- 8. TOP 10 PRODUCTS
-- ============================================================

SELECT
    Product_name,

    COUNT(DISTINCT Order_ID) AS orders,

    SUM(Quantity) AS quantity,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue

FROM ecommerce

GROUP BY Product_name

ORDER BY revenue DESC

LIMIT 10;


-- ============================================================
-- 9. REGIONAL PERFORMANCE
-- ============================================================

SELECT
    Region,

    COUNT(DISTINCT Customer_id) AS customers,

    COUNT(DISTINCT Order_ID) AS orders,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue

FROM ecommerce

GROUP BY Region

ORDER BY revenue DESC;


-- ============================================================
-- 10. SALES CHANNEL ANALYSIS
-- ============================================================

SELECT
    Sales_channel,

    COUNT(DISTINCT Order_ID) AS orders,

    SUM(Quantity) AS quantity,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue

FROM ecommerce

GROUP BY Sales_channel

ORDER BY revenue DESC;


-- ============================================================
-- 11. DEVICE TYPE ANALYSIS
-- ============================================================

SELECT
    Device_type,

    COUNT(DISTINCT Order_ID) AS orders,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue

FROM ecommerce

GROUP BY Device_type

ORDER BY revenue DESC;


-- ============================================================
-- 12. PAYMENT METHOD ANALYSIS
-- ============================================================

SELECT
    Payment_method,

    COUNT(DISTINCT Order_ID) AS orders,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue

FROM ecommerce

GROUP BY Payment_method

ORDER BY revenue DESC;


-- ============================================================
-- 13. ORDER STATUS ANALYSIS
-- ============================================================

SELECT
    Order_status,

    COUNT(DISTINCT Order_ID) AS orders,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue

FROM ecommerce

GROUP BY Order_status

ORDER BY orders DESC;


-- ============================================================
-- 14. DELIVERY PERFORMANCE
-- ============================================================

SELECT
    Order_status,

    COUNT(DISTINCT Order_ID) AS orders,

    ROUND(
        AVG(Delivery_days),
        2
    ) AS average_delivery_days

FROM ecommerce

GROUP BY Order_status

ORDER BY average_delivery_days;


-- ============================================================
-- 15. MONTHLY REVENUE
-- ============================================================

SELECT
    YEAR(Order_date) AS year,

    MONTH(Order_date) AS month,

    DATE_FORMAT(
        Order_date,
        '%Y-%m'
    ) AS month_name,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS monthly_revenue

FROM ecommerce

GROUP BY
    YEAR(Order_date),
    MONTH(Order_date),
    DATE_FORMAT(
        Order_date,
        '%Y-%m'
    )

ORDER BY year, month;


-- ============================================================
-- 16. MONTH-OVER-MONTH REVENUE
-- ============================================================

WITH monthly_revenue AS (

    SELECT
        DATE_FORMAT(
            Order_date,
            '%Y-%m'
        ) AS month,

        SUM(Order_total_INR) AS revenue

    FROM ecommerce

    GROUP BY
        DATE_FORMAT(
            Order_date,
            '%Y-%m'
        )
),

monthly_analysis AS (

    SELECT
        month,
        revenue,

        LAG(revenue)
        OVER (
            ORDER BY month
        ) AS previous_month_revenue

    FROM monthly_revenue
)

SELECT
    month,

    ROUND(
        revenue,
        2
    ) AS revenue,

    ROUND(
        previous_month_revenue,
        2
    ) AS previous_month_revenue,

    ROUND(
        (
            revenue - previous_month_revenue
        )
        / NULLIF(
            previous_month_revenue,
            0
        ) * 100,
        2
    ) AS mom_growth_percentage

FROM monthly_analysis

ORDER BY month;


-- ============================================================
-- 17. TOP CUSTOMERS BY REVENUE
-- ============================================================

SELECT
    Customer_id,

    MAX(Customer_name) AS Customer_name,

    COUNT(DISTINCT Order_ID) AS orders,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS total_revenue

FROM ecommerce

GROUP BY Customer_id

ORDER BY total_revenue DESC

LIMIT 10;


-- ============================================================
-- 18. CUSTOMER REVENUE RANKING
-- ============================================================

WITH customer_revenue AS (

    SELECT
        Customer_id,

        MAX(Customer_name) AS Customer_name,

        SUM(Order_total_INR) AS revenue

    FROM ecommerce

    GROUP BY Customer_id
)

SELECT
    Customer_id,

    Customer_name,

    ROUND(
        revenue,
        2
    ) AS revenue,

    DENSE_RANK()
    OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank

FROM customer_revenue

ORDER BY revenue_rank;


-- ============================================================
-- 19. HIGH-VALUE CUSTOMERS
-- ============================================================

SELECT
    Customer_id,

    MAX(Customer_name) AS Customer_name,

    COUNT(DISTINCT Order_ID) AS orders,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue

FROM ecommerce

GROUP BY Customer_id

HAVING SUM(Order_total_INR) >= 100000

ORDER BY revenue DESC;


-- ============================================================
-- 20. DISCOUNT ANALYSIS
-- ============================================================

SELECT
    Product_category,

    ROUND(
        AVG(Discount_percent),
        2
    ) AS average_discount,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue

FROM ecommerce

GROUP BY Product_category

ORDER BY revenue DESC;


-- ============================================================
-- 21. STATE-LEVEL PERFORMANCE
-- ============================================================

SELECT
    State,

    COUNT(DISTINCT Customer_id) AS customers,

    COUNT(DISTINCT Order_ID) AS orders,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS revenue

FROM ecommerce

GROUP BY State

ORDER BY revenue DESC

LIMIT 10;


-- ============================================================
-- 22. FINAL BUSINESS SUMMARY
-- ============================================================

SELECT

    COUNT(DISTINCT Order_ID)
        AS total_orders,

    COUNT(DISTINCT Customer_id)
        AS total_customers,

    ROUND(
        SUM(Order_total_INR),
        2
    ) AS total_revenue,

    SUM(Quantity)
        AS total_quantity,

    ROUND(
        SUM(Order_total_INR)
        / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value

FROM ecommerce;
