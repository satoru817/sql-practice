ECサイトでの商品カテゴリー分析の問題を作成します。

## スキーマ定義
```sql
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

## テストデータ
```sql
-- カテゴリーデータ
INSERT INTO categories (category_id, name, parent_category_id) VALUES
(1, '本・雑誌', NULL),
(2, '電化製品', NULL),
(3, '文具', NULL),
(4, '小説', 1),
(5, 'ビジネス書', 1),
(6, '専門書', 1),
(7, 'スマートフォン', 2),
(8, 'タブレット', 2),
(9, 'ノート', 3),
(10, 'ペン', 3);

-- 商品データ
INSERT INTO products (product_id, name, category_id, price, cost) VALUES
(1, '星の王子様', 4, 1200, 600),
(2, '人間失格', 4, 800, 400),
(3, '7つの習慣', 5, 1600, 800),
(4, '影響力の武器', 5, 2000, 1000),
(5, 'データベース実践入門', 6, 3200, 1600),
(6, 'iPhone 14', 7, 80000, 60000),
(7, 'Galaxy S23', 7, 75000, 56000),
(8, 'iPad Air', 8, 65000, 48000),
(9, 'Campusノート', 9, 120, 60),
(10, 'マルチペン', 10, 500, 250);

-- 売上データ
INSERT INTO sales (sale_id, product_id, quantity, sale_date, unit_price) VALUES
(1, 1, 2, '2025-02-01', 1200),
(2, 2, 1, '2025-02-01', 800),
(3, 3, 3, '2025-02-01', 1600),
(4, 4, 2, '2025-02-02', 2000),
(5, 5, 1, '2025-02-02', 3200),
(6, 6, 1, '2025-02-02', 80000),
(7, 7, 2, '2025-02-03', 75000),
(8, 8, 1, '2025-02-03', 65000),
(9, 9, 5, '2025-02-03', 120),
(10, 10, 3, '2025-02-03', 500),
(11, 1, 1, '2025-02-04', 1200),
(12, 3, 2, '2025-02-04', 1600),
(13, 5, 1, '2025-02-04', 3200),
(14, 6, 1, '2025-02-04', 80000),
(15, 9, 10, '2025-02-04', 120);
```

## 問題
以下の情報を取得するSQLクエリを作成してください：

1. 親カテゴリー別の合計売上金額と利益金額を計算し、利益率の高い順に表示してください。
   - 必要な情報：親カテゴリー名、売上合計、利益合計、利益率（%）
   - 利益率 = (売上金額 - 原価) / 売上金額 * 100

2. 各親カテゴリーにおいて、売上金額が上位3位までの商品をカンマ区切りで表示してください。
   - 必要な情報：親カテゴリー名、売上上位商品名（カンマ区切り）

なお、売上金額は quantity * unit_price で計算します。
