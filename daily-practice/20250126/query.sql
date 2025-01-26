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


4. トレンド分析
   - 過去3ヶ月の週次売上推移
   - 前週比での成長率
   - カテゴリごとの週次売上構成比の変化

with week_category_stats as (
    select
        date_sub(o.order_date,interval weekday(o.order_date) day) as week_start_date,
        c.category_id,
        c.name,
        sum(oi.quantity*oi.unit_price) as sales_amount,
    from
        order_items oi
        inner join orders o on o.order_id = oi.order_id
        inner join products p on p.product_id = oi.product_id
        inner join categories c on c.category_id = p.category_id
    where
--        timestamp_diff(month,o.order_date,curdate()) <= 3
        o.status != 'CANCELLED'
        and o.order_date >= date_sub(curdate(), interval 3 month)
    group by
        date_sub(o.order_date,interval weekday(o.order_date) day),
        c.category_id,
        c.name
),
pre_t as (
    select
        wcs.*,
        lag(wcs.sales_amount,1) over (partition by wcs.category_id order by wcs.week_start_date asc) as prev_week_sales,
        sum(wcs.sales_amount) over (partition by wcs.week_start_date) as week_total
    from
        week_category_stats wcs
)
select
    pt.week_start_date,
    pt.category_id,
    pt.name as category_name,
    round(pt.sales_amount,1) as sales_amount,
    round(pt.prev_week_sales,1) as prev_week_sales,
    concat(round(100.0*(pt.sales_amount-pt.prev_week_sales)/pt.prev_week_sales,1),'%') as growth_rate,
    concat(round(100.0*(pt.sales_amount/pt.week_total),1),'%') as sales_ratio
from
    pre_t pt;
    
    

--悔しいので問題３と４をもう一度解く


3. 商品パフォーマンス分析
   - 商品ごとの売上金額、販売数、粗利益を計算
   - 商品別の評価平均とレビュー数
   - 売上金額TOP10の商品リスト（カテゴリ名、評価平均を含む）

with prod_sale_stats as (
    select
        p.product_id,
        p.name,
        coalesce(sum(oi.quantity*oi.unit_price),0) as total_sales,
        coalesce(sum(oi.quantity),0) as total_quantity,
        coalesce(sum(oi.quantity*(oi.unit_price-p.cost)),0) as total_profit
    from
        products p
        left join order_items oi on oi.product_id = p.product_id
        left join orders o on o.order_id = oi.order_id and o.status != 'CANCELLED'
    group by
        p.product_id,
        p.name
),
prod_review_stats as (
    select
        product_id,
        round(avg(rating),1) as avg_rating
    from
        reviews
    group by
        product_id
),
pre_t as (
    select
        rank() over (order by pss.total_sales desc) as ranking,
        pss.name,
        pss.total_sales,
        pss.total_quantity,
        pss.total_profit,
        coalesce(prs.avg_rating,'レビューなし') as avg_rating
    from
        prod_sale_stats pss
        left join prod_review_stats prs
            on prs.product_id = pss.product_id
)
select
    ranking,
    name,
    round(total_sales,1) as total_sales,
    total_quantity,
    round(total_profit,1) as total_profit,
    avg_rating
from
    pre_t
where
    ranking <= 10
order by
    ranking asc;




4. トレンド分析
   - 過去3ヶ月の週次売上推移
   - 前週比での成長率
   - カテゴリごとの週次売上構成比の変化


with week_category_stats as (
    select
        date_sub(o.order_date,interval weekday(o.order_date) day) as start_of_week,
        c.name as category_name,
        sum(oi.quantity*oi.unit_price) as sales_amount,
    from
        categories c
        inner join products p on p.category_id = c.category_id
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id
    where
        o.order_date >= date_sub(curdate(),interval 3 month)
    group by
        date_sub(o.order_date,interval weekday(o.order_date) day),
        c.name,
        c.category_id
),
pre_t as (
    select
        start_of_week,
        category_name,
        sales_amount,
        lag(sales_amount,1) over (partition by category_name order by start_of_week asc) as prev_week_sales
    from
        week_category_stats
),
week_stats as (
    select
        start_of_week,
        sum(sales_amount) as week_total
    from
        week_category_stats
    group by
        start_of_week
)
select
    pt.start_of_week,
    pt.category_name,
    coalesce(round(pt.sales_amount,1),0) as sales_amount,
    coalesce(round(pt.prev_week_sales,1),0) as prev_week_sales,
    concat(round((pt.sales_amount-pt.prev_week_sales)*100.0/pt.prev_week_sales,1),'%') as growth_rate,
    concat(round(100.0*pt.sales_amount/ws.week_total,1),'%') as sales_ratio
