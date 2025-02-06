以下のようなECサイトのデータ分析の問題を出させていただきます：

## テーブル構造
```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    stock INT,
    created_at TIMESTAMP
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(50),
    parent_category_id INT
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
    PRIMARY KEY (order_id, product_id)
);
```

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

実際のビジネスシーンを想定したクエリを作成してください。
