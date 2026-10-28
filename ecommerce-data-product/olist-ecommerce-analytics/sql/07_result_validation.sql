-- 07 汇总一致性校验；发现差异时排查口径，不要直接改结果
SELECT COUNT(*) rows_total, COUNT(DISTINCT order_id) distinct_orders
FROM order_analysis_wide;

SELECT SUM(delivery_result='on_time') on_time_orders,
       SUM(delivery_result='late') late_orders,
       SUM(delivery_result IN ('on_time','late')) evaluable_orders,
       SUM(delivery_result='not_evaluable') not_evaluable_orders
FROM order_analysis_wide;

SELECT SUM(monthly_orders) monthly_order_total
FROM (
  SELECT DATE_FORMAT(order_purchase_timestamp,'%Y-%m') order_month,
         COUNT(*) monthly_orders
  FROM order_analysis_wide
  WHERE order_purchase_timestamp IS NOT NULL
  GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m')
) m;

SELECT COUNT(*) orders_without_purchase_timestamp
FROM order_analysis_wide WHERE order_purchase_timestamp IS NULL;

SELECT (SELECT COALESCE(SUM(late_order_count),0) FROM monthly_delay_buckets) bucket_order_total,
       (SELECT COUNT(*) FROM order_analysis_wide
        WHERE delivery_result='late'
          AND ((delivery_delay_days>=1 AND delivery_delay_days<3)
            OR (delivery_delay_days>=3 AND delivery_delay_days<=7)
            OR delivery_delay_days>7)) late_orders_in_defined_buckets;

SELECT (SELECT COALESCE(SUM(total_orders),0) FROM monthly_delivery_monitor) monthly_order_total,
       (SELECT COUNT(*) FROM order_analysis_wide
        WHERE order_purchase_timestamp IS NOT NULL) wide_orders_with_purchase_month;
