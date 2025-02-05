では、同じテーブル定義を使用して、以下の商品分析の問題を出題させていただきます：

## 問題
2024年1月の商品パフォーマンスを分析してください。以下の条件で商品を分類し、分析を行ってください：

利益貢献度による商品分類：
- High Profit（利益額が上位20%の商品）
- Mid Profit（利益額が中位60%の商品）
- Low Profit（利益額が下位20%の商品）

各分類について以下の情報を集計してください：
- 商品数
- 総売上金額
- 総利益金額（売上 - 原価）
- 平均利益率（総利益÷総売上×100）
- 合計販売数量
- カテゴリ別の商品数（同じ行にJSON形式で含める）

条件：
- 2024年1月の販売データのみを対象とする
- キャンセルされた注文は除外
- 金額は小数点2位で四捨五入
- カテゴリ集計は親カテゴリレベルで実施
- 売上0の商品は除外

期待される出力イメージ：
```
profit_rank | product_count | total_sales | total_profit | profit_margin | total_quantity | category_distribution
High Profit | 100          | 2500000.00  | 750000.00    | 30.00         | 2500          | {"Books": 40, "Electronics": 35, "Clothing": 25}
Mid Profit  | 300          | 3000000.00  | 600000.00    | 20.00         | 5000          | {"Books": 100, "Electronics": 120, "Clothing": 80}
Low Profit  | 100          | 1000000.00  | 100000.00    | 10.00         | 2000          | {"Books": 30, "Electronics": 40, "Clothing": 30}
```

このクエリを書いてみましょう。

--私の解答（JSON形式のやり方がわからない)

with prod_stats as (
    select
        p.product_id,
        coalesce(pc.name,'カテゴリー無し') as parent_category,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
        sum(oi.quantity) as total_quantity
    from
        products p
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id
        left join categories c on c.category_id = p.category_id
        left join categories pc on pc.category_id = c.parent_category_id
    where
        date_format(o.order_date,'%Y-%m')='2024-01'
        and o.status != 'cancelled'
    group by
        p.product_id
),
prod_percentiles as (
    select
        ps.*,
        percent_rank() over (order by ps.total_profit desc)  as percentile
    from
        prod_stats ps
),
prod_ranks as (
    select
        pp.product_id,
        pp.parent_category,
        pp.total_sales,
        pp.total_profit,
        pp.total_quantity,
        case
            when percentile <= 0.2 then 'High Profit'
            when percentile <= 0.8 then 'Mid Profit'
            else 'Low Profit'
        end as profit_rank
    from
        prod_percentiles pp
)
select
    profit_rank,
    count(product_id) as product_count,
    round(sum(total_sales),2) as total_sales,
    round(sum(total_profit),2) as total_profit,
    concat(round(100.0*sum(total_profit)/sum(total_sales),2),'%') as profit_margin,
    sum(total_quantity) as total_quantity
from
    prod_ranks 
group by
    profit_rank;

--実行結果(ここまではOK)
|profit_rank|product_count|total_sales|total_profit|profit_margin|total_quantity|
|-----------|-------------|-----------|------------|-------------|--------------|
|High Profit|3            |2,999      |799         |26.64%       |3             |
|Mid Profit |6            |1,368.89   |533.89      |39.00%       |12            |
|Low Profit |3            |189.94     |94.94       |49.98%       |6             |


さて、JSON形式をどうすればいい？

chatgptに聞いた

MySQLで`PERCENT_RANK()`を計算し、結果をJSON形式で取得する方法を示します。  

---

### ❶ **データの準備**
対象のテーブル `students` を作成し、サンプルデータを挿入します。

```sql
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    score INT
);

INSERT INTO students (name, score) VALUES 
('Alice', 95),
('Bob', 85),
('Carol', 80),
('Dave', 70),
('Eve', 60);
```

---

### ❷ **`PERCENT_RANK()` を適用し、JSON形式で取得**
MySQLの`JSON_OBJECT()`を利用して、結果をJSON形式で出力します。

```sql
SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
        'id', id,
        'name', name,
        'score', score,
        'percentile_rank', PERCENT_RANK() OVER (ORDER BY score DESC)
    )
) AS result_json
FROM students;
```

