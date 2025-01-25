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


--4. カテゴリ別のクロス集計
--各カテゴリの国別売上構成比を計算してください：
--- カテゴリ名
--- 国別の売上金額
--- 国別の売上構成比（カテゴリ全体に対する割合）
--カテゴリ内での売上構成比が10%以上の組み合わせのみ表示してください。

with category_country_stats as (
    select
        p.category,
        c.country,
        sum(oi.quantity*oi.unit_price) as total_sales
    from
        customers c
        inner join orders o on o.customer_id = c.customer_id
        inner join order_items oi on oi.order_id = o.order_id
        inner join products p on p.product_id = oi.product_id
    group by
        p.category,
        c.country
),
category_country_ratio as (
    select
        ccs.category,
        ccs.country,
        ccs.total_sales,
        ccs.total_sales/(sum(ccs.total_sales) over (partition by ccs.category)) as ratio
    from
        category_country_stats ccs
)
select
    ccr.category,
    ccr.country,
    round(ccr.total_sales,2) as total_sales,
    concat(round(100.0*ccr.ratio,1),'%') as ratio
from
    category_country_ratio ccr
where
    ccr.ratio >= 0.1
order by
    ccr.category,
    ccr.ratio desc;

--実行結果
--|category|country|total_sales|ratio|
--|--------|-------|-----------|-----|
--|Appliances|Spain|240.00|100.0%|
--|Electronics|USA|1250.00|50.5%|
--|Electronics|Japan|1200.00|48.5%|
--|Furniture|UK|300.00|52.6%|
--|Furniture|USA|150.00|26.3%|
--|Furniture|Spain|80.00|14.0%|


--3. 製品別の売上推移
--各製品の週次売上を分析してください：
--- 製品名
--- 週の開始日（月曜日）
--- 総売上金額
--- 前週からの売上金額の増減
--- 売上の成長率（前週比）
--製品ごとに新しい週順に表示してください。

with prod_week_stats as (
    select
        p.product_id,
        p.name,
        date_sub(o.order_date,interval weekday(o.order_date) day) as week_start_date,
        sum(oi.quantity*oi.unit_price) as week_total
    from
        products p 
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id
    group by
        p.product_id,
        p.name,
        date_sub(o.order_date,interval weekday(o.order_date) day)--
)
select
    pws.name,
    pws.week_start_date,
    pws.week_total,
    pws.week_total - lag(pws.week_total,1) over (partition by pws.product_id order by pws.week_start_date asc) as week_change,
    concat(round(100.0*(pws.week_total - lag(pws.week_total,1) over (partition by pws.product_id order by pws.week_start_date asc))/(lag(pws.week_total,1) over (partition by pws.product_id order by pws.week_start_date asc)),1),'%') as change_ratio
from
    prod_week_stats pws;

--実行結果
--|name|week_start_date|week_total|week_change|change_ratio|
--|----|---------------|----------|-----------|------------|
--|Laptop Pro|2024-01-01|1200.00|||
--|Laptop Pro|2024-01-15|1200.00|0.00|0.0%|
--|Wireless Mouse|2024-01-01|75.00|||
--|Office Chair|2024-01-15|150.00|||
--|Office Chair|2024-01-22|300.00|150.00|100.0%|
--|Coffee Maker|2024-01-08|80.00|||
--|Coffee Maker|2024-01-29|160.00|80.00|100.0%|
--|Desk Lamp|2024-01-08|80.00|||
--|Desk Lamp|2024-01-29|40.00|-40.00|-50.0%|


なぜ WEEKDAY 関数と組み合わせる場合に DAY が必要なのか？
以下のようなクエリを考えます：


DATE_SUB(order_date, INTERVAL WEEKDAY(order_date) DAY)


WEEKDAY(order_date): 日付が何曜日かを数値（0～6）で返します。たとえば、2025-01-25 は土曜日なので 5 を返します。
INTERVAL ... DAY: WEEKDAY の結果が「日数」であるため、MySQLに「何日引くか」を正確に伝えるために DAY を付けています。
もし DAY を省略すると、次のように MySQL は「この数値をどの単位で計算すればいいか」を判断できなくなり、エラーが発生します。



























