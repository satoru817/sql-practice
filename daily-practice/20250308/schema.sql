CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    registration_date DATE,
    last_login_date DATE,
    country VARCHAR(50),
    referral_source VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    cost DECIMAL(10,2),
    attributes JSON
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_category_id INT NULL,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_date DATE,
    status VARCHAR(20),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    price_paid DECIMAL(10,2),
    discount_amount DECIMAL(10,2) DEFAULT 0,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE user_sessions (
    session_id INT PRIMARY KEY,
    user_id INT,
    start_time DATETIME,
    end_time DATETIME,
    device VARCHAR(50),
    platform VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Clear existing data
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE user_sessions;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE products;
TRUNCATE TABLE categories;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- Insert categories (parent categories)
INSERT INTO categories (category_id, name, parent_category_id) VALUES
(1, 'Electronics', NULL),
(2, 'Clothing', NULL),
(3, 'Home & Garden', NULL),
(4, 'Books', NULL);

-- Insert subcategories
INSERT INTO categories (category_id, name, parent_category_id) VALUES
(101, 'Smartphones', 1),
(102, 'Laptops', 1),
(103, 'Accessories', 1),
(201, 'Men''s Clothing', 2),
(202, 'Women''s Clothing', 2),
(203, 'Children''s Clothing', 2),
(301, 'Furniture', 3),
(302, 'Kitchen', 3),
(303, 'Gardening', 3),
(401, 'Fiction', 4),
(402, 'Non-Fiction', 4),
(403, 'Academic', 4);

-- Insert products
INSERT INTO products (product_id, name, category_id, price, cost, attributes) VALUES
-- Electronics - Smartphones
(1001, 'iPhone 13', 101, 999.99, 650.00, '{"color": "black", "storage": "128GB", "features": ["5G", "Face ID"]}'),
(1002, 'Samsung Galaxy S21', 101, 899.99, 550.00, '{"color": "silver", "storage": "256GB", "features": ["5G", "Fingerprint"]}'),
(1003, 'Google Pixel 6', 101, 799.99, 450.00, '{"color": "white", "storage": "128GB", "features": ["5G", "Night Sight"]}'),

-- Electronics - Laptops
(1004, 'MacBook Pro', 102, 1499.99, 950.00, '{"processor": "M1", "ram": "16GB", "storage": "512GB"}'),
(1005, 'Dell XPS 15', 102, 1299.99, 850.00, '{"processor": "i7", "ram": "16GB", "storage": "1TB"}'),
(1006, 'HP Spectre', 102, 1199.99, 750.00, '{"processor": "i5", "ram": "8GB", "storage": "512GB"}'),

-- Electronics - Accessories
(1007, 'AirPods Pro', 103, 249.99, 120.00, '{"color": "white", "wireless": true}'),
(1008, 'Wireless Mouse', 103, 49.99, 15.00, '{"color": "black", "wireless": true}'),
(1009, 'USB-C Hub', 103, 39.99, 12.00, '{"ports": 7, "features": ["HDMI", "SD Card"]}'),

-- Clothing - Men's
(2001, 'Men''s Slim Jeans', 201, 59.99, 20.00, '{"size": "varies", "color": "blue", "material": "denim"}'),
(2002, 'Men''s Casual Shirt', 201, 39.99, 12.00, '{"size": "varies", "color": "varies", "material": "cotton"}'),
(2003, 'Men''s Jacket', 201, 89.99, 35.00, '{"size": "varies", "color": "black", "material": "polyester"}'),

-- Clothing - Women's
(2004, 'Women''s Dress', 202, 79.99, 30.00, '{"size": "varies", "color": "varies", "material": "cotton blend"}'),
(2005, 'Women''s Blouse', 202, 49.99, 18.00, '{"size": "varies", "color": "varies", "material": "silk"}'),
(2006, 'Women''s Leggings', 202, 29.99, 8.00, '{"size": "varies", "color": "black", "material": "spandex"}'),

-- Clothing - Children's
(2007, 'Kid''s T-shirt', 203, 19.99, 5.00, '{"size": "varies", "color": "varies", "material": "cotton"}'),
(2008, 'Kid''s Jeans', 203, 34.99, 10.00, '{"size": "varies", "color": "blue", "material": "denim"}'),
(2009, 'Kid''s Sweater', 203, 29.99, 8.00, '{"size": "varies", "color": "varies", "material": "wool blend"}'),

-- Home & Garden - Furniture
(3001, 'Sofa', 301, 599.99, 350.00, '{"color": "varies", "material": "fabric", "seats": 3}'),
(3002, 'Coffee Table', 301, 199.99, 80.00, '{"color": "brown", "material": "wood"}'),
(3003, 'Bookshelf', 301, 149.99, 60.00, '{"color": "varies", "material": "wood", "shelves": 5}'),

-- Home & Garden - Kitchen
(3004, 'Blender', 302, 79.99, 30.00, '{"color": "silver", "power": "1000W"}'),
(3005, 'Cookware Set', 302, 199.99, 80.00, '{"pieces": 10, "material": "stainless steel"}'),
(3006, 'Knife Set', 302, 129.99, 50.00, '{"pieces": 6, "material": "stainless steel"}'),

-- Home & Garden - Gardening
(3007, 'Garden Hose', 303, 29.99, 10.00, '{"length": "50ft", "material": "rubber"}'),
(3008, 'Plant Pot Set', 303, 49.99, 15.00, '{"pieces": 3, "material": "ceramic"}'),
(3009, 'Pruning Shears', 303, 19.99, 5.00, '{"material": "steel", "handle": "rubber grip"}'),

-- Books - Fiction
(4001, 'The Great Gatsby', 401, 14.99, 5.00, '{"author": "F. Scott Fitzgerald", "format": "paperback", "pages": 180}'),
(4002, 'To Kill a Mockingbird', 401, 12.99, 4.00, '{"author": "Harper Lee", "format": "paperback", "pages": 281}'),
(4003, '1984', 401, 11.99, 3.50, '{"author": "George Orwell", "format": "paperback", "pages": 328}'),

-- Books - Non-Fiction
(4004, 'Sapiens', 402, 24.99, 10.00, '{"author": "Yuval Noah Harari", "format": "hardcover", "pages": 443}'),
(4005, 'Atomic Habits', 402, 19.99, 8.00, '{"author": "James Clear", "format": "paperback", "pages": 320}'),
(4006, 'Educated', 402, 16.99, 6.00, '{"author": "Tara Westover", "format": "paperback", "pages": 334}'),

-- Books - Academic
(4007, 'Introduction to Algorithms', 403, 79.99, 40.00, '{"author": "Cormen et al.", "format": "hardcover", "pages": 1312}'),
(4008, 'Data Science for Business', 403, 59.99, 25.00, '{"author": "Provost & Fawcett", "format": "paperback", "pages": 414}'),
(4009, 'Organic Chemistry', 403, 89.99, 45.00, '{"author": "Paula Bruice", "format": "hardcover", "pages": 1344}');

-- Insert users
INSERT INTO users (user_id, name, email, registration_date, last_login_date, country, referral_source) VALUES
(1, 'John Smith', 'john.smith@example.com', '2023-01-15', '2023-03-01', 'USA', 'Search Engine'),
(2, 'Jane Doe', 'jane.doe@example.com', '2023-01-20', '2023-03-02', 'Canada', 'Social Media'),
(3, 'Michael Johnson', 'michael.j@example.com', '2023-01-25', '2023-03-01', 'UK', 'Referral'),
(4, 'Emily Brown', 'emily.b@example.com', '2023-02-01', '2023-03-02', 'USA', 'Direct'),
(5, 'David Wilson', 'david.w@example.com', '2023-02-05', '2023-03-01', 'Australia', 'Search Engine'),
(6, 'Sarah Taylor', 'sarah.t@example.com', '2023-02-10', '2023-03-03', 'USA', 'Social Media'),
(7, 'James Anderson', 'james.a@example.com', '2023-02-15', '2023-02-28', 'Canada', 'Referral'),
(8, 'Lisa Martinez', 'lisa.m@example.com', '2023-02-20', '2023-03-03', 'USA', 'Search Engine'),
(9, 'Robert Thomas', 'robert.t@example.com', '2023-01-05', '2023-03-02', 'UK', 'Direct'),
(10, 'Jennifer Garcia', 'jennifer.g@example.com', '2023-01-10', '2023-03-01', 'USA', 'Social Media');

-- Insert orders
INSERT INTO orders (order_id, user_id, order_date, status, total_amount, payment_method) VALUES
-- January orders
(101, 1, '2023-01-16', 'completed', 1049.98, 'Credit Card'),
(102, 2, '2023-01-21', 'completed', 849.98, 'PayPal'),
(103, 3, '2023-01-26', 'completed', 1699.98, 'Credit Card'),
(104, 4, '2023-01-28', 'cancelled', 129.99, 'Credit Card'),
(105, 5, '2023-01-30', 'completed', 299.97, 'PayPal'),
(106, 9, '2023-01-08', 'completed', 899.99, 'Credit Card'),
(107, 10, '2023-01-12', 'completed', 249.99, 'PayPal'),

-- February orders
(201, 1, '2023-02-05', 'completed', 899.99, 'Credit Card'),
(202, 2, '2023-02-10', 'completed', 1499.99, 'PayPal'),
(203, 3, '2023-02-15', 'completed', 79.99, 'Credit Card'),
(204, 6, '2023-02-12', 'completed', 1099.97, 'PayPal'),
(205, 7, '2023-02-17', 'completed', 249.97, 'Credit Card'),
(206, 8, '2023-02-22', 'completed', 599.99, 'PayPal'),
(207, 9, '2023-02-08', 'completed', 799.99, 'Credit Card'),
(208, 10, '2023-02-18', 'completed', 149.97, 'PayPal'),
(209, 4, '2023-02-25', 'processing', 199.99, 'Credit Card'),
(210, 5, '2023-02-28', 'completed', 39.99, 'PayPal'),

-- March orders
(301, 1, '2023-03-01', 'completed', 149.97, 'Credit Card'),
(302, 2, '2023-03-02', 'completed', 599.99, 'PayPal'),
(303, 3, '2023-03-01', 'completed', 129.99, 'Credit Card'),
(304, 4, '2023-03-02', 'completed', 1799.97, 'PayPal'),
(305, 5, '2023-03-01', 'processing', 89.99, 'Credit Card'),
(306, 6, '2023-03-03', 'completed', 369.96, 'PayPal'),
(307, 8, '2023-03-03', 'completed', 999.99, 'Credit Card');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, price_paid, discount_amount) VALUES
-- January orders
(101, 1001, 1, 999.99, 0.00),          -- iPhone 13
(101, 1007, 1, 249.99, 0.00),         -- AirPods Pro
(102, 1005, 1, 1299.99, 50.00),        -- Dell XPS 15
(102, 1008, 1, 49.99, 0.00),          -- Wireless Mouse
(103, 3001, 1, 599.99, 0.00),          -- Sofa
(103, 3002, 1, 199.99, 0.00),          -- Coffee Table
(105, 4001, 1, 14.99, 0.00),           -- The Great Gatsby
(105, 4002, 1, 12.99, 0.00),           -- To Kill a Mockingbird
(105, 4003, 1, 11.99, 0.00),           -- 1984
(106, 1002, 1, 899.99, 0.00),          -- Samsung Galaxy S21
(107, 1007, 1, 249.99, 0.00),          -- AirPods Pro

