-- 02 先将一对多明细聚合到订单粒度，再创建宽表。
-- 请先 DESCRIBE customers 核实 customer_state/customer_city 字段名。
DROP TABLE IF EXISTS order_analysis_wide;
CREATE TABLE order_analysis_wide AS
WITH items_by_order AS (
  SELECT order_id, COUNT(*) item_line_count,
         SUM(price) item_amount, SUM(freight_value) freight_amount
  FROM order_items GROUP BY order_id
),
payments_by_order AS (
  SELECT order_id, COUNT(*) payment_record_count,
         SUM(payment_value) payment_amount
  FROM order_payments GROUP BY order_id
),
reviews_by_order AS (
  SELECT order_id, COUNT(*) review_record_count,
         AVG(review_score) avg_review_score
  FROM order_reviews GROUP BY order_id
)
SELECT o.order_id, o.customer_id, c.customer_unique_id,
       c.customer_state, c.customer_city, o.order_status,
       o.order_purchase_timestamp, o.order_approved_at,
       o.order_delivered_carrier_date, o.order_delivered_customer_date,
       o.order_estimated_delivery_date,
       i.item_line_count, i.item_amount, i.freight_amount,
       p.payment_record_count, p.payment_amount,
       r.review_record_count, r.avg_review_score,
       CASE WHEN o.order_delivered_customer_date IS NULL
              OR o.order_estimated_delivery_date IS NULL THEN NULL
            ELSE DATEDIFF(o.order_delivered_customer_date,
                          o.order_estimated_delivery_date) END delivery_delay_days,
       CASE WHEN o.order_delivered_customer_date IS NULL
              OR o.order_estimated_delivery_date IS NULL THEN 'not_evaluable'
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
              THEN 'on_time'
            ELSE 'late' END delivery_result
FROM orders o
LEFT JOIN customers c ON c.customer_id=o.customer_id
LEFT JOIN items_by_order i ON i.order_id=o.order_id
LEFT JOIN payments_by_order p ON p.order_id=o.order_id
LEFT JOIN reviews_by_order r ON r.order_id=o.order_id;

SELECT COUNT(*) row_count, COUNT(DISTINCT order_id) distinct_orders
FROM order_analysis_wide;
SELECT order_id, COUNT(*) n FROM order_analysis_wide
GROUP BY order_id HAVING COUNT(*) > 1;
