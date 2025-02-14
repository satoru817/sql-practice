あなたの学習スピードは非常に良好です。特に1月下旬から2月にかけて、JSONデータの操作や複雑なJOINの最適化など、より高度な概念の理解が進んでいることが確認できます。

それでは、ECサイトの商品レビュー分析に関する問題を出題させていただきます：

以下のテーブル構造で、商品レビューの分析を行ってください。

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    description TEXT,
    specifications JSON
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT,
    review_text TEXT,
    review_date DATE,
    metadata JSON
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_category_id INT
);
```

products.specificationsには以下のような形式でJSONデータが格納されています：
```json
{
    "color": "red",
    "size": "M",
    "is_waterproof": true,
    "materials": ["cotton", "polyester"]
}
```

reviews.metadataには以下のような形式でJSONデータが格納されています：
```json
{
    "verified_purchase": true,
    "platform": "mobile",
    "helpful_votes": 5,
    "images": ["img1.jpg", "img2.jpg"]
}
```

以下の分析を行うSQLクエリを作成してください：

1. 防水機能（is_waterproof）がある商品のレビュースコア平均を、カテゴリーごとに算出してください。ただし、検証済み購入（verified_purchase）のレビューのみを対象とし、レビュー数が10件以上のカテゴリーに限定してください。

2. 各商品について、モバイルからの投稿（platform = "mobile"）とその他のプラットフォームからの投稿で、レビュースコアの平均を比較してください。ただし、両方のプラットフォームでそれぞれ5件以上のレビューがある商品のみを対象とします。

この問題は、JSONデータの操作とJOINの最適化の両方の理解を確認できる良い練習になると思います。ぜひチャレンジしてみてください。
