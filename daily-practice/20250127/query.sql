問題：以下の分析クエリを作成してください。

各親カテゴリーの2024年第1四半期（1-3月）の売上について、以下の情報を取得してください：

親カテゴリー名
総売上額
平均購入単価（注文数量で割った値）
売上額TOP3の商品名（カンマ区切りで1列に結合）



期待される出力イメージ：
parent_category | total_sales | avg_order_value | top_selling_products
Electronics     | 1250000.00  | 25000.00        | iPhone 13,MacBook Pro,AirPods
Books          | 350000.00   | 3500.00         | SQL Guide,Python Basics,Java Tutorial

with prod_stats as (
    select
        pr.product_name,
        pc.category_name as parent_category,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity) as total_order
    from
        order_items oi
        inner join orders o on 
            o.order_id = oi.order_id 
            and year(o.order_date) = '2024' 
            and quarter(o.order_date) = '1'
        inner join products pr on pr.product_id = oi.product_id
        inner join categories c on c.category_id = p.category_id
        inner join categories pc on pc.category_id = c.parent_category_id
    group by
        pr.product_id,
        pr.product_name,
        pc.category_id,
        pc.category_name
),
prod_ranks as (
    select
        product_name,
        parent_category,
        rank() over (partition by parent_category order by total_sales desc) as ranking
    from
        prod_stats 
),
top_threes as (
    select
        parent_category,
        group_concat(
            product_name
            order by ranking desc  
            separator ','      
        ) as top_selling_products
    from
        prod_ranks
    where
        ranking <= 3
    group by 
        parent_category
)
select
    ps.parent_category,
    sum(ps.total_sales) as total_sales,
    sum(ps.total_sales)/sum(ps.total_order) as avg_unit_price,
    (select tt.top_selling_products from top_threes tt where tt.parent_category = ps.parent_category) as top_selling_category
from
    prod_stats ps
group by
    ps.parent_category;
    


間違ったポイント


select
    ps.parent_category,
    sum(ps.total_sales) as total_sales,
    sum(ps.total_sales)/sum(ps.total_order) as avg_unit_price,
    select(tt.top_selling_products from top_threes tt where tt.parent_category = ps.parent_category) as--ここ、で()の位置がおかしい忘れていた
    top_selling_category
from

--これで正解
(select tt.top_selling_products from top_threes tt where tt.parent_category = ps.parent_category) as top_selling_category

