-- February orders
(201, 1002, 1, 899.99, 0.00),          -- Samsung Galaxy S21
(202, 1004, 1, 1499.99, 0.00),         -- MacBook Pro
(203, 3004, 1, 79.99, 0.00),           -- Blender
(204, 2001, 1, 59.99, 0.00),           -- Men's Slim Jeans
(204, 2004, 1, 79.99, 0.00),           -- Women's Dress
(204, 3001, 1, 599.99, 0.00),          -- Sofa
(205, 2007, 5, 19.99, 10.00),          -- Kid's T-shirt (5 with discount)
(205, 2008, 2, 34.99, 5.00),           -- Kid's Jeans (2 with discount)
(206, 3001, 1, 599.99, 0.00),          -- Sofa
(207, 1003, 1, 799.99, 0.00),          -- Google Pixel 6
(208, 4004, 1, 24.99, 0.00),           -- Sapiens
(208, 4005, 1, 19.99, 0.00),           -- Atomic Habits
(208, 4006, 3, 16.99, 5.00),           -- Educated (3 with discount)
(210, 1009, 1, 39.99, 0.00),           -- USB-C Hub

-- March orders
(301, 4001, 1, 14.99, 0.00),           -- The Great Gatsby
(301, 4005, 1, 19.99, 0.00),           -- Atomic Habits
(301, 4008, 1, 59.99, 0.00),           -- Data Science for Business
(302, 3001, 1, 599.99, 0.00),          -- Sofa
(303, 3006, 1, 129.99, 0.00),          -- Knife Set
(304, 1004, 1, 1499.99, 0.00),         -- MacBook Pro
(304, 1007, 1, 249.99, 0.00),          -- AirPods Pro
(304, 1009, 1, 39.99, 0.00),           -- USB-C Hub
(306, 2002, 2, 39.99, 5.00),           -- Men's Casual Shirt (2 with discount)
(306, 2005, 2, 49.99, 10.00),          -- Women's Blouse (2 with discount)
(307, 1001, 1, 999.99, 0.00);          -- iPhone 13

