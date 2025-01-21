--
--問題3: 時間帯別売上分析
--- 1日を6時間ごとに分割して売上分析をしてください
--- 時間帯区分：
--  * 00:00-05:59
--  * 06:00-11:59
--  * 12:00-17:59
--  * 18:00-23:59
--- 表示項目：
--  * 時間帯
--  * 注文件数
--  * 総売上金額
--  * 平均注文金額
--  * 最も売れた商品名

with sales_stats_of_a_product as (
    select
        p.product_id,
        p.product_name,
        case 
            when hour(o.order_date) < 6 then 1 
            when hour(o.order_date) < 12 then 2
            when hour(o.order_date) < 18 then 3
            else 4 end 
        as quarter_of_day,
        sum(oi.quantity*oi.unit_price) as total_sales
            from
                products p
                    inner join order_items oi on oi.product_id = p.product_id
                    inner join orders o on o.orer_id = oi.order_id
            group by
                p.product_id,
                p.product_name,
                (case when hour(o.order_date) < 6 then 1
                        when hour(o.orer_date) < 12 then 2
                        when hour(o.order_date)<18 then 3
                        else 4 end)
),
sale_rank as (
    select
        ssoap.*,
        rank() over (partition by ssoap.quarter_of_day order by total_sales desc) as ranking
            from
        sales_stas_of_a_product ssoap
),
sale_stats as (
    select
        case 
            when hour(o.order_date) < 6 then 1 
            when hour(o.order_date) < 12 then 2
            when hour(o.order_date) < 18 then 3
            else 4 end 
        as quarter_of_day,
        count(o.order_id) as 
        sum(o.total_amount) as total_amount,
        sum()
        )
