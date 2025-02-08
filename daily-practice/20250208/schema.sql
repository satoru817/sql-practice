-- スキーマ定義
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    parent_id INT,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    attributes JSON NOT NULL, -- 素材、カラット、サイズなどの属性
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    membership_level ENUM('REGULAR', 'SILVER', 'GOLD', 'PLATINUM') NOT NULL,
    preferences JSON -- 好みの素材、スタイルなど
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    payment_status ENUM('PENDING', 'COMPLETED', 'CANCELLED') NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    customization JSON, -- カスタマイズ情報（刻印、サイズ調整など）
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- サンプルデータ
INSERT INTO categories (category_id, name, parent_id) VALUES
(1, 'リング', NULL),
(2, 'ネックレス', NULL),
(3, 'ピアス', NULL),
(4, 'ダイヤモンドリング', 1),
(5, 'パールネックレス', 2),
(6, 'ゴールドピアス', 3);

INSERT INTO products (product_id, name, category_id, base_price, attributes) VALUES
(1, 'クラシックダイヤモンドリング', 4, 150000, '{"material": "platinum", "carat": 0.5, "clarity": "VS1", "sizes_available": [7,8,9,10]}'),
(2, 'パールネックレス', 5, 80000, '{"material": "white_gold", "pearl_type": "akoya", "pearl_size": 7.5, "length": 45}'),
(3, '華やかゴールドピアス', 6, 45000, '{"material": "gold", "karat": 18, "style": "drop", "length": 3.5}');

INSERT INTO customers (customer_id, name, membership_level, preferences) VALUES
(1, '山田花子', 'GOLD', '{"preferred_materials": ["platinum", "white_gold"], "style": "classic"}'),
(2, '鈴木一郎', 'SILVER', '{"preferred_materials": ["gold"], "style": "modern"}'),
(3, '佐藤美咲', 'PLATINUM', '{"preferred_materials": ["platinum"], "style": "vintage"}');

INSERT INTO orders (order_id, customer_id, order_date, total_amount, payment_status) VALUES
(1, 1, '2024-01-15 10:00:00', 150000, 'COMPLETED'),
(2, 2, '2024-01-16 15:30:00', 45000, 'COMPLETED'),
(3, 3, '2024-01-17 12:45:00', 230000, 'COMPLETED');

INSERT INTO order_items (order_id, product_id, quantity, unit_price, customization) VALUES
(1, 1, 1, 150000, '{"size": 8, "engraving": "Love Forever"}'),
(2, 3, 1, 45000, '{"gift_wrap": true}'),
(3, 1, 1, 150000, '{"size": 9, "engraving": "Together"}'),
(3, 2, 1, 80000, '{"length_adjustment": -2}');


-- カテゴリーのデータ追加
INSERT INTO categories (category_id, name, parent_id) VALUES
(7, 'ブレスレット', NULL),
(8, 'シルバーリング', 1);

-- 商品の追加
INSERT INTO products (product_id, name, category_id, base_price, attributes) VALUES
(4, 'シンプルシルバーリング', 8, 25000, '{"material": "silver", "sizes_available": [7,8,9,10,11], "style": "simple"}'),
(5, 'ダイヤモンドテニスブレスレット', 7, 200000, '{"material": "white_gold", "carat_total": 1.5, "length": 18}'),
(6, 'クラシックパールネックレス', 5, 65000, '{"material": "silver", "pearl_type": "freshwater", "pearl_size": 6.5, "length": 42}'),
(7, 'プラチナダイヤリング', 4, 180000, '{"material": "platinum", "carat": 0.7, "clarity": "VVS1", "sizes_available": [7,8,9]}'),
(8, 'スタッドピアス', 6, 35000, '{"material": "gold", "karat": 18, "style": "stud"}');

-- 顧客の追加
INSERT INTO customers (customer_id, name, membership_level, preferences) VALUES
(4, '田中誠', 'REGULAR', '{"preferred_materials": ["silver"], "style": "simple"}'),
(5, '高橋恵子', 'GOLD', '{"preferred_materials": ["gold", "platinum"], "style": "elegant"}');

-- 注文の追加（カスタマイズなしも含む）
INSERT INTO orders (order_id, customer_id, order_date, total_amount, payment_status) VALUES
(4, 4, '2024-01-18 14:20:00', 25000, 'COMPLETED'),
(5, 5, '2024-01-19 11:15:00', 215000, 'COMPLETED'),
(6, 1, '2024-01-20 16:30:00', 65000, 'COMPLETED'),
(7, 2, '2024-01-21 13:45:00', 180000, 'COMPLETED'),
(8, 3, '2024-01-22 10:30:00', 35000, 'COMPLETED');

-- 注文明細の追加（カスタマイズなしのものも含む）
INSERT INTO order_items (order_id, product_id, quantity, unit_price, customization) VALUES
(4, 4, 1, 25000, NULL),  -- カスタマイズなし
(5, 5, 1, 200000, '{"length_adjustment": -1, "clasp_type": "double"}'),
(5, 8, 1, 15000, NULL),  -- カスタマイズなし
(6, 6, 1, 65000, NULL),  -- カスタマイズなし
(7, 7, 1, 180000, '{"size": 8, "engraving": "Forever Love"}'),
(8, 8, 1, 35000, '{"backing_type": "screw"}');
