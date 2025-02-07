-- 商品カテゴリマスタ
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    attributes JSON,  -- カテゴリ固有の属性（例：本の場合は出版社情報、電化製品の場合は製造元情報）
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- 商品マスタ
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    specs JSON,  -- 商品仕様（サイズ、重量、色など）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 注文ヘッダ
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    delivery_info JSON,  -- 配送情報（住所、希望配送時間など）
    payment_info JSON,   -- 支払情報（支払方法、使用ポイントなど）
    total_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL
);

-- 注文明細
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    customization JSON,  -- カスタマイズ情報（ギフトラッピング、メッセージカードなど）
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- カスタマーレビュー
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    review_date TIMESTAMP NOT NULL,
    review_text TEXT,
    review_details JSON,  -- 詳細評価（評価項目ごとの点数など）
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- カテゴリのテストデータ
INSERT INTO categories (category_id, name, parent_category_id, attributes) VALUES
(1, '本・雑誌', NULL, '{"publishing_info": {"country": "JP", "requires_age_verification": false}}'),
(2, '家電製品', NULL, '{"warranty_info": {"standard_years": 1, "extended_available": true}}'),
(3, '文学・小説', 1, '{"publishing_info": {"genres": ["fiction", "literature"], "target_age": "adult"}}'),
(4, 'ビジネス書', 1, '{"publishing_info": {"genres": ["business", "economics"], "target_age": "adult"}}'),
(5, 'スマートフォン', 2, '{"warranty_info": {"standard_years": 1, "repair_locations": ["直営店", "認定店"]}}'),
(6, 'タブレット', 2, '{"warranty_info": {"standard_years": 1, "repair_locations": ["直営店", "認定店"]}}');

-- 商品のテストデータ
INSERT INTO products (product_id, name, category_id, price, cost, specs) VALUES
(1, '星の王子様', 3, 1540, 770, '{"format": "hardcover", "pages": 120, "language": "JP", "weight": 250}'),
(2, '経営戦略入門', 4, 3300, 1650, '{"format": "paperback", "pages": 320, "language": "JP", "weight": 400}'),
(3, 'Phone Pro 13', 5, 98000, 68600, '{"color": "black", "storage": "256GB", "screen": "6.1inch", "weight": 174}'),
(4, 'Phone Pro 13', 5, 98000, 68600, '{"color": "white", "storage": "256GB", "screen": "6.1inch", "weight": 174}'),
(5, 'TabletX Pro', 6, 79800, 55860, '{"color": "space-gray", "storage": "256GB", "screen": "11inch", "weight": 471}');

-- 注文のテストデータ
INSERT INTO orders (order_id, customer_id, order_date, delivery_info, payment_info, total_amount, status) VALUES
(1, 101, '2024-01-15 10:00:00', 
    '{"method": "宅配便", "time_slot": "14-16", "address": {"prefecture": "東京都", "city": "新宿区"}}',
    '{"method": "credit_card", "points_used": 0}',
    98000, 'completed'),
(2, 102, '2024-01-15 11:30:00',
    '{"method": "コンビニ受取", "store": "セブンイレブン", "address": {"prefecture": "大阪府", "city": "大阪市"}}',
    '{"method": "convenience_store", "points_used": 500}',
    4840, 'completed'),
(3, 103, '2024-01-16 09:15:00',
    '{"method": "宅配便", "time_slot": "19-21", "address": {"prefecture": "神奈川県", "city": "横浜市"}}',
    '{"method": "credit_card", "points_used": 2000}',
    77800, 'completed');

-- 注文明細のテストデータ
INSERT INTO order_items (order_id, product_id, quantity, unit_price, customization) VALUES
(1, 3, 1, 98000, '{"gift_wrap": false, "message": null}'),
(2, 1, 1, 1540, '{"gift_wrap": true, "message": "お誕生日おめでとう"}'),
(2, 2, 1, 3300, '{"gift_wrap": false, "message": null}'),
(3, 5, 1, 77800, '{"gift_wrap": false, "message": null}');