---

### ❸ **出力結果（JSON形式）**
```json
[
    {"id":1,"name":"Alice","score":95,"percentile_rank":0.0000},
    {"id":2,"name":"Bob","score":85,"percentile_rank":0.2500},
    {"id":3,"name":"Carol","score":80,"percentile_rank":0.5000},
    {"id":4,"name":"Dave","score":70,"percentile_rank":0.7500},
    {"id":5,"name":"Eve","score":60,"percentile_rank":1.0000}
]
```

---

### **ポイント**
1. **`PERCENT_RANK() OVER (ORDER BY score DESC)`**  
   → `score`の降順でパーセンタイルランクを計算。
2. **`JSON_OBJECT()`**  
   → 各行をJSONオブジェクトに変換。
3. **`JSON_ARRAYAGG()`**  
   → 全データを1つのJSON配列にまとめる。

---

この方法なら、MySQLで直接JSON形式のデータを取得できます！  
他のカラムも追加できますが、何かカスタマイズしたい部分はありますか？

--これを受けて

with prod_stats as (
    select
        p.product_id,
        coalesce(pc.name,'カテゴリー無し') as parent_category,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
        sum(oi.quantity) as total_quantity
    from
        products p
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id
        left join categories c on c.category_id = p.category_id
        left join categories pc on pc.category_id = c.parent_category_id
    where
        date_format(o.order_date,'%Y-%m')='2024-01'
        and o.status != 'cancelled'
    group by
        p.product_id
),
prod_percentiles as (
    select
        ps.*,
        percent_rank() over (order by ps.total_profit desc)  as percentile
    from
        prod_stats ps
),
prod_ranks as (
    select
        pp.product_id,
        pp.parent_category,
        pp.total_sales,
        pp.total_profit,
        pp.total_quantity,
        case
            when percentile <= 0.2 then 'High Profit'
            when percentile <= 0.8 then 'Mid Profit'
            else 'Low Profit'
        end as profit_rank
    from
        prod_percentiles pp
)
select
    profit_rank,
    count(product_id) as product_count,
    round(sum(total_sales),2) as total_sales,
    round(sum(total_profit),2) as total_profit,
    concat(round(100.0*sum(total_profit)/sum(total_sales),2),'%') as profit_margin,
    sum(total_quantity) as total_quantity,
    json_object(
        parent_category,
        count(*) over (partition by parent_category)
    ) as category_distribution
from
    prod_ranks 
group by
    profit_rank,
    parent_category;

--これの実行結果
|profit_rank|product_count|total_sales|total_profit|profit_margin|total_quantity|category_distribution |
|-----------|-------------|-----------|------------|-------------|--------------|----------------------|
|Mid Profit |1            |149.97     |74.97       |49.99%       |3             |"{\"Books\": 2}"      |
|Low Profit |3            |189.94     |94.94       |49.98%       |6             |"{\"Books\": 2}"      |
|Mid Profit |4            |519.92     |259.92      |49.99%       |8             |"{\"Clothing\": 1}"   |
|High Profit|3            |2,999      |799         |26.64%       |3             |"{\"Electronics\": 2}"|
|Mid Profit |1            |699        |199         |28.47%       |1             |"{\"Electronics\": 2}"|


実行結果がおかしい。

with prod_stats as (
    select
        p.product_id,
        coalesce(pc.name,'カテゴリー無し') as parent_category,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
        sum(oi.quantity) as total_quantity
    from
        products p
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id
        left join categories c on c.category_id = p.category_id
        left join categories pc on pc.category_id = c.parent_category_id
    where
        date_format(o.order_date,'%Y-%m')='2024-01'
        and o.status != 'cancelled'
    group by
        p.product_id
),
prod_percentiles as (
    select
        ps.*,
        percent_rank() over (order by ps.total_profit desc)  as percentile
    from
        prod_stats ps
),
prod_ranks as (
    select
        pp.product_id,
        pp.parent_category,
        pp.total_sales,
        pp.total_profit,
        pp.total_quantity,
        case
            when percentile <= 0.2 then 'High Profit'
            when percentile <= 0.8 then 'Mid Profit'
            else 'Low Profit'
        end as profit_rank
    from
        prod_percentiles pp
)
select
    profit_rank,
    count(product_id) as product_count,
    round(sum(total_sales),2) as total_sales,
    round(sum(total_profit),2) as total_profit,
    concat(round(100.0*sum(total_profit)/sum(total_sales),2),'%') as profit_margin,
    sum(total_quantity) as total_quantity,
    json_arrayagg(json_object(
        parent_category,
        count(*) over (partition by parent_category)
    )) as category_distribution
