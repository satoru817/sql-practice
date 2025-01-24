-- サンプルデータ
INSERT INTO publishers (publisher_id, publisher_name) VALUES
(1, 'TechBooks Inc.'),
(2, 'Literature Press'),
(3, 'Science Publishing');

INSERT INTO books (book_id, title, publisher_id, price, stock_quantity, publication_date) VALUES
(1, 'SQL基礎', 1, 2800, 100, '2024-01-01'),
(2, '小説: 春の風', 2, 1500, 150, '2024-01-15'),
(3, '物理の謎', 3, 3200, 80, '2024-01-20'),
(4, 'プログラミング入門', 1, 2500, 120, '2024-02-01'),
(5, '歴史物語', 2, 1800, 90, '2024-02-10');

INSERT INTO customers (customer_id, customer_name, email, membership_rank) VALUES
(1, '山田太郎', 'yamada@example.com', 'GOLD'),
(2, '鈴木花子', 'suzuki@example.com', 'SILVER'),
(3, '田中一郎', 'tanaka@example.com', 'BRONZE');

INSERT INTO orders (order_id, customer_id, order_date, total_amount, order_status) VALUES
(1, 1, '2024-02-01 10:00:00', 5600, 'COMPLETED'),
(2, 2, '2024-02-02 15:30:00', 3000, 'COMPLETED'),
(3, 3, '2024-02-03 12:45:00', 3200, 'COMPLETED'),
(4, 1, '2024-02-04 09:15:00', 4500, 'COMPLETED');

INSERT INTO order_details (order_id, book_id, quantity, unit_price) VALUES
(1, 1, 2, 2800),
(2, 2, 2, 1500),
(3, 3, 1, 3200),
(4, 4, 1, 2500),
(4, 5, 1, 2000);

