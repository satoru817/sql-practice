AIの出題
以下の分析問題を解いてみてください：

1. 商品の売上分析
   - 各商品の売上総額、販売数量、利益率を計算
   - カテゴリごとにグループ化
   - 売上額の高い順にランキング付け
   - 全体の売上に対する構成比も表示

2. 顧客の購買パターン分析
   - 顧客ランク別の平均購入額
   - 顧客ごとの購入頻度
   - 最も人気のある商品カテゴリ
   - 初回購入から2回目の購入までの日数


クエリを書く際は以下の点に注意してください：
- CTEを使用して複雑なクエリを整理する
- Window関数を適切に活用する商品名



問題1を改めて明確に提示させていただきます：

売上分析のクエリを作成してください。
出力には以下の情報を含めてください：

1. カテゴリパス（例：`Electronics > Smartphones`）
2. 商品名
3. 売上総額
4. 販売数量
5. 利益額（売上総額 - 原価総額）
6. 利益率（利益額 ÷ 売上総額 × 100）
7. カテゴリ内での売上ランク
8. 全体売上に対する構成比（％）

並び順は：
- カテゴリパス
- カテゴリ内での売上ランク

の順でソートしてください。

チャレンジしていただけますでしょうか？途中で質問があればお答えします。

私の解答

with prod_stats as (
    select
        pc.category_name as parent_category,
        c.category_name as child_category,
        p.product_name,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity) as total_order,
        sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
        sum(oi.quantity*(oi.unit_price-p.cost))/sum(oi.quantity*oi.unit_price) as profit_ratio
    from
        order_items oi
        inner join products p on p.product_id = oi.product_id
        inner join categories c on c.category_id = p.category_id
        inner join categories pc on pc.category_id = c.parent_category_id
    group by
        pc.category_name,
        c.category_name,
        p.product_name,
        p.cost
)       
select
    concat(parent_category,'>',child_category) as category_path,
    product_name,
    coalesce(round(total_sales,1),0) as total_sales,
    coalesce(total_order,0) as total_order,
    coalesce(round(total_profit,1),0) as total_profit,
    concat(round(100.0*coalesce(profit_ratio,0),1),'%') as profit_ratio,
    rank() over (partition by child_category order by total_sales desc) as rank_in_category,
    concat(round(total_sales*100.0/sum(total_sales) over (),1),'%') as sales_ratio
from
    prod_stats;

良い実装ですね！特に以下の点が素晴らしいと思います：

1. CTEを使って処理を分かりやすく段階分けしている
2. Window関数を効果的に使用している
3. COALESCEでNULL処理を適切に行っている
4. 比率計算を％表示で出力するよう工夫している

ただし、現在のクエリには1点だけ考慮が必要かもしれない点があります：

- 親カテゴリを持たない商品（categories.parent_category_idがNULLの商品）がデータに存在する場合、
現在のINNER JOINの構成では、それらが結果から除外されてしまいます。

この点を改善したい場合は、以下のいずれかの対応を検討できます：

1. 親カテゴリへのJOINをLEFT JOINに変更する
2. COALESCE(parent_category, child_category)を使用して親カテゴリがない場合の表示を工夫する

この点について、どのように対応するのが良いとお考えでしょうか？

改善した解答

with prod_stats as (
    select
        pc.category_name as parent_category,
        c.category_name as child_category,
        p.product_name,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity) as total_order,
        sum(oi.quantity*(oi.unit_price-p.cost)) as total_profit,
        sum(oi.quantity*(oi.unit_price-p.cost))/sum(oi.quantity*oi.unit_price) as profit_ratio
    from
        order_items oi
        inner join products p on p.product_id = oi.product_id
        inner join categories c on c.category_id = p.category_id
        left join categories pc on pc.category_id = c.parent_category_id
    group by
        pc.category_name,
        c.category_name,
        p.product_name,
        p.cost
)       
select
    concat(coalesce(parent_category,'親カテゴリーなし'),'>',child_category) as category_path,
    product_name,
    coalesce(round(total_sales,1),0) as total_sales,
    coalesce(total_order,0) as total_order,
    coalesce(round(total_profit,1),0) as total_profit,
    concat(round(100.0*coalesce(profit_ratio,0),1),'%') as profit_ratio,
    rank() over (partition by child_category order by total_sales desc) as rank_in_category,
    concat(round(total_sales*100.0/sum(total_sales) over (),1),'%') as sales_ratio
