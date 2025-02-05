CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(50)
);
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    profile_data JSON,  -- 年齢、性別、趣味などのJSONデータ
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP,
    total_amount DECIMAL(10,2),
    order_details JSON,  -- 配送先や支払い方法などのJSONデータ
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(200),
    category_id INT,
    attributes JSON  -- 色、サイズ、素材などのJSONデータ
);
