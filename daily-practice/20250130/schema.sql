ECサイトのデータ分析に関する問題を出題させていただきます。

以下のテーブル構造を前提とした分析クエリを作成してください：


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    stock INT,
    created_at TIMESTAMP
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50),
    parent_category_id INT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP,
    status VARCHAR(20)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP
);


問題：
2024年第4四半期（10-12月）における以下の分析を行ってください：

1. 親カテゴリ別の売上合計を算出し、売上の大きい順に表示
2. 各親カテゴリにおいて売上TOP3の商品名とその売上金額を表示
3. カテゴリごとの平均購入単価（order_itemsの単価の平均）を計算

要件：
- cancelled状態の注文は除外すること
- 金額は小数点2位で四捨五入
- カテゴリ名、商品名も結果に含めること
- 売上0の親カテゴリも表示すること

期待する出力イメージ：
```
parent_category_name, total_sales, top_selling_products, avg_unit_price
Electronics, 150000.00, "iPhone 13,MacBook Pro,iPad", 2500.50
Books, 75000.00, "Programming Guide,SQL Book,Python Basic", 45.80
...
```

クエリを作成してみてください。