-- レビューのテストデータ
INSERT INTO reviews (review_id, product_id, customer_id, rating, review_date, review_text, review_details) VALUES
(1, 3, 101, 5, '2024-01-20 18:30:00', 'カメラの性能が素晴らしい',
    '{"camera": 5, "battery": 4, "design": 5, "performance": 5}'),
(2, 3, 102, 4, '2024-01-21 14:20:00', 'バッテリーの持ちがやや気になる',
    '{"camera": 5, "battery": 3, "design": 4, "performance": 4}'),
(3, 1, 103, 5, '2024-01-22 09:45:00', '装丁が美しい名作',
    '{"content": 5, "binding": 5, "paper_quality": 4, "readability": 5}'),
(4, 5, 104, 4, '2024-01-22 16:15:00', '使いやすくて良い',
    '{"screen": 5, "battery": 4, "design": 4, "performance": 4}');

-- カテゴリの追加データ
INSERT INTO categories (category_id, name, parent_category_id, attributes) VALUES
(7, 'マンガ', 1, '{"publishing_info": {"genres": ["manga", "comics"], "target_age": "all"}}'),
(8, '参考書', 1, '{"publishing_info": {"genres": ["education"], "target_age": "student"}}'),
(9, 'オーディオ機器', 2, '{"warranty_info": {"standard_years": 2, "repair_locations": ["直営店"]}}'),
(10, '調理家電', 2, '{"warranty_info": {"standard_years": 1, "water_resistance": true}}');

-- 商品の追加データ
INSERT INTO products (product_id, name, category_id, price, cost, specs) VALUES
(6, 'ワンピース 103巻', 7, 484, 242, '{"format": "paperback", "pages": 192, "language": "JP", "weight": 180}'),
(7, '鬼滅の刃 23巻', 7, 484, 242, '{"format": "paperback", "pages": 192, "language": "JP", "weight": 180}'),
(8, '英語総合問題集', 8, 2200, 1100, '{"format": "paperback", "pages": 420, "language": "JP", "weight": 550}'),
(9, 'ワイヤレスイヤホンPro', 9, 29800, 14900, '{"color": "black", "battery": "30h", "weight": 67, "water_resistant": true}'),
(10, 'ワイヤレスイヤホンPro', 9, 29800, 14900, '{"color": "white", "battery": "30h", "weight": 67, "water_resistant": true}'),
(11, '全自動コーヒーメーカー', 10, 32800, 16400, '{"color": "black", "capacity": "1L", "weight": 4200, "timer": true}'),
(12, 'Phone Pro 13', 5, 98000, 68600, '{"color": "blue", "storage": "512GB", "screen": "6.1inch", "weight": 174}'),
(13, '経営の未来図', 4, 2860, 1430, '{"format": "paperback", "pages": 280, "language": "JP", "weight": 350}'),
(14, 'TabletX Pro', 6, 79800, 55860, '{"color": "silver", "storage": "512GB", "screen": "11inch", "weight": 471}');

-- 注文の追加データ
INSERT INTO orders (order_id, customer_id, order_date, delivery_info, payment_info, total_amount, status) VALUES
(4, 104, '2024-01-16 14:20:00',
    '{"method": "宅配便", "time_slot": "16-18", "address": {"prefecture": "東京都", "city": "渋谷区"}}',
    '{"method": "credit_card", "points_used": 1000}',
    29800, 'completed'),
(5, 105, '2024-01-17 10:30:00',
    '{"method": "店舗受取", "store": "渋谷店", "address": {"prefecture": "東京都", "city": "渋谷区"}}',
    '{"method": "cash", "points_used": 0}',
    98000, 'completed'),
(6, 106, '2024-01-17 15:45:00',
    '{"method": "宅配便", "time_slot": "19-21", "address": {"prefecture": "千葉県", "city": "船橋市"}}',
    '{"method": "credit_card", "points_used": 3000}',
    32800, 'completed'),
(7, 107, '2024-01-18 09:10:00',
    '{"method": "コンビニ受取", "store": "ファミリーマート", "address": {"prefecture": "埼玉県", "city": "さいたま市"}}',
    '{"method": "convenience_store", "points_used": 0}',
    968, 'completed'),
