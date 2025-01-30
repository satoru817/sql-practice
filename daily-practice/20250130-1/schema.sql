ECサイトの顧客分析に関する問題を出題させていただきます：


CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP,
    status VARCHAR(20)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP,
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    status VARCHAR(20)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2)
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(50),
    parent_category_id INT
);


問題：
2024年の顧客分析として、以下の指標を計算してください：

1. 各顧客の最新購入日からの経過日数
2. 顧客ごとの購入回数と合計購入金額
3. 最も頻繁に購入しているカテゴリ（親カテゴリレベル）
4. 平均購入間隔（日数）

要件：
- cancelled状態の注文は除外
- inactive状態の顧客は除外
- 金額は小数点2位で四捨五入
- 期間は2024年1月1日から2024年12月31日まで
- 結果は最新購入日からの経過日数が短い順に表示

期待される出力イメージ：

customer_name, days_since_last_order, order_count, total_spent, favorite_category, avg_order_interval
John Doe, 5, 12, 25000.50, Electronics, 30.5
Jane Smith, 8, 8, 15000.75, Books, 45.2
...


クエリを作成してください。
