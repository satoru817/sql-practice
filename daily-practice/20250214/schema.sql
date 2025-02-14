CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    description TEXT,
    specifications JSON
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT,
    review_text TEXT,
    review_date DATE,
    metadata JSON
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100),
    parent_category_id INT
);

-- カテゴリーデータ
INSERT INTO categories (category_id, name, parent_category_id) VALUES
(1, 'アウトドア', NULL),
(2, 'アパレル', NULL),
(3, 'レインウェア', 1),
(4, 'キャンプ用品', 1),
(5, 'Tシャツ', 2),
(6, 'パンツ', 2);

-- 商品データ
INSERT INTO products (product_id, name, category_id, price, description, specifications) VALUES
(1, 'マウンテンパーカー', 3, 15000, '高機能レインウェア', 
    '{"color": "navy", "size": "M", "is_waterproof": true, "materials": ["nylon", "polyester"]}'),
(2, 'キャンプテント', 4, 25000, '3人用テント', 
    '{"color": "green", "size": "3person", "is_waterproof": true, "materials": ["nylon", "aluminum"]}'),
(3, '速乾Tシャツ', 5, 3000, 'スポーツ用Tシャツ', 
    '{"color": "white", "size": "L", "is_waterproof": false, "materials": ["polyester"]}'),
(4, 'アウトドアパンツ', 6, 8000, '撥水加工パンツ', 
    '{"color": "beige", "size": "M", "is_waterproof": true, "materials": ["cotton", "polyester"]}'),
(5, 'レインポンチョ', 3, 5000, '携帯用レインウェア', 
    '{"color": "blue", "size": "free", "is_waterproof": true, "materials": ["nylon"]}');

-- レビューデータ
INSERT INTO reviews (review_id, product_id, user_id, rating, review_text, review_date, metadata) VALUES
-- マウンテンパーカー（product_id = 1）のレビュー
(1, 1, 101, 5, '防水性抜群です', '2024-01-01', 
    '{"verified_purchase": true, "platform": "mobile", "helpful_votes": 3, "images": ["img1.jpg"]}'),
(2, 1, 102, 4, '着心地良いです', '2024-01-02', 
    '{"verified_purchase": true, "platform": "mobile", "helpful_votes": 2}'),
(3, 1, 103, 5, '非常に満足', '2024-01-03', 
    '{"verified_purchase": true, "platform": "desktop", "helpful_votes": 5}'),
(4, 1, 104, 4, '良い買い物でした', '2024-01-04', 
    '{"verified_purchase": true, "platform": "desktop", "helpful_votes": 1}'),
(5, 1, 105, 3, 'サイズが少し大きい', '2024-01-05', 
    '{"verified_purchase": false, "platform": "mobile", "helpful_votes": 0}'),
(6, 1, 106, 5, '完璧な防水性', '2024-01-06', 
    '{"verified_purchase": true, "platform": "mobile", "helpful_votes": 4}'),

-- キャンプテント（product_id = 2）のレビュー
(7, 2, 201, 5, '設営が簡単', '2024-01-01', 
    '{"verified_purchase": true, "platform": "mobile", "helpful_votes": 7}'),
(8, 2, 202, 4, '防水性能良好', '2024-01-02', 
    '{"verified_purchase": true, "platform": "desktop", "helpful_votes": 3}'),
(9, 2, 203, 5, '大満足です', '2024-01-03', 
    '{"verified_purchase": true, "platform": "mobile", "helpful_votes": 5}'),
(10, 2, 204, 3, '少し重い', '2024-01-04', 
    '{"verified_purchase": true, "platform": "desktop", "helpful_votes": 2}'),

-- 速乾Tシャツ（product_id = 3）のレビュー
(11, 3, 301, 4, '着心地良い', '2024-01-01', 
    '{"verified_purchase": true, "platform": "mobile", "helpful_votes": 2}'),
(12, 3, 302, 5, '速乾性抜群', '2024-01-02', 
    '{"verified_purchase": true, "platform": "desktop", "helpful_votes": 4}'),

-- アウトドアパンツ（product_id = 4）のレビュー
(13, 4, 401, 5, '撥水性能良好', '2024-01-01', 
    '{"verified_purchase": true, "platform": "mobile", "helpful_votes": 6}'),
(14, 4, 402, 4, 'フィット感が良い', '2024-01-02', 
    '{"verified_purchase": true, "platform": "mobile", "helpful_votes": 3}'),
(15, 4, 403, 5, '動きやすい', '2024-01-03', 
    '{"verified_purchase": true, "platform": "desktop", "helpful_votes": 4}'),
(16, 4, 404, 4, '良い商品です', '2024-01-04', 
    '{"verified_purchase": true, "platform": "desktop", "helpful_votes": 2}'),
(17, 4, 405, 5, 'サイズも丁度良い', '2024-01-05', 
    '{"verified_purchase": true, "platform": "mobile", "helpful_votes": 1}'),
(18, 4, 406, 4, '満足です', '2024-01-06', 
    '{"verified_purchase": true, "platform": "desktop", "helpful_votes": 3}'),

-- レインポンチョ（product_id = 5）のレビュー
(19, 5, 501, 5, 'コンパクトで便利', '2024-01-01', 
    '{"verified_purchase": true, "platform": "mobile", "helpful_votes": 4}'),
(20, 5, 502, 4, '携帯に便利', '2024-01-02', 
    '{"verified_purchase": true, "platform": "desktop", "helpful_votes": 2}');
