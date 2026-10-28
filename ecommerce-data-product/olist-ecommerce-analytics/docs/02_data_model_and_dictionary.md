# 02 数据模型与字段字典

## 分析层
- `order_analysis_wide`：一行对应一个订单。
- `monthly_delivery_monitor`：按月份汇总配送监控指标。
- `monthly_delay_buckets`：按月份与延迟区间汇总延迟订单。

## 源表粒度
| 表 | 一行代表 | 关键字段 | 用途 |
|---|---|---|---|
| `orders` | 一个订单 | `order_id` | 状态、下单与配送时间 |
| `order_items` | 一个订单商品行 | `order_id`, `order_item_id` | 商品价格、运费 |
| `order_payments` | 一条支付记录 | `order_id`, `payment_sequential` | 支付方式、金额 |
| `order_reviews` | 一条评价 | `review_id`, `order_id` | 评价分数、时间 |
| `customers` | 一个客户记录 | `customer_id` | 客户所在地 |

关联：`orders.order_id` 与三张明细表的 `order_id` 为一对多；`orders.customer_id` 关联 `customers.customer_id`。`customer_id` 和 `customer_unique_id` 不能混用。

## 订单宽表逻辑字段
| 字段 | 含义/来源 | 注意事项 |
|---|---|---|
| `order_id` | 订单标识 | 宽表应唯一 |
| `customer_id`, `customer_unique_id` | 客户记录标识/跨订单客户标识 | 语义不同 |
| `customer_state`, `customer_city` | 客户州/城市 | 地区分析维度 |
| `order_status` | 订单状态 | 需明确筛选范围 |
| `order_purchase_timestamp` | 下单时间 | 月度订单分析常用 |
| `order_approved_at` | 审核时间 | 可能为空 |
| `order_delivered_carrier_date` | 交承运方时间 | 可能为空 |
| `order_delivered_customer_date` | 实际送达时间 | 配送结果关键字段 |
| `order_estimated_delivery_date` | 预计送达时间 | 配送比较基准 |
| `item_line_count` | 商品明细行数 | 不一定等于商品件数 |
| `item_amount` | `SUM(price)` 按订单聚合 | 与支付金额分开 |
| `freight_amount` | `SUM(freight_value)` 按订单聚合 | 防止重复累计 |
| `payment_record_count` | 支付记录数 | 一单可能多条 |
| `payment_amount` | `SUM(payment_value)` 按订单聚合 | 不默认等于商品金额 |
| `review_record_count` | 评价记录数 | 需检查多评价情况 |
| `avg_review_score` | 按订单评价均分 | 聚合规则需一致 |
| `delivery_delay_days` | 实际送达日期减预计日期 | 正数代表延迟 |
| `delivery_result` | 准时/延迟/不可评估 | 未送达不自动算准时 |

## 月度汇总表
`monthly_delivery_monitor` 建议包括月份、订单数、可评估订单数、准时/延迟订单数、准时率与延迟率。`monthly_delay_buckets` 包括月份、延迟区间、区间订单数。

## 键、刷新与限制
源表唯一性需检查：orders 的 `order_id`；order_items 的 `order_id + order_item_id`；payments 的 `order_id + payment_sequential`；reviews 的 `review_id`。宽表 `order_id` 唯一；月度表按月份或月份+区间唯一。公开数据通常批次导入，源数据更新后重建或重算分析表。

本文件是逻辑字段字典，不是对本地 DDL 的逐字段核验。类型、可空性和实际字段名以 `DESCRIBE`/`SHOW CREATE TABLE` 为准。延迟区间需采用互斥边界并在 SQL 与图表中统一。