-- Insert user sessions
INSERT INTO user_sessions (session_id, user_id, start_time, end_time, device, platform) VALUES
(1001, 1, '2023-01-16 09:30:00', '2023-01-16 09:45:00', 'Mobile', 'iOS'),
(1002, 2, '2023-01-21 14:00:00', '2023-01-21 14:30:00', 'Desktop', 'Windows'),
(1003, 3, '2023-01-26 18:15:00', '2023-01-26 19:00:00', 'Tablet', 'Android'),
(1004, 4, '2023-01-28 12:00:00', '2023-01-28 12:15:00', 'Mobile', 'Android'),
(1005, 5, '2023-01-30 20:00:00', '2023-01-30 20:45:00', 'Desktop', 'macOS'),

(2001, 1, '2023-02-05 10:00:00', '2023-02-05 10:30:00', 'Desktop', 'Windows'),
(2002, 2, '2023-02-10 11:30:00', '2023-02-10 12:00:00', 'Mobile', 'iOS'),
(2003, 3, '2023-02-15 15:45:00', '2023-02-15 16:15:00', 'Tablet', 'iPadOS'),
(2004, 6, '2023-02-12 17:00:00', '2023-02-12 17:45:00', 'Desktop', 'macOS'),
(2005, 7, '2023-02-17 09:15:00', '2023-02-17 09:45:00', 'Mobile', 'Android'),
(2006, 8, '2023-02-22 13:30:00', '2023-02-22 14:00:00', 'Desktop', 'Windows'),
(2007, 9, '2023-02-08 19:00:00', '2023-02-08 19:30:00', 'Mobile', 'iOS'),
(2008, 10, '2023-02-18 21:15:00', '2023-02-18 21:45:00', 'Tablet', 'Android'),
(2009, 4, '2023-02-25 14:30:00', '2023-02-25 15:00:00', 'Desktop', 'Windows'),
(2010, 5, '2023-02-28 16:45:00', '2023-02-28 17:15:00', 'Mobile', 'iOS'),

