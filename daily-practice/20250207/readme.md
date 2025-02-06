このSQLの問題では、ECサイトでJSONデータを含む複雑な分析が必要なシナリオを作成しましょう。

まず、以下のテーブル構造から始めましょう：

```sql
-- 商品カテゴリマスタ
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    attributes JSON,  -- カテゴリ固有の属性（例：本の場合は出版社情報、電化製品の場合は製造元情報）
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- 商品マスタ
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    specs JSON,  -- 商品仕様（サイズ、重量、色など）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 注文ヘッダ
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    delivery_info JSON,  -- 配送情報（住所、希望配送時間など）
    payment_info JSON,   -- 支払情報（支払方法、使用ポイントなど）
    total_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL
);

-- 注文明細
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    customization JSON,  -- カスタマイズ情報（ギフトラッピング、メッセージカードなど）
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- カスタマーレビュー
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    review_date TIMESTAMP NOT NULL,
    review_text TEXT,
    review_details JSON,  -- 詳細評価（評価項目ごとの点数など）
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

問題：
以下の分析を行うSQLクエリを作成してください。

1. 各カテゴリ（親カテゴリを含む）における以下の情報を抽出してください：
   - カテゴリ名
   - 総売上額
   - 平均利益率
   - 最も人気のある商品仕様（specs内の情報で最も売れている組み合わせ）
   - レビューの平均評価（review_details内の各評価項目の平均）
   - 配送方法ごとの注文数（delivery_info内の配送方法の分布）

このクエリでは以下のような技術的チャレンジがあります：
- JSONデータの解析と集計
- 階層的なカテゴリ構造の処理
- 複数テーブルの結合と集計
- Window関数の活用
- 複雑な条件での集計

回答する際は、以下のポイントを意識してください：
- パフォーマンスを考慮したクエリ設計
- JSONデータの適切な処理
- NULL値の適切な処理
- 集計結果の可読性
