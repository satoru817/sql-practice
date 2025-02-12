問題：以下の要件を満たすSQLクエリを作成してください。

1. 全ての商品について、以下の情報を取得してください：
   - 商品名
   - カテゴリー名（親カテゴリー名も含む）
   - レビュー数
   - 平均評価（rating）
   - おすすめされた数（details->>"$.recommended" が true の数）
   - 品質の平均点（details->>"$.quality" の平均）

2. 結果は以下の条件で出力してください：
   - レビューがない商品も含める
   - 平均評価は小数点第1位で四捨五入
   - おすすめ数が多い順にソート
   - おすすめ数が同じ場合は平均評価の高い順

期待される出力形式：
```
商品名 | カテゴリー | 親カテゴリー | レビュー数 | 平均評価 | おすすめ数 | 品質平均
```

ヒント：
- LEFT JOINを使用してレビューがない商品も表示
- JSON操作には ->> 演算子を使用
- カテゴリーの階層はJOINで結合
- NULL値の処理に注意

--私の解答（簡単すぎん？）
select
    p.name,
    c.name as category,
    coalesce(pc.name,'親カテゴリー無し') as parent_category,
    count(r.review_id) as reviews,
    round(avg(r.rating),2) as avg_rating,
    count(case when r.details->>'$.recommended'='true' then 1 end) as recommends,
    round(avg(r.details->>'$.quality'),2) as avg_quality
from
    products p
    inner join categories c on c.category_id = p.category_id
    left join categories pc on pc.category_id = c.parent_category_id
    left join reviews r on r.product_id = p.product_id
group by
    p.name,
    c.name,
    coalesce(pc.name,'親カテゴリー無し');

--実行結果

|name       |category|parent_category|reviews|avg_rating|recommends|avg_quality|
|-----------|--------|---------------|-------|----------|----------|-----------|
|スマートフォンX   |スマートフォン |家電             |2      |4.5       |2         |4.5        |
|タブレットPro   |タブレット   |家電             |1      |3         |0         |3          |
|ノートPCスタンダード|パソコン    |家電             |1      |5         |1         |5          |
|メンズジャケット   |メンズ     |衣類             |1      |4         |1         |4          |
|レディースコート   |レディース   |衣類             |0      |          |0         |           |

