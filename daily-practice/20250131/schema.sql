ECサイトの商品分析に関する問題を出題させていただきます。

以下のテーブル構造で、商品の販売実績と在庫管理を分析する問題です：


-- 商品カテゴリ
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- 商品マスタ
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    discontinued_at TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 注文
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL
);

-- 注文明細
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


## 問題
2023年第4四半期（10-12月）における以下のレポートを作成してください：

1. 親カテゴリごとの以下の情報を抽出：
   - 総売上額
   - カテゴリ内の平均購入単価（注文明細の単価の平均）
   - カテゴリ内で最も売れている商品TOP3（売上金額ベース）をカンマ区切りで1列に表示

2. レポートの要件：
   - 親カテゴリが設定されていないカテゴリは、そのカテゴリ自体を親として扱う
   - 売上がなかったカテゴリは表示しない
   - 金額は小数点以下2桁で表示
   - 商品名の結合はGROUP_CONCATを使用

クエリを作成してください。
