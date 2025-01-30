## 問題
2023年第4四半期（10-12月）における以下のレポートを作成してください：

1. 親カテゴリごとの以下の情報を抽出：
   - 総売上額
   - カテゴリ内の平均購入単価（注文明細の単価の平均）
   - カテゴリ内で最も売れている商品TOP3（売上金額ベース）をカンマ区切りで1列に表示

2. レポートの要件：
   - 親カテゴリが設定されていないカテゴリは、そのカテゴリ自体を親として扱う
   - 売上がなかったカテゴリは表示しない
   - 金額は小数点以下2桁で表示
   - 商品名の結合はGROUP_CONCATを使用

with prod_parent_stats as (
    select
        coalesce(pc.category_id,c.category_id) as parent_category_id,
        coalesce(pc.category_name,c.category_name) as parent_category_name,
        pr.product_name,
        pr.product_id,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity) as total_quantity
    from
        order_items oi
        inner join orders o 
            on o.order_id = oi.order_id
            and year(o.order_date) = '2023'
            and quarter(o.order_date) = '4'
            and o.status != 'cancelled'
        inner join products pr on pr.product_id = oi.product_id
        inner join categories c on c.category_id = p.category_id
        left join categories pc on pc.category_id = c.parent_category_id
    group by
        coalesce(pc.category_id,c.category_id),
        coalesce(pc.category_name,c.category_name),
        pr.product_name,
        pr.product_id
),
prod_parent_ranks as (
    select
        parent_category_id,
        product_name,
        rank() over (partition by parent_category_id order by total_sales desc) as rank_in_category
    from
        prod_parent_stats 
),
top_sellings as (
    select
        parent_category_id,
        group_concat(
            product_name
            order by rank_in_category desc
            separator ','        
        ) as top_seller
    from
        prod_paren_ranks
    where
        rank_in_category <= 3
    group by
        paren_category_id
)
select
    pps.parent_category_name,
    round(sum(pps.total_sales),2) as total_sales,
    round(sum(pps.total_sales)/sum(pps.total_quantity),2) as weighed_avg_unit_price,
    ts.top_seller
from
    prod_parent_stats pps
    inner join top_sellings ts on ts.parent_category_id = pps.parent_category_id
group by
    pps.parent_category_name,
    ts.top_seller;
    
--AIの指摘
申し訳ありません。ご指摘の通りです。私の指摘4は誤りでした。最終的な結合で注文ステータスのフィルタリングは行っていません。

正しい改善点は以下の3つです：

1. テーブル参照の誤り
```sql
inner join categories c on c.category_id = p.category_id  
-- ここでp.category_idとなっていますが、pr.category_idの誤りです
```

2. タイプミス
```sql
from prod_paren_ranks  -- prod_parent_ranksの誤り
group by paren_category_id  -- parent_category_idの誤り
```

3. GROUP_CONCATでのorder by
```sql
order by rank_in_category desc  -- ascの方が1位から順に表示されます
```

申し訳ありませんが、4つ目の指摘は私の誤りでした。訂正させていただきます。












