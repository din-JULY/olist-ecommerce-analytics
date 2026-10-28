-- 05 地区分析同时展示可评估样本量
SELECT customer_state, COUNT(*) total_orders,
       SUM(delivery_result IN ('on_time','late')) evaluable_orders,
       SUM(delivery_result='late') late_orders,
       ROUND(100.0*SUM(delivery_result='late')/
         NULLIF(SUM(delivery_result IN ('on_time','late')),0),2) late_rate_pct
FROM order_analysis_wide
GROUP BY customer_state
ORDER BY late_rate_pct DESC, evaluable_orders DESC;
