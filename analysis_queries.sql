-- E-COMMERCE SALES ANALYSIS SQL PROJECT
-- Use this file in DB Browser for SQLite, SQLiteStudio, or any SQLite environment.

-- 1. Total revenue, orders, customers, and products sold
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_rate)), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    SUM(oi.quantity) AS total_products_sold
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered';

-- 2. Monthly revenue trend
SELECT
    strftime('%Y-%m', o.order_date) AS month,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_rate)), 2) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS delivered_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY strftime('%Y-%m', o.order_date)
ORDER BY month;

-- 3. Top 10 products by revenue
SELECT
    p.product_name,
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_rate)), 2) AS revenue,
    SUM(oi.quantity) AS units_sold
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;

-- 4. Revenue by category
SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_rate)), 2) AS revenue,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT o.order_id) AS orders_count
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY revenue DESC;

-- 5. Top cities by revenue
SELECT
    c.city,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_rate)), 2) AS revenue,
    COUNT(DISTINCT o.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders_count
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.city
ORDER BY revenue DESC;

-- 6. Customer segment performance
SELECT
    c.segment,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_rate)), 2) AS revenue,
    COUNT(DISTINCT o.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_rate)) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.segment
ORDER BY revenue DESC;

-- 7. Top 10 customers by total spending
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    c.segment,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_rate)), 2) AS total_spent,
    COUNT(DISTINCT o.order_id) AS orders_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.city, c.segment
ORDER BY total_spent DESC
LIMIT 10;

-- 8. Order status breakdown
SELECT
    status,
    COUNT(*) AS orders_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_orders
FROM orders
GROUP BY status
ORDER BY orders_count DESC;

-- 9. Payment method analysis
SELECT
    o.payment_method,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_rate)), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY o.payment_method
ORDER BY revenue DESC;

-- 10. Repeat customers
SELECT
    CASE
        WHEN customer_orders >= 2 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type,
    COUNT(*) AS number_of_customers
FROM (
    SELECT
        customer_id,
        COUNT(order_id) AS customer_orders
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
) AS customer_order_counts
GROUP BY customer_type;

-- 11. Average order value by month
SELECT
    strftime('%Y-%m', o.order_date) AS month,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_rate)) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY strftime('%Y-%m', o.order_date)
ORDER BY month;

-- 12. Products with low sales
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(SUM(oi.quantity), 0) AS units_sold
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status = 'Delivered'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY units_sold ASC
LIMIT 10;