from
    prod_stats;

実行結果
親カテゴリーなし>Electronics	Tablet Y	600.0	1	200.0	33.3%	1	16.2%
Books>Fiction	Mystery Novel	100.0	5	60.0	60.0%	1	2.7%
Electronics>Laptops	Laptop Pro	1300.0	1	400.0	30.8%	1	35.1%
Books>Non-Fiction	Programming Guide	100.0	2	60.0	60.0%	1	2.7%
Electronics>Smartphones	Smartphone X	1600.0	2	400.0	25.0%	1	43.2%


素晴らしい改善ですね！以下の点が特に良いと思います：

1. `LEFT JOIN categories pc`に変更することで、親カテゴリがない商品も取得できるようになりました
2. `COALESCE(parent_category,'親カテゴリーなし')`で、NULLの場合の表示も分かりやすく対応されています
3. 元の分析機能はそのままに、データの網羅性が向上しました

このクエリで、以下のような分析が可能になります：
- 階層構造のある商品の分析
- 親カテゴリを持たない商品の分析
- すべての商品を含めた売上構成比の把握





2. 顧客の購買パターン分析
   - 顧客ランク別の平均購入額
   - 顧客ごとの購入頻度
   - 最も人気のある商品カテゴリ
   - 初回購入から2回目の購入までの日数

はい、問題2の「顧客の購買パターン分析」の要件を明確にします。

期待する出力として、以下の4つの観点での分析が必要です：

1. 顧客ランク別の平均購入額
- 顧客ランク（BRONZE, SILVER, GOLD, PLATINUM）ごとに集計
- 出力カラム：
  * 顧客ランク
  * そのランクの顧客数
  * 1注文あたりの平均購入額
  * そのランクの総注文数

2. 顧客ごとの購入頻度
- 各顧客の購入パターンを分析
- 出力カラム：
  * 顧客ID
  * 顧客名
  * 顧客ランク
  * 総注文回数
  * 総購入金額
  * 平均購入金額（1回あたり）

3. 最も人気のある商品カテゴリ
- 顧客ランクごとの好みのカテゴリを分析
- 出力カラム：
  * 顧客ランク
  * カテゴリパス（親カテゴリ > 子カテゴリ）
  * 購入金額
  * そのランク内での構成比率（％）

4. 初回購入から2回目の購入までの日数
- 複数回購入した顧客のみを対象
- 出力カラム：
  * 顧客ID
  * 顧客名
  * 初回購入日
  * 2回目の購入日
  * 経過日数

各分析は別々のクエリとして作成してください。どの分析から始めてみますか？


1. 顧客ランク別の平均購入額
- 顧客ランク（BRONZE, SILVER, GOLD, PLATINUM）ごとに集計
- 出力カラム：
  * 顧客ランク
  * そのランクの顧客数
  * 1注文あたりの平均購入額
  * そのランクの総注文数

select
    c.`rank` as `rank`,
    count(distinct c.customer_id) as customer_num,
    coalesce(round(sum(o.total_amount)/sum(o.order_id),1),0) as  avg_purchase,
    count(o.order_id) as total_order
from
    customers c
    inner join orders o on o.customer_id = c.customer_id
group by
    c.`rank`;


2. 顧客ごとの購入頻度
- 各顧客の購入パターンを分析
- 出力カラム：
  * 顧客ID
  * 顧客名
  * 顧客ランク
  * 総注文回数
  * 総購入金額
  * 平均購入金額（1回あたり）



