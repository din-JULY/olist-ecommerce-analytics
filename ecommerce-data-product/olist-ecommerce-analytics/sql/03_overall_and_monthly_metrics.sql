-- 03 商品金额、支付金额、运费分别展示，不默认等同于 GMV
SELECT COUNT(*) order_count, SUM(item_amount) total_item_amount,
       SUM(payment_amount) total_payment_amount,
       SUM(freight_amount) total_freight_amount
FROM order_analysis_wide;

SELECT DATE_FORMAT(order_purchase_timestamp,'%Y-%m') order_month,
       COUNT(*) order_count, SUM(item_amount) total_item_amount,
       SUM(payment_amount) total_payment_amount,
       SUM(freight_amount) total_freight_amount
FROM order_analysis_wide
GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m')
ORDER BY order_month;
