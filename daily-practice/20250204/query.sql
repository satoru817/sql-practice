
**問題**
スマートフォンカテゴリー（category_id = 5）の商品について、以下の分析を行ってください：

1. 各商品の売上情報と、JSONで保存されている以下のスペック情報を抽出してください：
   - 画面サイズ（specs -> "$.screen_size"）
   - RAM容量（specs -> "$.ram"）
   - ストレージ容量（specs -> "$.storage"）

2. 結果には以下の情報を含めてください：
   - 商品名
   - 商品価格
   - 総販売数
   - 総売上金額
   - 上記のスペック情報

3. 以下の条件で抽出してください：
   - 2024年の販売データのみ
   - 総販売数が10個以上の商品のみ
   - キャンセルされた注文（status = 'cancelled'）は除外
   - 売上金額の降順で表示

この問題では、JSONデータの抽出、複数テーブルの結合、集計処理、条件付きフィルタリングなど、複数のSQLの機能を組み合わせる必要があります。回答をお願いします。

SELECT
    pr.name as '商品名',
    pr.price as '価格',
    sum(oi.quantity) as '総販売数',
    sum(oi.quantity*oi.unit_price) as '総売上金額',
    JSON_EXTRACT(pr.specs,'$.screen_size') as '画面サイズ',
    JSON_EXTRACT(pr.specs,'$.ram') as 'RAM容量',
    JSON_EXTRACT(pr.specs,'$.storage') as 'ストレージ容量'
from
    products pr
    inner join order_items oi on oi.product_id = pr.product_id
    inner join orders o on o.order_id = oi.order_id
where
    year(o.order_date) = '2024'
    and o.status != 'cancelled'
    and pr.category_id = '5'
group by
    pr.name,
    pr.price,
    pr.specs,
    pr.product_id
having
    sum(oi.quantity) >= 10
order by
    sum(oi.quantity*oi.unit_price) desc;





















