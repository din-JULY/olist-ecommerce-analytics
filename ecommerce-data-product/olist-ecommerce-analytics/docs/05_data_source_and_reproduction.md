# 05 数据来源与复现

## 数据来源
Olist Brazilian E-Commerce Public Dataset（巴西电商公开数据集）。从数据集发布页面获取原始文件，并保留来源与许可说明。本仓库不包含原始 CSV。

## 导入
1. 在 MySQL 建立独立数据库。
2. 用 DataGrip 导入 CSV，检查编码、分隔符、列名、日期和数值类型。
3. 表名需与脚本一致：`orders`、`order_items`、`order_payments`、`order_reviews`、`customers`。
4. 执行质量检查；若字段不一致，先核对导入映射再修订脚本。

## 执行顺序
`sql/01_data_quality_checks.sql` → `02_order_analysis_wide.sql` → `03_overall_and_monthly_metrics.sql` → `04_delivery_performance_analysis.sql` → `05_state_level_analysis.sql` → `06_delay_bucket_analysis.sql` → `07_result_validation.sql`。

## 版本差异与结果管理
历史 CSV 行数和 DataGrip 行数存在差异，现有信息不足以确定原因。复现时重新检查，不要为了匹配历史数字而人为删行。只导出不含敏感信息的聚合结果，并记录日期、SQL 来源、粒度、指标口径和筛选条件。不要提交数据库密码或原始明细数据。
