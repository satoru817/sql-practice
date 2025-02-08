

各カテゴリーの売上分析を行い、以下の情報を表示してください：
- カテゴリー名
- 総売上金額
- 平均注文単価
- カスタマイズされた注文の割合（パーセンテージ）
- そのカテゴリーで最も人気のある素材（attributesのmaterial）

ヒント：
- JSON_EXTRACT関数を使用して商品の素材（material）を抽出できます
- カスタマイズ注文は、order_itemsのcustomizationカラムがNULLでない注文です
- 集計はproducts, categories, orders, order_itemsの結合が必要です


--とりあえずCTEのテスト
    select
        c.category_id,
        c.name as category_name,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity*oi.unit_price)/nullif(sum(oi.quantity),0) as avg_unit_price,
        count(distinct case when oi.customization IS NOT NULL then o.order_id end) as customized_order_count,
        count(distinct o.order_id) as order_count
    from
        categories c
        inner join products p on p.category_id = c.category_id
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id
    group by
        c.category_id,
        c.name;

|category_id|category_name|total_sales|avg_unit_price|customized_order_count|order_count|
|-----------|-------------|-----------|--------------|----------------------|-----------|
|4          |ダイヤモンドリング    |930,000    |71,538.461538 |3                     |3          |
|5          |パールネックレス     |145,000    |72,500        |1                     |2          |
|6          |ゴールドピアス      |95,000     |31,666.666667 |2                     |3          |
|7          |ブレスレット       |200,000    |200,000       |1                     |1          |
|8          |シルバーリング      |25,000     |25,000        |0                     |1          |


count(distinct case when oi.customization IS NOT NULL then o.order_id end) as customized_order_count,

このdistinctが重要。これがないと一つのorderに複数のcustomizeされたorder_itemsがあるとき重複カウントされてしまう。

--私の解答
with category_stats as (
    select
        c.category_id,
        c.name as category_name,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity*oi.unit_price)/nullif(sum(oi.quantity),0) as avg_unit_price,
        count(distinct case when oi.customization IS NOT NULL then o.order_id end) as customized_order_count,
        count(distinct o.order_id) as order_count
    from
        categories c
        inner join products p on p.category_id = c.category_id
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id
    where
        o.payment_status != 'cancelled'
    group by
        c.category_id,
        c.name
),
category_material_stats as (
    select
        c.category_id,
        pr.attributes->>'$.material' as material,
        sum(oi.quantity) as total_quantity
    from
        categories c 
        inner join products pr on pr.category_id = c.category_id
        inner join order_items oi on oi.product_id = pr.product_id
        inner join orders o on o.order_id = oi.order_id
    where
        o.payment_status != 'cancelled'
    group by
        c.category_id,
        pr.attributes->>'$.material'
),
category_material_ranks as (
    select
        category_id,
        material,
        rank() over (partition by material order by total_quantity desc) as rank_in_category
    from
        category_material_stats
),
category_popular_material as (
	select
		category_id,
		group_concat(material) as popular_materials
	from
		category_material_ranks
	where
		rank_in_category = 1
	group by
		category_id
) 
select
    cs.category_name,
    round(cs.total_sales,2) as total_sales,
    round(cs.avg_unit_price,2) as avg_unit_price,
    concat(round(100.0*cs.customized_order_count/cs.order_count,2),'%') as customized_ratio,
    cpm.popular_materials
from
    category_stats cs
    left join category_popular_material cpm
        on cpm.category_id = cs.category_id;

--実行結果
|category_name|total_sales|avg_unit_price|customized_ratio|popular_materials|
|-------------|-----------|--------------|----------------|-----------------|
|ダイヤモンドリング    |930,000    |71,538.46     |100.00%         |platinum         |
|パールネックレス     |145,000    |72,500        |50.00%          |silver,white_gold|
|ゴールドピアス      |95,000     |31,666.67     |66.67%          |gold             |
|ブレスレット       |200,000    |200,000       |100.00%         |white_gold       |
|シルバーリング      |25,000     |25,000        |0.00%           |silver           |
  
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        




