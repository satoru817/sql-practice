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

--問題2
各会員レベル（membership_level）について：

会員数
平均購入金額（1回の注文あたり）
2024年第1四半期の平均注文回数
最も多く購入されたカテゴリー（親カテゴリーレベル）
レビュー投稿率（注文した商品に対するレビュー投稿の割合）



期待される出力イメージ：
membership_level | member_count | avg_order_amount | avg_order_frequency | favorite_category | review_rate
PREMIUM         | 150         | 12500.00        | 4.2                | Electronics      | 85.5%
STANDARD        | 450         | 5500.00         | 2.1                | Books           | 45.2%

with parent_membership_stats as (--メンバーシップ、親カテゴリーごとの統計情報
    select
        pc.category_name,
        cust.membership_level,
        sum(oi.quantity*oi.unit_price) as total_sales
    from
        customers cust
        inner join orders o 
            on o.customer_id = cust.customer_id
            and year(o.order_date) = '2024'
            and quarter(o.order_date) = '1'
        inner join order_items oi on oi.order_id = o.order_id
        inner join products p on p.product_id = oi.product_id
        inner join categories c on c.category_id = p.category_id
        inner join categories pc on pc.category_id = c.parent_category_id
    where
        o.status != 'CANCELLED'
    group by
        pc.category_id,
        pc.category_name,
        cust.membership_level
),
parent_membership_ranks as (
    select
        category_name,
        membership_level,
        rank() over (partition by membership_level order by total_sales desc , category_name desc) as ranking
    from
        parent_membership_stats
),
review_stats as (
    select
        cust.membership_level,
        count(rev.review_id) as review_count
    from
        customers cust
        inner join reviews rev 
            on rev.customer_id = cust.customer_id 
            and year(rev.created_at) = '2024'
            and quarter(rev.created_at) = '1'
    group by
        cust.membership_level
)
select
    cust.membership_level,
    count(distinct cust.customer_id) as member_count,
    round(sum(o.total_amount)/count(o.order_id),1) as avg_order_amount,
    count(o.order_id)/count(distinct cust.customer_id) as avg_order_frequency,
    pmr.category_name as favorite_category,
    concat(round(100.0*rs.review_count/sum(o.order_id),1),'%') as review_rate
from
    customers cust
    left join orders o 
        on o.customer_id = cust.customer_id
        and year(o.order_date) = '2024'
        and quarter(o.order_date) = '1'
        and o.status != 'CANCELLED'
    left join parent_membership_ranks pmr 
        on pmr.membership_level = cust.membership_level 
        and pmr.ranking = 1
    left join review_stats rs on rs.membership_level = cust.membership_level
group by
    cust.membership_level,
    pmr.category_name,
    rs.review_count;
        











































