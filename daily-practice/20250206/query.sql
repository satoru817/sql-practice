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

--私の解答

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

--出力結果
|parent_category|number_of_products|total_sales|avg_unit_price|
|---------------|------------------|-----------|--------------|
|本・コミック         |7                 |22,000     |1,000         |
|家電             |4                 |30,500     |6,100         |
|ファッション         |4                 |18,000     |2,571         |



--問題2



with prod_parent_stats as (
    select
        pr.product_id,
        pr.name,
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
        pr.name,
        coalesce(pc.name,'親カテゴリー無し')
),
prod_parent_ranks as (
    select
        *,
        rank() over (partition by parent_category order by total_sales desc) as in_category_rank
    from
        prod_parent_stats
)
select
    parent_category,
    name as product_name,
    total_sales,
    total_quantity,
    in_category_rank
from
    prod_parent_ranks
where
    in_category_rank <= 3;

--実行結果
|parent_category|product_name|total_sales|total_quantity|in_category_rank|
|---------------|------------|-----------|--------------|----------------|
|ファッション         |Tシャツ M      |10,000     |5             |1               |
|ファッション         |スカート M      |8,000      |2             |2               |
|ファッション         |Tシャツ L      |           |              |3               |
|ファッション         |スカート L      |           |              |3               |
|家電             |コーヒーメーカー    |16,000     |2             |1               |
|家電             |電子ケトル       |8,500      |2             |2               |
|家電             |キーボード       |6,000      |1             |3               |
|本・コミック         |小説 A        |7,500      |5             |1               |
|本・コミック         |ビジネス本 A     |7,500      |3             |1               |
|本・コミック         |コミック A      |7,000      |14            |3               |



--AIの採点
## 採点結果: 95/100点

### 優れている点 👍
1. データ構造の理解と適切な実装
   - CTEを使用した段階的な処理
   - LEFT JOINによる欠損データの適切な処理
   - Window関数の効果的な活用

2. 堅牢性の高いコード
   - COALESCEによるNULL処理
   - NULLIFによるゼロ除算防止
   - 条件の適切な配置（注文のフィルタリング）

3. 要件の充足
   - 親カテゴリー単位での集計
   - TOP3の抽出
   - 売上0の商品も含めた表示

### 改善の余地がある点 📝
1. 金額のフォーマット
```sql
round(total_sales, 2) as total_sales
```

2. 日付条件の書き方
```sql
-- 現在の実装
year(o.order_date) = 2024 and quarter(o.order_date) = 4

-- より効率的な実装
o.order_date between '2024-10-01' and '2024-12-31'　
```

### 総評
実務レベルの非常に良質なクエリが実装できています。特にNULLの処理や結合の使い方が適切で、メンテナンス性も高いコードになっています。微細な最適化の余地はありますが、基本的な実装は完璧です。



--考察

year(o.order_date)=2024 and quarter(o.order_date)=4を
o.order_date between '2024-10-01' and '2024-12-31'
と書いたほうが効率が善いということを知らなかった。今後はbetween句を利用するようにしたい。

AIに褒められているが、claude.aiだけでなくほかのaiにも採点させたほうがいいのか？









