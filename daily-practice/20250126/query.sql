データベース構造を作成し、ECサイトに関する分析的なSQLの問題を作ってみましょう。



以下の分析課題に取り組んでください：

**問題：ECサイトの売上・顧客分析**

以下の分析を行うSQLクエリを作成してください：

1. カテゴリ階層分析
   - 各親カテゴリと、その配下の子カテゴリごとの売上合計を算出
   - 各カテゴリの売上構成比（全体に対する割合）を計算
   - カテゴリごとの平均購入単価を算出

2. 顧客セグメント分析
   - 会員レベル（BRONZE/SILVER/GOLD/PLATINUM）ごとの：
     - 総購入金額
     - 平均購入金額
     - 顧客数
     - 1人あたりの注文回数
   - レベルごとの売上構成比を算出

3. 商品パフォーマンス分析
   - 商品ごとの売上金額、販売数、粗利益を計算
   - 商品別の評価平均とレビュー数
   - 売上金額TOP10の商品リスト（カテゴリ名、評価平均を含む）

4. トレンド分析
   - 過去3ヶ月の週次売上推移
   - 前週比での成長率
   - カテゴリごとの週次売上構成比の変化

回答する際は、以下の点に注意してください：
- Common Table Expression (CTE)を活用して、複雑なクエリを整理する
- 適切なJOINの種類を選択する
- NULL値の処理を適切に行う
- 結果の可読性を考慮（適切な桁数での四捨五入、パーセント表示など）





1. カテゴリ階層分析
   - 各親カテゴリと、その配下の子カテゴリごとの売上合計を算出
   - 各カテゴリの売上構成比（全体に対する割合）を計算
   - カテゴリごとの平均購入単価を算出

with child_stats as (
    select
        c.category_id as child_category_id,
        c.name as child_category_name,
        sum(oi.quantity*oi.unit_price) as child_total_sales,
        sum(oi.quantity) as child_total_quantity,
        sum(oi.quantity*oi.unit_price)/sum(oi.quantity) as child_avg_unit_price
    from
        order_items oi
        inner join products p on p.product_id = oi.product_id
        inner join categories c on c.category_id = p.category_id
    group by
        c.category_id,
        c.name
),
parent_stats as (
    select
        pc.category_id as parent_category_id,
        pc.name as parent_category_name,
        sum(cs.child_total_sales) as parent_total,
        sum(cs.child_total_quantity) as parent_total_quantity,
        sum(cs.child_total_sales)/sum(cs.child_total_quantity) as parent_avg_unit_price
    from
        child_stats cs
        inner join categories c on c.category_id = cs.child_category_id
        inner join categories pc on pc.category_id = c.parent_category_id
    group by
        pc.category_id,
        pc.name
)
select
    coalesce(cs.child_category_name,ps.parent_category_name) as category_name,
    coalesce(pc.name,'left is parent') as parent_category_name,
    round(coalesce(cs.child_total,ps.parent_total),1) as category_total,
    round(coalesce(cs.child_avg_unit_price,ps.parent_avg_unit_price),1) as category_avg_unit_price,
    concat(100.0*coalesce(cs.child_total,ps.parent_total)/(sum(ps.parent_total) over ()),'%') as category_sales_ratio
from
    categories c
    left join categories pc on pc.category_id = c.parent_category_id
    left join child_stats cs on cs.child_category_id = c.category_id
    left join parent_stats ps on ps.parent_category_id = c.category_id;
    
    

2. 顧客セグメント分析
   - 会員レベル（BRONZE/SILVER/GOLD/PLATINUM）ごとの：
     - 総購入金額
     - 平均購入金額
     - 顧客数
     - 1人あたりの注文回数
   - レベルごとの売上構成比を算出

