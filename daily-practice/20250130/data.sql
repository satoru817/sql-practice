-- カテゴリのテストデータ
INSERT INTO categories VALUES
(1, 'Electronics', NULL),  -- 親カテゴリ
(2, 'Books', NULL),        -- 親カテゴリ
(3, 'Clothing', NULL),     -- 親カテゴリ
(11, 'Smartphones', 1),    -- Electronics の子カテゴリ
(12, 'Laptops', 1),       -- Electronics の子カテゴリ
(13, 'Tablets', 1),       -- Electronics の子カテゴリ
(21, 'Programming', 2),    -- Books の子カテゴリ
(22, 'Fiction', 2),       -- Books の子カテゴリ
(31, 'T-Shirts', 3),      -- Clothing の子カテゴリ
(32, 'Pants', 3);         -- Clothing の子カテゴリ

-- 商品のテストデータ
INSERT INTO products VALUES
(1, 'iPhone 13', 11, 999.99, 100, '2024-01-01'),
(2, 'MacBook Pro', 12, 1299.99, 50, '2024-01-01'),
(3, 'iPad', 13, 799.99, 75, '2024-01-01'),
(4, 'Programming Guide', 21, 49.99, 200, '2024-01-01'),
(5, 'SQL Book', 21, 39.99, 150, '2024-01-01'),
(6, 'Python Basic', 21, 45.99, 180, '2024-01-01'),
(7, 'Mystery Novel', 22, 19.99, 300, '2024-01-01'),
(8, 'Basic T-Shirt', 31, 29.99, 500, '2024-01-01'),
(9, 'Jeans', 32, 79.99, 200, '2024-01-01');

-- 顧客のテストデータ
INSERT INTO customers VALUES
(1, 'John Doe', 'john@example.com', '2024-01-01'),
(2, 'Jane Smith', 'jane@example.com', '2024-01-01'),
(3, 'Bob Johnson', 'bob@example.com', '2024-01-01');

-- 注文のテストデータ
INSERT INTO orders VALUES
(1, 1, '2024-10-15 10:00:00', 'completed'),
(2, 2, '2024-11-20 14:30:00', 'completed'),
(3, 3, '2024-12-05 16:45:00', 'completed'),
(4, 1, '2024-12-10 09:15:00', 'cancelled'),
(5, 2, '2024-12-15 11:30:00', 'completed');

-- 注文明細のテストデータ
INSERT INTO order_items VALUES
(1, 1, 2, 999.99),    -- iPhone 13 x2
(1, 4, 1, 49.99),     -- Programming Guide x1
(2, 2, 1, 1299.99),   -- MacBook Pro x1
(2, 3, 1, 799.99),    -- iPad x1
(3, 5, 3, 39.99),     -- SQL Book x3
(3, 8, 2, 29.99),     -- Basic T-Shirt x2
(4, 1, 1, 999.99),    -- キャンセルされた注文
(5, 6, 2, 45.99),     -- Python Basic x2
(5, 9, 1, 79.99);     -- Jeans x1
