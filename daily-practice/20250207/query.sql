問題：
以下の分析を行うSQLクエリを作成してください。

1. 各カテゴリ（親カテゴリを含む）における以下の情報を抽出してください：
   - カテゴリ名
   - 総売上額
   - 平均利益率
   - 最も人気のある商品仕様（specs内の情報で最も売れている組み合わせ）
   - レビューの平均評価（review_details内の各評価項目の平均）
   - 配送方法ごとの注文数（delivery_info内の配送方法の分布）

このクエリでは以下のような技術的チャレンジがあります：
- JSONデータの解析と集計
- 階層的なカテゴリ構造の処理
- 複数テーブルの結合と集計
- Window関数の活用
- 複雑な条件での集計

回答する際は、以下のポイントを意識してください：
- パフォーマンスを考慮したクエリ設計
- JSONデータの適切な処理
- NULL値の適切な処理
- 集計結果の可読性


--親カテゴリを入れたものをいきなり考えるのはきついので、まず親カテゴリ無しで作る。

--まず実験。jsonの抜き出したデータでgroup by集計できるのか?
SELECT 
	c.category_id,
	c.name,
	o.delivery_info->>'$.method' as delivery_method,
	count(distinct o.order_id) as delivery_count
from
	categories c
	inner join products p on p.category_id  = c.category_id 
	inner join order_items oi on oi.product_id  = p.product_id 
	inner join orders o on o.order_id = oi.order_id 
group by
	c.category_id,
	c.name,
	o.delivery_info->>'$.method';

|category_id|name   |delivery_method|delivery_count|
|-----------|-------|---------------|--------------|
|3          |文学・小説  |コンビニ受取         |1             |
|4          |ビジネス書  |コンビニ受取         |1             |
|4          |ビジネス書  |宅配便            |1             |
|5          |スマートフォン|宅配便            |2             |
|5          |スマートフォン|店舗受取           |1             |
|6          |タブレット  |宅配便            |2             |
|7          |マンガ    |コンビニ受取         |1             |
|9          |オーディオ機器|宅配便            |2             |
|10         |調理家電   |宅配便            |1             |


これは上手くいった。




with category_spec_stats as (
    select
        c.category_id,
        p.specs,
        sum(oi.quantity) as total_quantity
    from
        categories c
        inner join products p on p.category_id = c.category_id
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id and o.status != 'cancelled'
    group by
        c.category_id,
        p.specs
),
category_spec_ranks as (
    select
        category_id,
        specs,
        rank() over (partition by category_id order by total_quantity) as rank_in_category
    from
        category_spec_stats
),
category_delivery_stats as (
    select
        c.category_id,
        o.delivery_info->>'$.method' as delivery_method,
        count(distinct o.order_id) as delivery_count
    from
	    categories c
	    inner join products p on p.category_id  = c.category_id 
	    inner join order_items oi on oi.product_id  = p.product_id 
	    inner join orders o on o.order_id = oi.order_id 
    group by
	    c.category_id,
	    c.name,
	    o.delivery_info->>'$.method'
),
category_review_stats as (
    select
        c.category_id,
        avg(rev.rating) as avg_rating
    from
        categories c
        inner join products p on p.category_id = c.category_id
        inner join reviews rev on rev.product_id = p.product_id
    group by
        c.category_id
)
select
    c.name,
    sum(oi.quantity*oi.unit_price) as total_sales,
    sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
    group_concat(csr.specs) as popular_specs,
    crs.avg_rating,
    json_objectagg(cds.delivery_method,cds.delivery_count) as delivery_method_distribution
from
    categories c
    inner join products p on p.category_id = c.category_id
    inner join order_items oi on oi.product_id = p.product_id
    left join category_review_stats crs on crs.category_id = c.category_id
    left join category_delivery_stats cds on cds.category_id = c.category_id
    left join category_spec_ranks csr on csr.category_id = c.category_id
where
    csr.rank_in_category = 1
group by
    c.category_id,
    c.name,
    crs.avg_rating;


































       
