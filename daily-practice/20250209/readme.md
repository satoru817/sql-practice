ECサイトのレビューシステムに関する分析の問題を作成します。

## テーブル定義
```sql
-- 商品テーブル
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2)
);

-- レビューテーブル
CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT,
    review_date TIMESTAMP,
    content TEXT,
    meta_data JSON,  -- レビュー関連のメタデータ（デバイス情報、購入確認情報など）
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

## サンプルデータ例
```sql
-- reviews.meta_dataの例
{
    "device": {
        "type": "mobile",
        "os": "iOS",
        "version": "15.0"
    },
    "verified_purchase": true,
    "photos": ["photo1.jpg", "photo2.jpg"],
    "helpful_votes": 5,
    "tags": ["size_fits", "good_quality", "fast_delivery"]
}
```

## 問題
以下の分析を行うSQLクエリを作成してください：

1. 製品ごとに、以下の情報を集計してください：
   - 平均評価（rating）
   - 投稿されたレビューの総数
   - 写真付きレビューの数
   - verified_purchaseが true のレビュー数
   - モバイルからの投稿数
   結果は平均評価が高い順に表示し、レビュー数が10件以上の製品のみを対象としてください。

2. タグ（tags配列）の使用頻度を分析し、最も多く使用されているタグトップ5を抽出してください。
   - タグごとの使用回数
   - そのタグが使用されているレビューの平均評価
   を表示してください。

ヒント：
- JSON_EXTRACT() を使用して JSON データから値を取得できます
- JSON_CONTAINS() で配列内の値の存在確認ができます
- JSON_LENGTH() で配列の長さを取得できます