(3001, 1, '2023-03-01 09:00:00', '2023-03-01 09:30:00', 'Mobile', 'iOS'),
(3002, 2, '2023-03-02 10:15:00', '2023-03-02 10:45:00', 'Desktop', 'Windows'),
(3003, 3, '2023-03-01 11:30:00', '2023-03-01 12:00:00', 'Tablet', 'Android'),
(3004, 4, '2023-03-02 13:45:00', '2023-03-02 14:15:00', 'Desktop', 'macOS'),
(3005, 5, '2023-03-01 15:00:00', '2023-03-01 15:30:00', 'Mobile', 'Android'),
(3006, 6, '2023-03-03 16:15:00', '2023-03-03 16:45:00', 'Desktop', 'Windows'),
(3007, 8, '2023-03-03 17:30:00', '2023-03-03 18:00:00', 'Mobile', 'iOS');

-- Add some orphaned products (category that doesn't exist)
INSERT INTO products (product_id, name, category_id, price, cost, attributes) VALUES
(5001, 'Orphaned Product 1', 999, 99.99, 40.00, '{"status": "discontinued"}'),
(5002, 'Orphaned Product 2', 999, 149.99, 70.00, '{"status": "discontinued"}');

-- Add some orders with orphaned products
INSERT INTO orders (order_id, user_id, order_date, status, total_amount, payment_method) VALUES
(401, 3, '2023-01-31', 'completed', 249.98, 'Credit Card');

INSERT INTO order_items (order_id, product_id, quantity, price_paid, discount_amount) VALUES
(401, 5001, 1, 99.99, 0.00),
(401, 5002, 1, 149.99, 0.00);
