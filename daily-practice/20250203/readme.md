ECサイトのデータ分析に関する問題を出題します。

# テーブル定義
```sql
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(200),
    category_id INT,
    price DECIMAL(10,2),
    cost DECIMAL(10,2),
    stock INT,
    discontinued_at TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP,
    total_amount DECIMAL(12,2),
    status VARCHAR(20)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

# 問題
2024年の第4四半期（10-12月）における以下の分析を行うクエリを作成してください：

1. 親カテゴリー別の総売上と利益を計算
2. 各親カテゴリー内で売上額トップ3の商品名を取得
3. 親カテゴリー別の平均注文単価を計算（注文単価＝1回の注文での購入金額）

以下の点に注意してクエリを作成してください：
- 商品が廃番（discontinued_at NOT NULL）の場合も含める
- 注文ステータスが 'cancelled' の場合は除外
- 結果は売上額の降順でソート
- 金額は小数点第2位で四捨五入
- NULL値の適切な処理

実際のビジネスシーンを想定した実用的なクエリを作成してください。
