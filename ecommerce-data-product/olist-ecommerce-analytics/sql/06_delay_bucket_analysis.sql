-- 06 延迟区间互斥：1<=d<3、3<=d<=7、d>7
DROP TABLE IF EXISTS monthly_delay_buckets;
CREATE TABLE monthly_delay_buckets AS
SELECT DATE_FORMAT(order_purchase_timestamp,'%Y-%m') order_month,
       CASE WHEN delivery_delay_days>=1 AND delivery_delay_days<3 THEN '1-不足3天'
            WHEN delivery_delay_days>=3 AND delivery_delay_days<=7 THEN '3-7天'
            WHEN delivery_delay_days>7 THEN '超过7天' END delay_bucket,
       COUNT(*) late_order_count
FROM order_analysis_wide
WHERE delivery_result='late'
GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m'),
       CASE WHEN delivery_delay_days>=1 AND delivery_delay_days<3 THEN '1-不足3天'
            WHEN delivery_delay_days>=3 AND delivery_delay_days<=7 THEN '3-7天'
            WHEN delivery_delay_days>7 THEN '超过7天' END;

DROP TABLE IF EXISTS monthly_delivery_monitor;
CREATE TABLE monthly_delivery_monitor AS
SELECT DATE_FORMAT(order_purchase_timestamp,'%Y-%m') order_month,
       COUNT(*) total_orders,
       SUM(delivery_result IN ('on_time','late')) evaluable_orders,
       SUM(delivery_result='on_time') on_time_orders,
       SUM(delivery_result='late') late_orders,
       ROUND(100.0*SUM(delivery_result='on_time')/
         NULLIF(SUM(delivery_result IN ('on_time','late')),0),2) on_time_rate_pct,
       ROUND(100.0*SUM(delivery_result='late')/
         NULLIF(SUM(delivery_result IN ('on_time','late')),0),2) late_rate_pct
FROM order_analysis_wide
GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m');

SELECT * FROM monthly_delivery_monitor ORDER BY order_month;
SELECT * FROM monthly_delay_buckets ORDER BY order_month, delay_bucket;
