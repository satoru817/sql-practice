-- スキーマ定義
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    metadata JSON,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    specifications JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    preferences JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- サンプルデータ
INSERT INTO categories VALUES
(1, 'Electronics', NULL, '{"display_order": 1, "icon": "electronics.png"}'),
(2, 'Smartphones', 1, '{"display_order": 1, "specifications": ["brand", "color", "storage"]}'),
(3, 'Laptops', 1, '{"display_order": 2, "specifications": ["brand", "cpu", "ram", "storage"]}'),
(4, 'Books', NULL, '{"display_order": 2, "icon": "books.png"}'),
(5, 'Programming', 4, '{"display_order": 1, "topics": ["web", "mobile", "database"]}');

INSERT INTO products VALUES
(1, 'iPhone 14', 2, 999.99, 'Latest iPhone model', '{"color": ["black", "white"], "storage": ["128GB", "256GB"]}', '2024-01-01'),
(2, 'MacBook Pro', 3, 1499.99, 'Professional laptop', '{"cpu": "M2", "ram": "16GB", "storage": "512GB"}', '2024-01-02'),
(3, 'Database Design', 5, 49.99, 'Complete guide to DB', '{"format": ["print", "digital"], "pages": 450}', '2024-01-03'),
(4, 'Android Dev', 5, 39.99, 'Android programming', '{"format": ["digital"], "pages": 380}', '2024-01-04');

INSERT INTO customers VALUES
(1, 'John Doe', 'john@example.com', '{"interests": ["technology", "programming"], "preferred_format": "digital"}', '2024-01-01'),
(2, 'Jane Smith', 'jane@example.com', '{"interests": ["mobile", "photography"], "preferred_format": "print"}', '2024-01-02'),
(3, 'Bob Wilson', 'bob@example.com', '{"interests": ["programming"], "preferred_format": "digital"}', '2024-01-03');

INSERT INTO reviews VALUES
(1, 1, 1, 5, 'Great phone!', '{"verified_purchase": true, "helpful_votes": 10}', '2024-01-15'),
(2, 1, 2, 4, 'Good but expensive', '{"verified_purchase": true, "helpful_votes": 5}', '2024-01-16'),
(3, 2, 1, 5, 'Perfect for development', '{"verified_purchase": true, "helpful_votes": 15}', '2024-01-17'),
(4, 3, 3, 4, 'Comprehensive guide', '{"verified_purchase": true, "helpful_votes": 8}', '2024-01-18'),
(5, 3, 1, 5, 'Excellent resource', '{"verified_purchase": false, "helpful_votes": 3}', '2024-01-19');
