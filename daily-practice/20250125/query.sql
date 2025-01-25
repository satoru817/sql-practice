--1. 2024年1月の売上分析
--以下の情報を製品カテゴリ別に集計してください：
--- カテゴリ名
--- 総売上金額
--- 総販売数
--- 平均販売単価
--売上金額の高い順に表示し、金額は小数点第2位で四捨五入してください。

select
    p.category,
    round(sum(oi.quantity*oi.unit_price),2) as total_sales,
    sum(oi.quantity) as total_order_count,
    round(sum(oi.quantity*oi.unit_price)/sum(oi.quantity),2) as avg_unit_price
from
    products p
    inner join order_items oi 
        on oi.product_id = p.product_id
    inner join orders o 
        on o.order_id = oi.order_id
where
    date_format(o.order_date,'%Y-%m')='2024-01'
group by
    p.category
order by
    total_sales desc;

--実行結果
--|category|total_sales|total_order_count|avg_unit_price|
--|--------|-----------|-----------------|--------------|
--|Electronics|2475.00|5|495.00|
--|Furniture|530.00|5|106.00|
--|Appliances|240.00|3|80.00|

--2. 顧客購買パターン分析
--各顧客について以下の情報を表示してください：
--- 顧客名
--- 国
--- 総注文回数
--- 合計購入金額
--- 平均注文金額（1回の注文あたり）
--- 最も購入したカテゴリ
--合計購入金額の高い順に上位3名のみ表示してください。




with cust_stats as (
    select
        c.customer_id,
        c.name,
        c.country,
        count(distinct o.order_id) as total_order_count,
        sum(oi.quantity*oi.unit_price) as total_sales,
        round(sum(oi.quantity*oi.unit_price)/count(distinct o.order_id),2) as avg_order_amount
    from
        customers c
        inner join orders o on o.customer_id = c.customer_id
        inner join order_items oi on oi.order_id = o.order_id
    group by 
        c.customer_id,
        c.name,
        c.country                
),
cust_category_stats as (
    select
        c.customer_id,
        p.category,
        sum(oi.quantity*oi.unit_price) as total_amount
    from
        customers c
        inner join orders o on o.customer_id = c.customer_id
        inner join order_items oi on oi.order_id = o.order_id
        inner join products p on p.product_id = oi.product_id
    group by
        c.customer_id,
        p.category
),
cust_category_ranks as (
    select
        customer_id,
        category,
        rank() over (partition by customer_id order by total_amount desc , category desc) as ranking
    from
        cust_category_stats
),
pre_table as (
    select
        cs.name,
        cs.country,
        cs.total_order_count,
        cs.total_sales,
        cs.avg_order_amount,
        ccr.category,
        rank() over (order by total_sales desc) as ranking
    from
        cust_stats cs
        inner join cust_category_ranks ccr on ccr.customer_id = cs.customer_id
    where
        ccr.ranking = 1        
)
select
    pt.*
from
    pre_table pt
where
    pt.ranking <= 3
order by
    ranking asc;
--実行結果
--|name|country|total_order_count|total_sales|avg_order_amount|category|ranking|
--|----|-------|-----------------|-----------|----------------|--------|-------|
--|John Smith|USA|2|1400.00|700.00|Electronics|1|
--|Yuki Tanaka|Japan|2|1240.00|620.00|Electronics|2|
--|Maria Garcia|Spain|2|320.00|160.00|Appliances|3|



