from
    prod_ranks 
group by
    profit_rank,
    parent_category;

--これも実行エラー

with句で先に出しておくか？
with prod_stats as (
    select
        p.product_id,
        coalesce(pc.name,'カテゴリー無し') as parent_category,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
        sum(oi.quantity) as total_quantity
    from
        products p
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id
        left join categories c on c.category_id = p.category_id
        left join categories pc on pc.category_id = c.parent_category_id
    where
        date_format(o.order_date,'%Y-%m')='2024-01'
        and o.status != 'cancelled'
    group by
        p.product_id
),
prod_percentiles as (
    select
        ps.*,
        percent_rank() over (order by ps.total_profit desc)  as percentile
    from
        prod_stats ps
),
prod_ranks as (
    select
        pp.product_id,
        pp.parent_category,
        pp.total_sales,
        pp.total_profit,
        pp.total_quantity,
        case
            when percentile <= 0.2 then 'High Profit'
            when percentile <= 0.8 then 'Mid Profit'
            else 'Low Profit'
        end as profit_rank
    from
        prod_percentiles pp
),
json_cte as(
    select
        profit_rank,
        json_objectagg(
            parent_category,total_quantity        
        ) as distribution
    from(
        select
            pr.profit_rank as profit_rank,
            pr.parent_category as parent_category,
            sum(pr.total_quantity) as total_quantity
        from
            prod_ranks pr
        group by
            pr.profit_rank,
            pr.parent_category         
    ) as pre_t
    group by
        profit_rank    
)
select
    pr.profit_rank,
    count(pr.product_id) as product_count,
    round(sum(pr.total_sales),2) as total_sales,
    round(sum(pr.total_profit),2) as total_profit,
    concat(round(100.0*sum(pr.total_profit)/sum(pr.total_sales),2),'%') as profit_margin,
    sum(pr.total_quantity) as total_quantity,
    jc.distribution
from
    prod_ranks pr
    inner join json_cte jc on jc.profit_rank = pr.profit_rank 
group by
    profit_rank,
    parent_category;

--実行結果

|profit_rank|product_count|total_sales|total_profit|profit_margin|total_quantity|distribution                                         |
|-----------|-------------|-----------|------------|-------------|--------------|-----------------------------------------------------|
|High Profit|3            |2,999      |799         |26.64%       |3             |"{\"Electronics\": 3}"                               |
|Mid Profit |1            |699        |199         |28.47%       |1             |"{\"Books\": 3, \"Clothing\": 8, \"Electronics\": 1}"|
|Mid Profit |4            |519.92     |259.92      |49.99%       |8             |"{\"Books\": 3, \"Clothing\": 8, \"Electronics\": 1}"|
|Mid Profit |1            |149.97     |74.97       |49.99%       |3             |"{\"Books\": 3, \"Clothing\": 8, \"Electronics\": 1}"|
|Low Profit |3            |189.94     |94.94       |49.98%       |6             |"{\"Books\": 6}"                                     |


惜しい。最後のgroup byでparent_categoryが余計。

