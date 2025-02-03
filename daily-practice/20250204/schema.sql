CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    category_id INT,
    specs JSON,  -- 商品スペックをJSON形式で保存
    created_at TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP,
    shipping_address JSON,  -- 配送先情報をJSON形式で保存
    status VARCHAR(20)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(50),
    parent_category_id INT
);
