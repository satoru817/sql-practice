-- schema.sql
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

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    delivery_status JSON NOT NULL,  -- 配送状況の履歴
    order_details JSON NOT NULL,    -- 注文の詳細情報
    total_amount DECIMAL(10,2) NOT NULL
);

CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE shipping_addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    prefecture VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    is_default BOOLEAN DEFAULT false
);

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

-- data.sql
INSERT INTO shipping_addresses (address_id, user_id, prefecture, city, is_default) VALUES
(1, 1, '東京都', '渋谷区', true),
(2, 1, '神奈川県', '横浜市', false),
(3, 2, '大阪府', '大阪市', true),
(4, 3, '福岡県', '福岡市', true);

INSERT INTO orders (order_id, user_id, order_date, delivery_status, order_details, total_amount) VALUES
(1, 1, '2024-02-01 10:00:00', 
   '{"status": "delivered", "history": [
        {"status": "ordered", "timestamp": "2024-02-01 10:00:00"},
        {"status": "shipped", "timestamp": "2024-02-02 15:00:00"},
        {"status": "delivered", "timestamp": "2024-02-03 14:00:00"}
    ]}',
   '{"payment_method": "credit_card", "shipping_type": "normal", "gift": false}',
   25800),
(2, 2, '2024-02-05 11:30:00',
   '{"status": "shipped", "history": [
        {"status": "ordered", "timestamp": "2024-02-05 11:30:00"},
        {"status": "shipped", "timestamp": "2024-02-06 13:00:00"}
    ]}',
   '{"payment_method": "convenience_store", "shipping_type": "express", "gift": true}',
   89800),
(3, 1, '2024-02-10 15:45:00',
   '{"status": "ordered", "history": [
        {"status": "ordered", "timestamp": "2024-02-10 15:45:00"}
    ]}',
   '{"payment_method": "credit_card", "shipping_type": "normal", "gift": false}',
   12800);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 4, 2, 12900),
(2, 1, 1, 89800),
(3, 4, 1, 12800);
