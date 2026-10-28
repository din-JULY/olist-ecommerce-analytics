-- 04 配送率的分母是实际与预计送达时间均非空的订单
SELECT COUNT(*) total_orders,
       SUM(delivery_result='on_time') on_time_orders,
       SUM(delivery_result='late') late_orders,
       SUM(delivery_result='not_evaluable') not_evaluable_orders,
       ROUND(100.0*SUM(delivery_result='on_time')/
         NULLIF(SUM(delivery_result IN ('on_time','late')),0),2) on_time_rate_pct,
       ROUND(100.0*SUM(delivery_result='late')/
         NULLIF(SUM(delivery_result IN ('on_time','late')),0),2) late_rate_pct
FROM order_analysis_wide;

SELECT DATE_FORMAT(order_purchase_timestamp,'%Y-%m') order_month,
       COUNT(*) total_orders,
       SUM(delivery_result='on_time') on_time_orders,
       SUM(delivery_result='late') late_orders,
       SUM(delivery_result='not_evaluable') not_evaluable_orders,
       ROUND(100.0*SUM(delivery_result='late')/
         NULLIF(SUM(delivery_result IN ('on_time','late')),0),2) late_rate_pct
FROM order_analysis_wide
GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m')
ORDER BY order_month;
