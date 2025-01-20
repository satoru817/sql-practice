INSERT INTO categories (category_id, category_name, parent_category_id) VALUES
(1, 'エレクトロニクス', NULL),
(2, 'スマートフォン', 1),
(3, 'ノートPC', 1),
(4, '衣類', NULL),
(5, 'メンズ', 4),
(6, 'レディース', 4);

INSERT INTO products (product_name, category_id, price, stock_quantity) VALUES
('iPhone 14', 2, 89800, 50),
('Galaxy S23', 2, 94800, 30),
('MacBook Air', 3, 134800, 20),
('ThinkPad X1', 3, 184800, 15),
('メンズジャケット', 5, 12800, 100),
('レディースコート', 6, 15800, 80);

INSERT INTO customers (email, first_name, last_name, registration_date) VALUES
('yamada@example.com', '太郎', '山田', '2023-01-01'),
('tanaka@example.com', '花子', '田中', '2023-02-15'),
('suzuki@example.com', '一郎', '鈴木', '2023-03-20');

INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES
(1, '2024-01-01 10:00:00', 'completed', 89800),
(2, '2024-01-02 15:30:00', 'completed', 134800),
(1, '2024-01-05 12:00:00', 'completed', 12800),
(3, '2024-01-10 09:15:00', 'processing', 94800);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 89800),
(2, 3, 1, 134800),
(3, 5, 1, 12800),
(4, 2, 1, 94800);
