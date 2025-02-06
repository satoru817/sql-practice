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

-- カテゴリーのテストデータ
INSERT INTO categories VALUES
(1, '本・コミック', NULL),
(2, '家電', NULL),
(3, 'ファッション', NULL),
(11, '文学・小説', 1),
(12, 'ビジネス書', 1),
(13, 'コミック', 1),
(21, 'キッチン家電', 2),
(22, 'PCアクセサリー', 2),
(31, 'メンズウェア', 3),
(32, 'レディースウェア', 3);

-- 商品のテストデータ
INSERT INTO products VALUES
(1, '小説 A', 11, 1500.00, 100, '2024-01-01'),
(2, '小説 B', 11, 1200.00, 50, '2024-01-01'),
(3, '小説 C', 11, 1800.00, 0, '2024-01-01'),
(4, 'ビジネス本 A', 12, 2500.00, 30, '2024-01-01'),
(5, 'ビジネス本 B', 12, 3000.00, 20, '2024-01-01'),
(6, 'コミック A', 13, 500.00, 200, '2024-01-01'),
(7, 'コミック B', 13, 480.00, 150, '2024-01-01'),
(8, '電子ケトル', 21, 5000.00, 30, '2024-01-01'),
(9, 'コーヒーメーカー', 21, 8000.00, 25, '2024-01-01'),
(10, 'マウス', 22, 3000.00, 100, '2024-01-01'),
(11, 'キーボード', 22, 6000.00, 80, '2024-01-01'),
(12, 'Tシャツ M', 31, 2000.00, 50, '2024-01-01'),
(13, 'Tシャツ L', 31, 2000.00, 50, '2024-01-01'),
(14, 'スカート M', 32, 4000.00, 30, '2024-01-01'),
(15, 'スカート L', 32, 4000.00, 30, '2024-01-01');

-- 注文のテストデータ
INSERT INTO orders VALUES
(1, 101, '2024-10-01 10:00:00', 4500.00, 'completed'),
(2, 102, '2024-10-15 11:30:00', 8000.00, 'completed'),
(3, 103, '2024-10-20 15:45:00', 3500.00, 'cancelled'),
(4, 104, '2024-11-01 09:15:00', 15000.00, 'completed'),
(5, 105, '2024-11-10 14:20:00', 6000.00, 'completed'),
(6, 106, '2024-11-20 16:40:00', 4000.00, 'completed'),
(7, 107, '2024-12-01 10:30:00', 9500.00, 'completed'),
(8, 108, '2024-12-15 13:25:00', 12000.00, 'completed'),
(9, 109, '2024-12-25 11:10:00', 7500.00, 'completed');

-- 注文明細のテストデータ
INSERT INTO order_items VALUES
-- 10月の注文
(1, 1, 3, 1500.00),  -- 小説 A
(2, 4, 2, 2500.00),  -- ビジネス本 A
(2, 6, 6, 500.00),   -- コミック A
(3, 8, 1, 3500.00),  -- 電子ケトル（キャンセル）

-- 11月の注文
(4, 9, 1, 8000.00),  -- コーヒーメーカー
(4, 11, 1, 6000.00), -- キーボード
(5, 12, 3, 2000.00), -- Tシャツ M
(6, 14, 1, 4000.00), -- スカート M

-- 12月の注文
(7, 1, 2, 1500.00),  -- 小説 A
(7, 4, 1, 2500.00),  -- ビジネス本 A
(7, 6, 8, 500.00),   -- コミック A
(8, 8, 1, 5000.00),  -- 電子ケトル
(8, 9, 1, 8000.00),  -- コーヒーメーカー
(9, 12, 2, 2000.00), -- Tシャツ M
(9, 14, 1, 4000.00); -- スカート M