from
    pre_t pt
    inner join week_stats ws on ws.start_of_week = pt.start_of_week;
    
    
# SQL学習まとめ（2025年1月26日）

## 重要な学びと気づき

### 1. 多対多結合での集計の罠
最も重要な発見は、複数テーブルの結合時における集計の問題でした。

**問題点の例**：
```sql
-- 誤った実装（商品の売上とレビューを直接結合）
select
    p.name,
    sum(oi.quantity) as total_quantity
from
    products p
    inner join order_items oi on oi.product_id = p.product_id
    inner join reviews r on r.product_id = p.product_id
group by
    p.name;
```

この場合、一つの商品に複数のレビューがあると、その分だけorder_itemsのレコードが重複してカウントされてしまいます。

**正しい実装**：
```sql
-- 別々に集計してから結合
with order_stats as (
    select
        product_id,
        sum(quantity) as total_quantity
    from order_items
    group by product_id
),
review_stats as (
    select
        product_id,
        avg(rating) as avg_rating
    from reviews
    group by product_id
)
select
    p.name,
    o.total_quantity,
    r.avg_rating
from
    products p
    left join order_stats o on o.product_id = p.product_id
    left join review_stats r on r.product_id = p.product_id;
```

### 2. 時系列分析のパターン
週次集計などの時系列分析では、以下のパターンが効果的だとわかりました：

1. まず基本的な集計を行う
2. Window関数（LAG等）で前期比較を計算
3. 全体値に対する構成比を計算

```sql
with weekly_stats as (
    select
        date_sub(date, interval weekday(date) day) as week_start,
        sum(amount) as total
    from sales
    group by date_sub(date, interval weekday(date) day)
),
with_prev as (
    select
        *,
        lag(total) over (order by week_start) as prev_week
    from weekly_stats
)
select
    week_start,
    total,
    prev_week,
    case
        when prev_week = 0 then 'N/A'
        else concat(round((total - prev_week) * 100.0 / prev_week, 1), '%')
    end as growth_rate
from with_prev;
```

### 3. LEFT JOINの重要性
データ分析では、存在しないデータも含めた完全な状況を把握することが重要です：

```sql
-- 商品の売上がゼロでもレビューがあれば表示
select
    p.name,
    coalesce(sum(oi.quantity), 0) as sales_quantity,
    count(r.review_id) as review_count
from
    products p
    left join order_items oi on oi.product_id = p.product_id
    left join reviews r on r.product_id = p.product_id
group by
    p.name;
```

## 今後の課題

1. **実行計画の理解**
   - より大規模なデータでの最適化
   - インデックスの効果的な活用

2. **より複雑な集計パターン**
   - ピボットテーブル
   - 再帰的な集計
   - 移動平均の計算

3. **エラー処理の強化**
   - ゼロ除算の対策
   - NULL値の適切な処理
   - エッジケースの考慮

## 塾システムへの応用

学んだパターンは以下のような分析に活用できます：

1. **成績分析**
   ```sql
   -- 生徒ごとの科目別平均点を集計してから
   -- クラスごとの平均を計算
   with student_averages as (
       select
           student_id,
           subject,
           avg(score) as avg_score
       from test_results
       group by student_id, subject
   )
   select
       c.class_name,
       s.subject,
       avg(s.avg_score) as class_avg
   from
       classes c
       inner join class_students cs on cs.class_id = c.class_id
       inner join student_averages s on s.student_id = cs.student_id
   group by
       c.class_name, s.subject;
   ```

2. **時系列での成績推移**
   - 週次・月次の平均点推移
   - 前回からの伸び率計算
   - 科目間の相対的な強さの分析

これらの知識は、より正確で意味のある分析を可能にし、システムの価値を高めることができます。



























