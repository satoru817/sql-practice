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

INSERT INTO books (book_id, title, publisher_id, price, stock_quantity, publication_date) VALUES
(6, 'データベース設計', 1, 3500, 70, '2024-01-25'),
(7, '夏の詩集', 2, 1200, 200, '2024-01-28'),
(8, '化学実験の基礎', 3, 2800, 100, '2024-01-30'),
(9, 'Webプログラミング', 1, 3200, 150, '2024-02-05'),
(10, '古典文学選', 2, 2200, 80, '2024-02-08');

INSERT INTO customers (customer_id, customer_name, email, membership_rank) VALUES
(4, '佐藤次郎', 'sato@example.com', 'GOLD'),
(5, '高橋愛子', 'takahashi@example.com', 'BRONZE'),
(6, '渡辺健一', 'watanabe@example.com', 'SILVER');

INSERT INTO orders (order_id, customer_id, order_date, total_amount, order_status) VALUES
(5, 4, '2024-02-05 11:20:00', 6700, 'COMPLETED'),
(6, 5, '2024-02-06 14:45:00', 2800, 'COMPLETED'),
(7, 6, '2024-02-07 16:30:00', 4400, 'COMPLETED'),
(8, 4, '2024-02-08 09:45:00', 3200, 'COMPLETED'),
(9, 1, '2024-02-09 13:15:00', 5700, 'COMPLETED'),
(10, 2, '2024-02-10 10:30:00', 4000, 'COMPLETED');

INSERT INTO order_details (order_id, book_id, quantity, unit_price) VALUES
(5, 6, 1, 3500),
(5, 7, 2, 1600),
(6, 8, 1, 2800),
(7, 9, 1, 3200),
(7, 10, 1, 1200),
(8, 9, 1, 3200),
(9, 6, 1, 3500),
(9, 8, 1, 2200),
(10, 7, 2, 2000);

