SQLの問題を作成いたします。JSON_TABLE関数を使った複雑なデータ分析のシナリオを考えました。

# MySQLのJSON_TABLE問題：ECサイトの製品レビュー分析

## 問題設定

あなたはECサイトのデータアナリストとして、ユーザーレビューの詳細分析を任されました。レビューデータはJSON形式で保存されており、製品ごとのレビュースコア、ユーザーの購入履歴、詳細評価などの情報が含まれています。

## テーブル構造

```sql
CREATE TABLE products (
  product_id INT PRIMARY KEY,
  name VARCHAR(100),
  category VARCHAR(50),
  price DECIMAL(10,2)
);

CREATE TABLE reviews (
  review_id INT PRIMARY KEY,
  product_id INT,
  user_id INT,
  review_date DATE,
  review_data JSON,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

## review_dataのJSON構造例

```json
{
  "overall_rating": 4.5,
  "verified_purchase": true,
  "purchase_date": "2024-12-10",
  "detailed_ratings": [
    {"aspect": "quality", "score": 5},
    {"aspect": "value", "score": 4},
    {"aspect": "usability", "score": 5}
  ],
  "usage_context": ["home", "work"],
  "metadata": {
    "platform": "mobile",
    "country": "Japan",
    "language": "ja"
  }
}
```

## 問題

以下のレポートを作成するSQLクエリを書いてください：

1. 製品ごとに以下の情報を含むレポートを作成してください：
   - 製品名
   - カテゴリ
   - 全体評価の平均スコア
   - 検証済み購入のレビュー数（verified_purchase = true）
   - 各使用コンテキスト（usage_context）の数（例：「家庭での使用」の数）
   - 最も高いスコアを持つ詳細評価の側面（aspect）

2. モバイルとデスクトッププラットフォーム間のレビュースコアを比較してください。

3. 製品の購入後、レビューが投稿されるまでの平均日数を計算してください（review_dateとJSON内のpurchase_dateを使用）。

このクエリでは、JSON_TABLE関数を使用してJSONデータを行と列に変換し、それらのデータに対して分析を行ってください。

問題2のための要件をより詳しく説明いたします：

# 問題2: モバイルとデスクトッププラットフォーム間のレビュースコア比較

この問題では、review_dataのJSON内に含まれる`metadata.platform`の値に基づいて、モバイル端末からのレビューとデスクトップからのレビューを比較分析する必要があります。

## 具体的な要件：

1. **モバイルプラットフォーム**（`metadata.platform = "mobile"`）と**デスクトッププラットフォーム**（`metadata.platform = "desktop"`）からのレビューを区別して集計

2. 各プラットフォームごとに以下の情報を集計・比較する：
   - 製品ごとの平均総合評価スコア（overall_rating）
   - レビュー数
   - 検証済み購入（verified_purchase = true）のレビュー割合

3. 可能であれば、両プラットフォーム間の評価差を計算する

## 期待される出力イメージ：

```
| 製品名 | モバイル評価平均 | デスクトップ評価平均 | 評価差 | モバイルレビュー数 | デスクトップレビュー数 | モバイル検証済み割合 | デスクトップ検証済み割合 |
|--------|----------------|---------------------|-------|-------------------|----------------------|---------------------|------------------------|
| 製品A  | 4.2            | 4.5                 | -0.3  | 5                 | 3                    | 80%                 | 67%                    |
| 製品B  | 3.8            | 4.0                 | -0.2  | 3                 | 2                    | 100%                | 50%                    |
| ...    | ...            | ...                 | ...   | ...               | ...                  | ...                 | ...                    |
```

このような分析は、異なるプラットフォームでのユーザー体験の違いを理解し、プラットフォーム別の最適化の必要性を判断するのに役立ちます。
