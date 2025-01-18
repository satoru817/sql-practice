-- Categories
INSERT INTO categories (category_id, parent_category_id, name, description) VALUES
(1, NULL, 'Electronics', 'Electronic devices and accessories'),
(2, 1, 'Smartphones', 'Mobile phones and accessories'),
(3, 1, 'Laptops', 'Notebooks and accessories'),
(4, NULL, 'Books', 'Books and magazines'),
(5, 4, 'Programming', 'Programming and technical books'),
(6, 4, 'Business', 'Business and management books');

-- Products
INSERT INTO products (product_id, category_id, name, description, price, cost, sku, stock_quantity) VALUES
(1, 2, 'iPhone 15', 'Latest iPhone model', 120000, 80000, 'IPH-15-BLK', 100),
(2, 2, 'Galaxy S24', 'Latest Samsung model', 100000, 70000, 'SAM-S24-BLK', 150),
(3, 3, 'MacBook Air', 'M2 MacBook Air', 150000, 100000, 'MAC-AIR-M2', 50),
(4, 3, 'ThinkPad X1', 'Lenovo ThinkPad X1', 180000, 120000, 'LEN-X1-BLK', 30),
(5, 5, 'SQL Basics', 'SQL for beginners', 2800, 1400, 'BOOK-SQL-001', 200),
(6, 5, 'Java Master', 'Advanced Java programming', 3200, 1600, 'BOOK-JAVA-001', 150);

-- Users
INSERT INTO users (user_id, email, password_hash, first_name, last_name, phone_number) VALUES
(1, 'yamada@example.com', 'hash1', 'Taro', 'Yamada', '090-1111-1111'),
(2, 'tanaka@example.com', 'hash2', 'Hanako', 'Tanaka', '090-2222-2222'),
(3, 'suzuki@example.com', 'hash3', 'Ichiro', 'Suzuki', '090-3333-3333');

-- User addresses
INSERT INTO user_addresses (user_id, address_type, postal_code, prefecture, city, street_address, is_default) VALUES
(1, 'shipping', '150-0001', 'Tokyo', 'Shibuya', '1-1-1', true),
(1, 'billing', '150-0001', 'Tokyo', 'Shibuya', '1-1-1', true),
(2, 'shipping', '160-0001', 'Tokyo', 'Shinjuku', '2-2-2', true),
(2, 'billing', '160-0001', 'Tokyo', 'Shinjuku', '2-2-2', true),
(3, 'shipping', '170-0001', 'Tokyo', 'Toshima', '3-3-3', true),
(3, 'billing', '170-0001', 'Tokyo', 'Toshima', '3-3-3', true);

-- Orders from past 3 months
INSERT INTO orders (order_id, user_id, order_status, total_amount, shipping_fee, tax_amount, shipping_address_id, billing_address_id, created_at) VALUES
(1, 1, 'delivered', 123000, 0, 11182, 1, 2, '2024-11-15 10:00:00'),
(2, 2, 'delivered', 153000, 0, 13909, 3, 4, '2024-12-01 11:30:00'),
(3, 3, 'delivered', 183000, 0, 16636, 5, 6, '2024-12-15 14:20:00'),
(4, 1, 'delivered', 6000, 500, 591, 1, 2, '2024-12-20 16:45:00'),
(5, 2, 'shipped', 150000, 0, 13636, 3, 4, '2025-01-05 09:15:00'),
(6, 3, 'confirmed', 100000, 0, 9091, 5, 6, '2025-01-15 13:40:00');

-- Order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 120000), -- iPhone 15
(1, 5, 1, 3000),   -- SQL Book
(2, 3, 1, 150000), -- MacBook Air
(2, 5, 1, 3000),   -- SQL Book
(3, 4, 1, 180000), -- ThinkPad X1
(3, 6, 1, 3000),   -- Java Book
(4, 5, 1, 3000),   -- SQL Book
(4, 6, 1, 3000),   -- Java Book
(5, 3, 1, 150000), -- MacBook Air
(6, 2, 1, 100000); -- Galaxy S24

-- Product reviews
INSERT INTO reviews (product_id, user_id, rating, title, comment) VALUES
(1, 1, 5, 'Great phone!', 'Very satisfied with the purchase'),
(2, 2, 4, 'Good but expensive', 'Good quality but a bit pricey'),
(3, 2, 5, 'Perfect laptop', 'Exactly what I needed for work'),
(5, 1, 5, 'Great SQL book', 'Very helpful for beginners'),
(5, 2, 4, 'Good reference', 'Using it daily at work'),
(6, 3, 4, 'Detailed Java guide', 'Good for advanced learning');