with prod_stats as (
    select
        p.product_id,
        coalesce(pc.name,'カテゴリー無し') as parent_category,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
        sum(oi.quantity) as total_quantity
    from
        products p
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id
        left join categories c on c.category_id = p.category_id
        left join categories pc on pc.category_id = c.parent_category_id
    where
        date_format(o.order_date,'%Y-%m')='2024-01'
        and o.status != 'cancelled'
    group by
        p.product_id
),
prod_percentiles as (
    select
        ps.*,
        percent_rank() over (order by ps.total_profit desc)  as percentile
    from
        prod_stats ps
),
prod_ranks as (
    select
        pp.product_id,
        pp.parent_category,
        pp.total_sales,
        pp.total_profit,
        pp.total_quantity,
        case
            when percentile <= 0.2 then 'High Profit'
            when percentile <= 0.8 then 'Mid Profit'
            else 'Low Profit'
        end as profit_rank
    from
        prod_percentiles pp
),
json_cte as(
    select
        profit_rank,
        json_objectagg(
            parent_category,total_quantity        
        ) as distribution
    from(
        select
            pr.profit_rank as profit_rank,
            pr.parent_category as parent_category,
            sum(pr.total_quantity) as total_quantity
        from
            prod_ranks pr
        group by
            pr.profit_rank,
            pr.parent_category         
    ) as stats_of_profit_rank_and_parent_category --これ注意（table名のaliasが必要)
    group by
        profit_rank    
)
select
    pr.profit_rank,
    count(pr.product_id) as product_count,
    round(sum(pr.total_sales),2) as total_sales,
    round(sum(pr.total_profit),2) as total_profit,
    concat(round(100.0*sum(pr.total_profit)/sum(pr.total_sales),2),'%') as profit_margin,
    sum(pr.total_quantity) as total_quantity,
    jc.distribution
from
    prod_ranks pr
    inner join json_cte jc on jc.profit_rank = pr.profit_rank 
group by
    profit_rank;

|profit_rank|product_count|total_sales|total_profit|profit_margin|total_quantity|distribution                                         |
|-----------|-------------|-----------|------------|-------------|--------------|-----------------------------------------------------|
|High Profit|3            |2,999      |799         |26.64%       |3             |"{\"Electronics\": 3}"                               |
|Mid Profit |6            |1,368.89   |533.89      |39.00%       |12            |"{\"Books\": 3, \"Clothing\": 8, \"Electronics\": 1}"|
|Low Profit |3            |189.94     |94.94       |49.98%       |6             |"{\"Books\": 6}"                                     |


おしい。分布は要件では売上ではなく、商品数だった。json_cteを書き換える

with prod_stats as (
    select
        p.product_id,
        coalesce(pc.name,'カテゴリー無し') as parent_category,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
        sum(oi.quantity) as total_quantity
    from
        products p
        inner join order_items oi on oi.product_id = p.product_id
        inner join orders o on o.order_id = oi.order_id
        left join categories c on c.category_id = p.category_id
        left join categories pc on pc.category_id = c.parent_category_id
    where
        date_format(o.order_date,'%Y-%m')='2024-01'
        and o.status != 'cancelled'
    group by
        p.product_id
),
prod_percentiles as (
    select
        ps.*,
        percent_rank() over (order by ps.total_profit desc)  as percentile
    from
        prod_stats ps
),
prod_ranks as (
    select
        pp.product_id,
        pp.parent_category,
        pp.total_sales,
        pp.total_profit,
        pp.total_quantity,
        case
            when percentile <= 0.2 then 'High Profit'
            when percentile <= 0.8 then 'Mid Profit'
            else 'Low Profit'
        end as profit_rank
    from
        prod_percentiles pp
),
json_cte as(
    select
        distinct profit_rank,
        json_objectagg(
            parent_category,total_products     
        ) as distribution
    from(
        select
            pr.profit_rank as profit_rank,
            pr.parent_category as parent_category,
            count(pr.product_id) as total_products
        from
            prod_ranks pr
        group by
            pr.profit_rank,
            pr.parent_category         
    ) as pre_t
    group by
        profit_rank    
)
select
    pr.profit_rank,
    count(pr.product_id) as product_count,
    round(sum(pr.total_sales),2) as total_sales,
    round(sum(pr.total_profit),2) as total_profit,
    concat(round(100.0*sum(pr.total_profit)/sum(pr.total_sales),2),'%') as profit_margin,
    sum(pr.total_quantity) as total_quantity,
    jc.distribution
from
    prod_ranks pr
    inner join json_cte jc on jc.profit_rank = pr.profit_rank 
group by
    profit_rank;

