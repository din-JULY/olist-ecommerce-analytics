-- 01 源数据质量检查：先确认连接到正确的 schema
SELECT 'orders' table_name, COUNT(*) row_count FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'customers', COUNT(*) FROM customers;

SELECT order_id, COUNT(*) n FROM orders GROUP BY order_id HAVING COUNT(*) > 1;

SELECT SUM(order_id IS NULL) null_order_id,
       SUM(customer_id IS NULL) null_customer_id,
       SUM(order_status IS NULL) null_order_status
FROM orders;

SELECT 'order_items' source_table, COUNT(*) unmatched_rows
FROM order_items oi LEFT JOIN orders o ON o.order_id=oi.order_id
WHERE o.order_id IS NULL
UNION ALL SELECT 'order_payments', COUNT(*)
FROM order_payments p LEFT JOIN orders o ON o.order_id=p.order_id
WHERE o.order_id IS NULL
UNION ALL SELECT 'order_reviews', COUNT(*)
FROM order_reviews r LEFT JOIN orders o ON o.order_id=r.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) orders_without_customer_match
FROM orders o LEFT JOIN customers c ON c.customer_id=o.customer_id
WHERE c.customer_id IS NULL;

SELECT order_id, order_item_id, COUNT(*) n FROM order_items
GROUP BY order_id, order_item_id HAVING COUNT(*) > 1;
SELECT order_id, payment_sequential, COUNT(*) n FROM order_payments
GROUP BY order_id, payment_sequential HAVING COUNT(*) > 1;
SELECT review_id, COUNT(*) n FROM order_reviews
GROUP BY review_id HAVING COUNT(*) > 1;
