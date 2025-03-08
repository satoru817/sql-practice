I'd be happy to give you a challenging SQL problem to test your skills. Here's a problem that will require some advanced SQL concepts:

# Advanced SQL Challenge: E-commerce Analytics

## Database Schema

```sql
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
```

## Challenge

Write a SQL query that analyzes customer purchase behavior with the following requirements:

1. For each product category (including parent categories), calculate:
   - Total revenue
   - Total profit
   - Number of unique customers
   - Average order value
   - Percentage of total store revenue

2. For each parent category, identify the top 3 subcategories by revenue

3. Calculate the customer retention rate by showing what percentage of customers who purchased in one month also made a purchase in the following month

4. Include only completed orders (status = 'completed')

5. Use window functions and CTEs for better organization

6. Handle cases where products may belong to subcategories that have been deleted (orphaned products)

7. Format monetary values with 2 decimal places and percentages with 1 decimal place

This query should provide a comprehensive analysis that could be used by business stakeholders to understand product category performance and customer retention patterns.