|profit_rank|product_count|total_sales|total_profit|profit_margin|total_quantity|distribution                                         |
|-----------|-------------|-----------|------------|-------------|--------------|-----------------------------------------------------|
|High Profit|3            |2,999      |799         |26.64%       |3             |"{\"Electronics\": 3}"                               |
|Mid Profit |6            |1,368.89   |533.89      |39.00%       |12            |"{\"Books\": 1, \"Clothing\": 4, \"Electronics\": 1}"|
|Low Profit |3            |189.94     |94.94       |49.98%       |6             |"{\"Books\": 3}"                                     |


これで多分正解。AIに採点

クエリの基本的な構造は良いですが、いくつかの改善点があります：

1. JOINの考慮:
- order_itemsのproduct_idとorder_idにNOT NULL制約がないため、INNER JOINではなくLEFT JOINを使用すべき

2. GROUP BY句:
- profit_rankでグループ化する際に、distributionも含める必要がありますー＞これがなくても何故か動いていた。

修正したクエリは以下のようになります：

```sql
with prod_stats as (
    select
        p.product_id,
        coalesce(pc.name,'カテゴリー無し') as parent_category,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
        sum(oi.quantity) as total_quantity
    from
        products p
        left join order_items oi on oi.product_id = p.product_id
        left join orders o on o.order_id = oi.order_id
        left join categories c on c.category_id = p.category_id
        left join categories pc on pc.category_id = c.parent_category_id
    where
        date_format(o.order_date,'%Y-%m')='2024-01'
        and o.status != 'cancelled'
    group by
        p.product_id,
        coalesce(pc.name,'カテゴリー無し')
),
prod_percentiles as (
    select
        ps.*,
        percent_rank() over (order by ps.total_profit desc) as percentile
    from
        prod_stats ps
    where
        ps.total_sales > 0  -- 売上0の商品を除外
),
prod_ranks as (
    select
        pp.product_id,
        pp.parent_category,
        pp.total_sales,
        pp.total_profit,
        pp.total_quantity,
        case
            when percentile <= 0.2 then 'High Profit'
            when percentile <= 0.8 then 'Mid Profit'
            else 'Low Profit'
        end as profit_rank
    from
        prod_percentiles pp
),
json_cte as(
    select
        distinct profit_rank,
        json_objectagg(
            parent_category,total_products     
        ) as distribution
    from(
        select
            pr.profit_rank,
            pr.parent_category,
            count(pr.product_id) as total_products
        from
            prod_ranks pr
        group by
            pr.profit_rank,
            pr.parent_category         
    ) as pre_t
    group by
        profit_rank    
)
select
    pr.profit_rank,
    count(pr.product_id) as product_count,
    round(sum(pr.total_sales),2) as total_sales,
    round(sum(pr.total_profit),2) as total_profit,
    concat(round(100.0*sum(pr.total_profit)/sum(pr.total_sales),2),'%') as profit_margin,
    sum(pr.total_quantity) as total_quantity,
    jc.distribution as category_distribution
from
    prod_ranks pr
    inner join json_cte jc on jc.profit_rank = pr.profit_rank 
group by
    pr.profit_rank,
    jc.distribution
order by
    case pr.profit_rank
        when 'High Profit' then 1
        when 'Mid Profit' then 2
        when 'Low Profit' then 3
    end;
```

主な改善点：
1. INNER JOINをLEFT JOINに変更
2. 売上0の商品の除外条件を追加
3. GROUP BY句にdistributionを追加
4. 結果の並び順を追加
5. カラム名を期待される出力に合わせて調整

これでより堅牢で要件に適合した結果が得られます。


|profit_rank|product_count|total_sales|total_profit|profit_margin|total_quantity|category_distribution                                |
|-----------|-------------|-----------|------------|-------------|--------------|-----------------------------------------------------|
|High Profit|3            |2,999      |799         |26.64%       |3             |"{\"Electronics\": 3}"                               |
|Mid Profit |6            |1,368.89   |533.89      |39.00%       |12            |"{\"Books\": 1, \"Clothing\": 4, \"Electronics\": 1}"|
|Low Profit |3            |189.94     |94.94       |49.98%       |6             |"{\"Books\": 3}"                                     |

--結果
AIのと私のとで結果は変わらない。