with membership_stats as (
    select
        c.membership_level,
        sum(o.total_amount) as total_amount,
        sum(o.total_amount)/count(o.order_id) as avg_amount,
        count(distinct c.customer_id) as customer_num,
        count(o.order_id)/count(distinct c.customer_id) as avg_order_count
    from
        customers c
        inner join orders o on o.customer_id = c.customer_id
    where
        o.status != 'CANCELLED'--ここの考慮が抜けていた。
    group by
        c.membership_level
)
select
    membership_level,
    round(total_amount,1) as total_amount,
    round(avg_amount,1) as avg_amount,
    customer_num,
    round(avg_order_count,1)  as avg_order_count,
    concat(round(100.0*total_amount/(sum(total_amount) over ()),1),'%') as ratio
from
    membership_stats;

3. 商品パフォーマンス分析
   - 商品ごとの売上金額、販売数、粗利益を計算
   - 商品別の評価平均とレビュー数
   - 売上金額TOP10の商品リスト（カテゴリ名、評価平均を含む）

--これは重要なミスのあるクエリ
with prod_stats as (
    select
        p.product_id,
        p.name,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity) as total_quantity,
        sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
        avg(r.rating) as avg_rating,
        count(r.review_id) as review_count
    from
        products p
        inner join order_items oi on oi.product_id = p.product_id
        left join reviews r on r.product_id = p.product_id
    group by 
        p.product_id,
        p.name,
        p.price
),
prod_ranks as (
    select
        ps.*,
        rank() over (order by ps.total_sales desc) as ranking
    from
        prod_stats ps
)
select
    pr.ranking,
    pr.name,
    round(pr.total_sales,1) as total_sales,
    pr.total_quantity,
    round(pr.total_profit,1) as total_profit,
    round(pr.avg_rating,1) as avg_rating,
    pr.review_count
from
    prod_ranks pr
where
    pr.ranking <= 10
order by
    pr.ranking asc;


ミスの詳細

1. まず、結合の基本的な動作を見てみましょう：

```sql
-- 例として、あるproductに対して：
-- order_items が 3行
-- reviews が 2行 あるケース

products
product_id  name    price
1          商品A    1000

order_items
product_id  quantity  unit_price
1          2         1000        -- 注文1
1          3         1000        -- 注文2
1          1         1000        -- 注文3

reviews
product_id  rating  comment
1          5       "良い"        -- レビュー1
1          4       "まあまあ"    -- レビュー2
```

2. これらを単純に結合すると：
```sql
products × order_items × reviews の組み合わせになります。

つまり：3(order_items) × 2(reviews) = 6行 のデータになります：

product_id  name   quantity  rating
1          商品A   2         5      -- 注文1×レビュー1
1          商品A   2         4      -- 注文1×レビュー2
1          商品A   3         5      -- 注文2×レビュー1
1          商品A   3         4      -- 注文2×レビュー2
1          商品A   1         5      -- 注文3×レビュー1
1          商品A   1         4      -- 注文3×レビュー2
```

3. この状態で集計すると：
```sql
sum(quantity) -- > (2+2+3+3+1+1) = 12
```
実際の注文数量の合計は (2+3+1) = 6 なのに、レビューの数だけ重複してカウントされてしまいます。

4. 正しい実装方法：
```sql
-- 方法1: 注文とレビューを別々に集計
with order_summary as (
    select 
        product_id,
        sum(quantity) as total_quantity,
        sum(quantity * unit_price) as total_sales
    from order_items
    group by product_id
),
review_summary as (
    select
        product_id,
        avg(rating) as avg_rating,
        count(*) as review_count
    from reviews
    group by product_id
)
select
    p.product_id,
    p.name,
    o.total_quantity,
    o.total_sales,
    r.avg_rating,
    r.review_count
from products p
left join order_summary o on p.product_id = o.product_id
left join review_summary r on p.product_id = r.product_id;
```

このように、多対多の関係がある場合は：
1. 先に個別に集計を行う
2. その後で結合する

という順序で処理するのが安全です。元のクエリでは重複カウントの問題が発生していたことになります。


































