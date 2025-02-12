ECサイトの商品レビュー分析に関する問題を作成します。

```sql
-- schema.sql
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id INT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    details JSON,  -- 詳細評価（品質、価格、デザインなど）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    joined_date DATE NOT NULL
);

-- インデックスの作成
CREATE INDEX idx_product_category ON products(category_id);
CREATE INDEX idx_review_product ON reviews(product_id);
CREATE INDEX idx_review_user ON reviews(user_id);
```

```sql
-- data.sql
-- カテゴリーデータ
INSERT INTO categories (category_id, name, parent_category_id) VALUES
(1, '家電', NULL),
(2, 'スマートフォン', 1),
(3, 'タブレット', 1),
(4, 'パソコン', 1),
(5, '衣類', NULL),
(6, 'メンズ', 5),
(7, 'レディース', 5);

-- 商品データ
INSERT INTO products (product_id, name, price, category_id, description) VALUES
(1, 'スマートフォンX', 89800, 2, '最新モデル'),
(2, 'タブレットPro', 59800, 3, '大画面モデル'),
(3, 'ノートPCスタンダード', 98000, 4, '標準モデル'),
(4, 'メンズジャケット', 12800, 6, '秋冬モデル'),
(5, 'レディースコート', 15800, 7, '防寒性抜群');

-- ユーザーデータ
INSERT INTO users (user_id, username, joined_date) VALUES
(1, 'user1', '2024-01-01'),
(2, 'user2', '2024-01-15'),
(3, 'user3', '2024-01-20');

-- レビューデータ
INSERT INTO reviews (product_id, user_id, rating, review_text, details) VALUES
(1, 1, 4, '良い商品です', '{"quality": 4, "price": 3, "design": 5, "recommended": true}'),
(1, 2, 5, '最高です', '{"quality": 5, "price": 4, "design": 5, "recommended": true}'),
(2, 1, 3, '普通', '{"quality": 3, "price": 3, "design": 3, "recommended": false}'),
(3, 3, 5, '期待以上', '{"quality": 5, "price": 4, "design": 4, "recommended": true}'),
(4, 2, 4, 'サイズぴったり', '{"quality": 4, "price": 5, "design": 4, "recommended": true}');
```

問題：以下の要件を満たすSQLクエリを作成してください。

1. 全ての商品について、以下の情報を取得してください：
   - 商品名
   - カテゴリー名（親カテゴリー名も含む）
   - レビュー数
   - 平均評価（rating）
   - おすすめされた数（details->>"$.recommended" が true の数）
   - 品質の平均点（details->>"$.quality" の平均）

2. 結果は以下の条件で出力してください：
   - レビューがない商品も含める
   - 平均評価は小数点第1位で四捨五入
   - おすすめ数が多い順にソート
   - おすすめ数が同じ場合は平均評価の高い順

期待される出力形式：
```
商品名 | カテゴリー | 親カテゴリー | レビュー数 | 平均評価 | おすすめ数 | 品質平均
```

ヒント：
- LEFT JOINを使用してレビューがない商品も表示
- JSON操作には ->> 演算子を使用
- カテゴリーの階層はJOINで結合
- NULL値の処理に注意