select
    c.customer_id,
    c.customer_name,
    c.`rank`,
    count(o.order_id) as total_order,
    sum(o.total_amount) as total_purchase,
    round(coalesce(sum(o.total_amount)/count(o.order_id),0),1) as avg_order_amount
from
    customers c
    inner join orders o on o.customer_id = c.customer_id
group by
    c.customer_id,
    c.customer_name,
    c.`rank`
order by
    sum(o.total_amount) desc;

実行結果
customer_id|customer_name|rank    |total_order|total_purchase|avg_order_amount|
-----------+-------------+--------+-----------+--------------+----------------+
          1|John Smith   |GOLD    |          2|       1449.97|           725.0|
          2|Jane Doe     |SILVER  |          1|       1299.99|          1300.0|
          3|Bob Wilson   |PLATINUM|          1|        869.97|           870.0|
          4|Alice Brown  |BRONZE  |          1|         69.98|            70.0|


3. 最も人気のある商品カテゴリ
- 顧客ランクごとの好みのカテゴリを分析
- 出力カラム：
  * 顧客ランク
  * カテゴリパス（親カテゴリ > 子カテゴリ）
  * 購入金額
  * そのランク内での構成比率（％）

with category_rank_stats as (
    select
        cust.`rank`,
        coalesce(pc.category_name,'親カテゴリー無し') as parent_category,
        c.category_name as child_category,
        sum(oi.quantity*oi.unit_price) as total_purchase
    from
        customers cust
        inner join orders o on o.customer_id = cust.customer_id
        inner join order_items oi on oi.order_id = o.order_id
        inner join products p on p.product_id = oi.product_id
        inner join categories c on c.category_id = p.category_id
        left join categories pc on pc.category_id = c.parent_category_id
    group by
        cust.`rank`,
        pc.category_name,
        c.category_name
)
select
    `rank`,
    concat(parent_category,'>',child_category) as category_path,
    coalesce(round(total_purchase,1),0) as total_purchase,
    concat(coalesce(round(total_purchase*100.0/sum(total_purchase) over (partition by `rank`),1),0),'%') as ratio_in_rank
from
    category_rank_stats
order by
    `rank`,
    total_purchase desc;


実行結果    
|rank|category_path|total_purchase|ratio_in_rank|
|----|-------------|--------------|-------------|
|BRONZE|Books>Non-Fiction|50.0|55.6%|
|BRONZE|Books>Fiction|40.0|44.4%|
|GOLD|Electronics>Smartphones|800.0|55.6%|
|GOLD|親カテゴリー無し>Electronics|600.0|41.7%|
|GOLD|Books>Fiction|40.0|2.8%|
|PLATINUM|Electronics>Smartphones|800.0|92.0%|
|PLATINUM|Books>Non-Fiction|50.0|5.7%|
|PLATINUM|Books>Fiction|20.0|2.3%|
|SILVER|Electronics>Laptops|1300.0|100.0%|


4. 初回購入から2回目の購入までの日数
- 複数回購入した顧客のみを対象
- 出力カラム：
  * 顧客ID
  * 顧客名
  * 初回購入日
  * 2回目の購入日
  * 経過日数


with ranked_cte as (
    select
        c.customer_id,
        c.customer_name,
        o.order_date,
        row_number() over (partition by c.customer_id order by o.order_date asc) as ranking
    from
        customers c
        inner join orders o on o.customer_id = c.customer_id
),
first_orders as (
    select
        rc.*
    from
        ranked_cte rc
    where
        rc.ranking = 1
),
second_orders as (
    select
        rc.customer_id,
        rc.order_date
    from
        ranked_cte rc
    where
        rc.ranking = 2
)
select
    fo.*,
    so.order_date as second_order,
    timestampdiff(day,fo.order_date,so.order_date) as time_lapse
from
    first_orders fo
    inner join second_orders so on fo.customer_id = so.customer_id;
    
















