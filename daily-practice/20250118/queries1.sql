--商品の売上ランキングを分析する問題はいかがでしょうか？以下のような要件で：
--
--商品ごとの売上総額
--販売数
--利益額（売上 - 原価）
--利益率（利益額÷売上）
--カテゴリー名も表示
--売上額順にランク付け
--
--期待される出力形式：
--| rank | product_name | category_name | total_sales | quantity | profit | profit_margin |
--|------|-------------|---------------|-------------|----------|---------|---------------|
--| 1    | ThinkPad X1 | Laptops       | 180000     | 1        | 60000   | 0.33         |
--...


with product_stats as(
    select
        p.name as product_name,
        c.name as category_name,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity) as quantity,
        sum(oi.quantity*(oi.unit_price-p.cost)) as profit,
        sum(oi.quantity*(oi.unit_price-p.cost))/sum(oi.quantity*oi.unit_price) as profit_margin
            from 
                products p
                    inner join categories c on c.category_id = p.category_id
                    inner join order_items oi on oi.product_id = p.product_id
                    inner join orders o on o.order_id = oi.order_id and o.order_status != 'cancelled'
            group by
                p.name,
                c.name
)
select
    rank() over (order by ps.total_sales desc) as ranking,
    ps.*
        from product_stats ps;



ranking|product_name|category_name|total_sales|quantity|profit   |profit_margin|
-------+------------+-------------+-----------+--------+---------+-------------+
      1|MacBook Air |Laptops      |  300000.00|       2|100000.00|     0.333333|
      2|ThinkPad X1 |Laptops      |  180000.00|       1| 60000.00|     0.333333|
      3|iPhone 15   |Smartphones  |  120000.00|       1| 40000.00|     0.333333|
      4|Galaxy S24  |Smartphones  |  100000.00|       1| 30000.00|     0.300000|
      5|SQL Basics  |Programming  |    9000.00|       3|  4800.00|     0.533333|
      6|Java Master |Programming  |    6000.00|       2|  2800.00|     0.466667|

6 row(s) fetched.
