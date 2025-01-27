-- サンプルデータの投入
INSERT INTO categories VALUES
(1, 'Electronics', NULL),
(2, 'Books', NULL),
(3, 'Smartphones', 1),
(4, 'Laptops', 1),
(5, 'Fiction', 2),
(6, 'Non-Fiction', 2);

INSERT INTO products VALUES
(1, 'Smartphone X', 3, 799.99, 600.00, 100, '2024-01-01', NULL),
(2, 'Laptop Pro', 4, 1299.99, 900.00, 50, '2024-01-01', NULL),
(3, 'Mystery Novel', 5, 19.99, 8.00, 200, '2024-01-01', NULL),
(4, 'Programming Guide', 6, 49.99, 20.00, 150, '2024-01-01', NULL),
(5, 'Tablet Y', 1, 599.99, 400.00, 75, '2024-01-01', NULL);

INSERT INTO customers VALUES
(1, 'John Smith', 'john@example.com', '2024-01-01', 'GOLD'),
(2, 'Jane Doe', 'jane@example.com', '2024-01-02', 'SILVER'),
(3, 'Bob Wilson', 'bob@example.com', '2024-01-03', 'PLATINUM'),
(4, 'Alice Brown', 'alice@example.com', '2024-01-04', 'BRONZE'),
(5, 'Charlie Davis', 'charlie@example.com', '2024-01-05', 'GOLD');

INSERT INTO orders VALUES
(1, 1, '2024-01-10', '123 Main St', 849.98, 'COMPLETED'),
(2, 2, '2024-01-11', '456 Oak Rd', 1299.99, 'COMPLETED'),
(3, 3, '2024-01-12', '789 Pine Ave', 869.97, 'COMPLETED'),
(4, 1, '2024-01-13', '123 Main St', 599.99, 'COMPLETED'),
(5, 4, '2024-01-14', '321 Elm St', 69.98, 'COMPLETED');

INSERT INTO order_items VALUES
(1, 1, 1, 799.99),
(1, 3, 2, 19.99),
(2, 2, 1, 1299.99),
(3, 1, 1, 799.99),
(3, 4, 1, 49.99),
(3, 3, 1, 19.99),
(4, 5, 1, 599.99),
(5, 3, 2, 19.99),
(5, 4, 1, 49.99);
