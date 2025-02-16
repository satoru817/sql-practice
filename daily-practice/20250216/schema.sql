-- 商品カテゴリ
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- 商品マスタ
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    specifications JSON,  -- 商品仕様（防水性能、サイズ、色など）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- レビュー
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    metadata JSON,  -- プラットフォーム情報、検証済み購入フラグなど
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- カテゴリ
INSERT INTO categories (category_id, name, parent_category_id) VALUES
(1, '電化製品', NULL),
(2, 'スマートフォン', 1),
(3, 'タブレット', 1),
(4, 'アクセサリー', NULL),
(5, 'ケース', 4);

-- 商品
INSERT INTO products (product_id, name, category_id, price, specifications) VALUES
(1, '防水スマートフォンケース', 5, 2999, '{"is_waterproof": true, "color": "black", "size": "L"}'),
(2, 'スタンダードケース', 5, 1999, '{"is_waterproof": false, "color": "red", "size": "M"}'),
(3, '高級スマートフォン', 2, 99999, '{"is_waterproof": true, "color": "gold", "memory": "256GB"}');

-- レビュー
INSERT INTO reviews (product_id, rating, comment, metadata) VALUES
(1, 5, '防水性能が素晴らしい', '{"platform": "mobile", "verified_purchase": true}'),
(1, 4, '使いやすい', '{"platform": "web", "verified_purchase": true}'),
(2, 3, '普通のケース', '{"platform": "mobile", "verified_purchase": true}'),
(3, 5, '最高の商品', '{"platform": "web", "verified_purchase": true}');