(8, 108, '2024-01-18 13:25:00',
    '{"method": "宅配便", "time_slot": "12-14", "address": {"prefecture": "東京都", "city": "港区"}}',
    '{"method": "credit_card", "points_used": 5000}',
    79800, 'completed');

-- 注文明細の追加データ
INSERT INTO order_items (order_id, product_id, quantity, unit_price, customization) VALUES
(4, 9, 1, 29800, '{"gift_wrap": false, "message": null}'),
(5, 12, 1, 98000, '{"gift_wrap": false, "message": null}'),
(6, 11, 1, 32800, '{"gift_wrap": true, "message": "新生活のお祝いに"}'),
(7, 6, 1, 484, '{"gift_wrap": false, "message": null}'),
(7, 7, 1, 484, '{"gift_wrap": false, "message": null}'),
(8, 14, 1, 79800, '{"gift_wrap": true, "message": "就職おめでとう"}');

-- レビューの追加データ
INSERT INTO reviews (review_id, product_id, customer_id, rating, review_date, review_text, review_details) VALUES
(5, 9, 104, 5, '2024-01-23 10:20:00', '音質が素晴らしい',
    '{"sound": 5, "comfort": 5, "battery": 4, "noise_cancelling": 5}'),
(6, 12, 105, 4, '2024-01-24 16:40:00', '容量が十分で使いやすい',
    '{"camera": 4, "battery": 4, "design": 5, "performance": 4}'),
(7, 11, 106, 5, '2024-01-25 08:15:00', 'タイマー機能が便利',
    '{"ease_of_use": 5, "cleaning": 4, "timer": 5, "taste": 5}'),
(8, 6, 107, 5, '2024-01-25 19:30:00', '面白かった',
    '{"story": 5, "art": 5, "print_quality": 4, "price": 5}'),
(9, 14, 108, 4, '2024-01-26 11:45:00', '描画性能が素晴らしい',
    '{"screen": 5, "battery": 4, "design": 4, "performance": 5}'),
(10, 3, 109, 5, '2024-01-26 15:20:00', '写真がきれい',
    '{"camera": 5, "battery": 4, "design": 5, "performance": 5}');

-- さらに注文データを追加（過去の傾向分析用）
INSERT INTO orders (order_id, customer_id, order_date, delivery_info, payment_info, total_amount, status) VALUES
(9, 110, '2024-01-19 11:30:00',
    '{"method": "宅配便", "time_slot": "14-16", "address": {"prefecture": "東京都", "city": "品川区"}}',
    '{"method": "credit_card", "points_used": 0}',
    32284, 'completed'),
(10, 111, '2024-01-19 16:45:00',
    '{"method": "宅配便", "time_slot": "19-21", "address": {"prefecture": "神奈川県", "city": "川崎市"}}',
    '{"method": "credit_card", "points_used": 2000}',
    98000, 'completed');

INSERT INTO order_items (order_id, product_id, quantity, unit_price, customization) VALUES
(9, 13, 1, 2860, '{"gift_wrap": false, "message": null}'),
(9, 9, 1, 29800, '{"gift_wrap": true, "message": "誕生日おめでとう"}'),
(10, 4, 1, 98000, '{"gift_wrap": false, "message": null}');

INSERT INTO reviews (review_id, product_id, customer_id, rating, review_date, review_text, review_details) VALUES
(11, 13, 110, 4, '2024-01-27 09:30:00', '内容が充実している',
    '{"content": 4, "readability": 4, "examples": 5, "relevance": 4}'),
(12, 9, 110, 5, '2024-01-27 09:35:00', 'ノイズキャンセリングが優秀',
    '{"sound": 5, "comfort": 4, "battery": 5, "noise_cancelling": 5}'),
(13, 4, 111, 5, '2024-01-27 14:20:00', 'デザインが気に入っている',
    '{"camera": 5, "battery": 4, "design": 5, "performance": 5}');

