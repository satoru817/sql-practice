-- 商品カテゴリマスタ
CREATE TABLE product_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- 商品マスタ
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    specs JSON,  -- 商品仕様（色、サイズなど）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
);

-- キャンペーンマスタ
CREATE TABLE campaigns (
    campaign_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    discount_rate DECIMAL(4,2) NOT NULL  -- 割引率（例：10.00は10%割引）
);

-- 商品・キャンペーン紐付けテーブル
CREATE TABLE product_campaigns (
    product_id INT,
    campaign_id INT,
    PRIMARY KEY (product_id, campaign_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- 注文テーブル
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date TIMESTAMP NOT NULL,
    customer_id INT NOT NULL,
    payment_method JSON  -- 支払方法の詳細情報
);

-- 注文明細テーブル
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,  -- 実際の販売価格（キャンペーン適用後）
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- カテゴリのテストデータ
INSERT INTO product_categories (category_id, name) VALUES
(1, 'スマートフォン'),
(2, 'タブレット'),
(3, 'ノートPC'),
(4, 'イヤホン'),
(5, 'スマートウォッチ');

-- 商品のテストデータ
INSERT INTO products (product_id, name, category_id, base_price, specs) VALUES
(1, 'Phone Pro Max', 1, 150000, '{"color": "black", "storage": "256GB"}'),
(2, 'Phone Pro Max', 1, 150000, '{"color": "white", "storage": "256GB"}'),
(3, 'TabletX', 2, 80000, '{"color": "silver", "storage": "128GB"}'),
(4, 'UltraBook Pro', 3, 120000, '{"color": "gray", "ram": "16GB"}'),
(5, 'EarBuds Air', 4, 29800, '{"color": "white", "type": "wireless"}'),
(6, 'SmartWatch 5', 5, 42800, '{"color": "black", "size": "44mm"}'),
(7, 'Phone Lite', 1, 75000, '{"color": "blue", "storage": "128GB"}'),
(8, 'TabletX Pro', 2, 100000, '{"color": "space-gray", "storage": "256GB"}');

-- キャンペーンのテストデータ
INSERT INTO campaigns (campaign_id, name, start_date, end_date, discount_rate) VALUES
(1, '新春セール', '2024-01-01', '2024-01-15', 10.00),
(2, '週末限定セール', '2024-01-20', '2024-01-22', 15.00),
(3, 'スマートフォンフェア', '2024-01-10', '2024-01-25', 12.00);

-- 商品・キャンペーン紐付けのテストデータ
INSERT INTO product_campaigns (product_id, campaign_id) VALUES
(1, 1), (1, 3),
(2, 1), (2, 3),
(3, 1),
(7, 3),
(8, 1);

-- 注文のテストデータ
INSERT INTO orders (order_id, order_date, customer_id, payment_method) VALUES
(1, '2024-01-05 10:00:00', 1, '{"method": "credit_card", "installments": 1}'),
(2, '2024-01-05 11:30:00', 2, '{"method": "bank_transfer", "bank": "ABC"}'),
(3, '2024-01-12 14:20:00', 3, '{"method": "credit_card", "installments": 1}'),
(4, '2024-01-21 09:15:00', 4, '{"method": "convenience_store", "store": "Seven"}'),
(5, '2024-01-21 16:45:00', 5, '{"method": "credit_card", "installments": 12}'),
(6, '2024-01-22 13:20:00', 6, '{"method": "credit_card", "installments": 1}'),
(7, '2024-01-23 10:30:00', 7, '{"method": "bank_transfer", "bank": "XYZ"}'),
(8, '2024-01-24 15:10:00', 8, '{"method": "convenience_store", "store": "Family"}'),
(9, '2024-01-25 11:20:00', 9, '{"method": "credit_card", "installments": 1}'),
(10, '2024-01-25 14:40:00', 10, '{"method": "credit_card", "installments": 6}');

-- 注文明細のテストデータ
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 135000),  -- 新春セール10%オフ
(2, 3, 2, 72000),   -- 新春セール10%オフ
(3, 2, 1, 132000),  -- スマートフォンフェア12%オフ
(4, 7, 1, 63750),   -- 週末限定セール15%オフ
(4, 5, 2, 29800),   -- 通常価格
(5, 8, 1, 85000),   -- 週末限定セール15%オフ
(6, 4, 1, 120000),  -- 通常価格
(7, 6, 2, 42800),   -- 通常価格
(8, 1, 1, 127500),  -- スマートフォンフェア12%オフ
(9, 3, 1, 80000),   -- 通常価格
(10, 2, 1, 132000); -- スマートフォンフェア12%オフ
