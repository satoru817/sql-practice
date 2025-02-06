## 問題
2024年第4四半期（10-12月）の売上データについて、以下の分析を行うクエリを作成してください：

1. 親カテゴリー別の総売上額を算出し、売上額順に表示
   - 親カテゴリー名
   - 総売上額
   - カテゴリー内の商品数
   - 平均注文単価

2. 各親カテゴリーでTOP3の売れ筋商品を抽出
   - カテゴリー名
   - 商品名
   - 売上個数
   - 売上金額
   - カテゴリー内順位

要件：
- カテゴリーは親カテゴリー単位で集計
- キャンセルされていない注文のみを対象
- 金額は小数点以下2桁で表示
- 売上0の商品も含める
- Window関数を使用してランキングを算出

はい、ご指摘ありがとうございます。
もう少し具体的に要件を明確にさせていただきます：

1. カテゴリー内商品数について：
- productsテーブルに登録されている全商品が対象
- 売れていない商品も含めてカウント
- 在庫切れ（stock = 0）の商品も含める

2. 注文について：
- status = 'cancelled' の注文は除外
- その他のステータス（completed, shipped など）は全て含める

3. より具体的な出力イメージ：

1つ目の集計クエリの出力例：
```
親カテゴリー名 | 商品数 | 総売上額 | 平均注文単価
書籍          | 100    | 1500000 | 2500.00
家電          | 50     | 3000000 | 15000.00
```
- 商品数：その親カテゴリーに属する全商品数（売上の有無に関わらず）
- 総売上額：期間内の実際の売上合計
- 平均注文単価：売上が発生した注文の平均単価

では、この要件でクエリを作成していただけますでしょうか？


with prod_parent_stats as (
    select
        pr.product_id,
        coalesce(pc.name,'親カテゴリー無し') as parent_category,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity) as total_quantity
    from
        products pr
        left join categories c on c.category_id = pr.category_id
        left join categories pc on pc.category_id = c.parent_category_id
        left join order_items oi on oi.product_id = pr.product_id
        left join orders o 
            on o.order_id = oi.order_id
            and year(o.order_date) = 2024
            and quarter(o.order_date) = 4
            and o.status != 'cancelled'
    group by
        pr.product_id,
        coalesce(pc.name,'親カテゴリー無し')
)
select
    parent_category,
    count(product_id) as number_of_products,
    sum(total_sales) as total_sales,
    round(sum(total_sales)/nullif(sum(total_quantity),0)) as avg_unit_price
from
    prod_parent_stats
group by
    parent_category;


|parent_category|number_of_products|total_sales|avg_unit_price|
|---------------|------------------|-----------|--------------|
|本・コミック         |7                 |22,000     |1,000         |
|家電             |4                 |30,500     |6,100         |
|ファッション         |4                 |18,000     |2,571         |












