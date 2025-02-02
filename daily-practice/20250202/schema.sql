CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- カテゴリーデータ
INSERT INTO categories (category_id, name, parent_category_id) VALUES
(1, 'Electronics', NULL),
(2, 'Computers', 1),
(3, 'Smartphones', 1),
(4, 'Books', NULL),
(5, 'Fiction', 4),
(6, 'Non-Fiction', 4),
(7, 'Clothing', NULL),
(8, 'Men''s Wear', 7),
(9, 'Women''s Wear', 7);

-- 商品データ
INSERT INTO products (product_id, name, category_id, price, cost, stock_quantity, created_at) VALUES
-- Electronics
(1, 'Gaming Laptop', 2, 1200.00, 900.00, 50, '2023-12-01'),
(2, 'Business Laptop', 2, 800.00, 600.00, 100, '2023-12-01'),
(3, 'iPhone 15', 3, 999.00, 700.00, 200, '2023-12-01'),
(4, 'Android Phone', 3, 699.00, 500.00, 150, '2023-12-01'),

-- Books
(5, 'Best Seller Novel', 5, 29.99, 15.00, 1000, '2023-12-01'),
(6, 'Classic Literature', 5, 19.99, 10.00, 500, '2023-12-01'),
(7, 'Programming Guide', 6, 49.99, 25.00, 300, '2023-12-01'),
(8, 'Business Book', 6, 39.99, 20.00, 400, '2023-12-01'),

-- Clothing
(9, 'Men''s Jacket', 8, 89.99, 45.00, 200, '2023-12-01'),
(10, 'Men''s Jeans', 8, 59.99, 30.00, 300, '2023-12-01'),
(11, 'Women''s Dress', 9, 79.99, 40.00, 250, '2023-12-01'),
(12, 'Women''s Skirt', 9, 49.99, 25.00, 350, '2023-12-01');

-- 顧客データ
INSERT INTO customers (customer_id, name, email, registered_at) VALUES
(1, 'John Smith', 'john@example.com', '2023-12-01'),
(2, 'Mary Johnson', 'mary@example.com', '2023-12-01'),
(3, 'Robert Wilson', 'robert@example.com', '2023-12-01'),
(4, 'Lisa Brown', 'lisa@example.com', '2023-12-01'),
(5, 'Michael Davis', 'michael@example.com', '2023-12-01');

-- 注文データ
INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
-- John's orders (Heavy user)
(1, 1, '2024-01-05', 'completed'),
(2, 1, '2024-01-12', 'completed'),
(3, 1, '2024-01-19', 'completed'),
(4, 1, '2024-01-26', 'completed'),

-- Mary's orders (Middle user)
(5, 2, '2024-01-10', 'completed'),
(6, 2, '2024-01-20', 'completed'),

-- Robert's orders (Middle user)
(7, 3, '2024-01-15', 'completed'),
(8, 3, '2024-01-25', 'cancelled'),
(9, 3, '2024-01-30', 'completed'),

-- Lisa's orders (Light user)
(10, 4, '2024-01-08', 'completed'),

-- Michael's orders (Heavy user with some variety)
(11, 5, '2024-01-03', 'completed'),
(12, 5, '2024-01-13', 'completed'),
(13, 5, '2024-01-23', 'completed'),
(14, 5, '2024-01-28', 'completed');

-- 注文明細データ
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
-- John's purchases
(1, 1, 1, 1200.00),  -- Gaming Laptop
(2, 7, 2, 49.99),    -- Programming Guide
(3, 9, 1, 89.99),    -- Men's Jacket
(4, 5, 3, 29.99),    -- Best Seller Novel

-- Mary's purchases
(5, 3, 1, 999.00),   -- iPhone 15
(6, 11, 2, 79.99),   -- Women's Dress

-- Robert's purchases
(7, 2, 1, 800.00),   -- Business Laptop
(9, 8, 2, 39.99),    -- Business Book

-- Lisa's purchase
(10, 6, 1, 19.99),   -- Classic Literature

-- Michael's purchases
(11, 4, 1, 699.00),  -- Android Phone
(12, 10, 2, 59.99),  -- Men's Jeans
(13, 7, 1, 49.99),   -- Programming Guide
(14, 12, 3, 49.99);  -- Women's Skirt
