-- 顧客データの挿入
INSERT INTO customers (customer_id, name, profile_data) VALUES
(1, '山田太郎', '{"age": 35, "gender": "male", "hobbies": ["読書", "ゴルフ"], "occupation": "会社員"}'),
(2, '鈴木花子', '{"age": 28, "gender": "female", "hobbies": ["料理", "ヨガ"], "occupation": "デザイナー"}'),
(3, '佐藤健一', '{"age": 45, "gender": "male", "hobbies": ["釣り", "カメラ"], "occupation": "自営業"}'),
(4, '田中美咲', '{"age": 32, "gender": "female", "hobbies": ["旅行", "カフェ巡り"], "occupation": "医師"}'),
(5, '渡辺修平', '{"age": 52, "gender": "male", "hobbies": ["ワイン", "美術"], "occupation": "経営者"}');

INSERT INTO categories VALUES
(1, '時計'),
(2, 'バッグ'),
(3, '食品'),
(4, 'ワイン'),
(5, 'ガジェット');

-- 商品データの挿入
INSERT INTO products (product_id, name, category_id, attributes) VALUES
(1, '高級腕時計A', 1, '{"color": "silver", "material": "stainless steel", "water_resistant": true}'),
(2, 'デザイナーバッグB', 2, '{"color": "black", "material": "leather", "size": "medium"}'),
(3, '有機食品セットC', 3, '{"type": "organic", "contents": ["野菜", "果物", "調味料"], "weight": "2kg"}'),
(4, 'プレミアムワインD', 4, '{"origin": "France", "year": 2015, "type": "red"}'),
(5, 'スマートガジェットE', 5, '{"color": "black", "warranty": "2years", "features": ["防水", "GPS"]}');

-- 注文データの挿入（過去2年分のデータ）
INSERT INTO orders (order_id, customer_id, order_date, total_amount, order_details) VALUES
-- VIP顧客（id: 1）の注文
(1, 1, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 15 DAY), 250000.00, '{"payment": "credit_card", "shipping": "express"}'),
(2, 1, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 45 DAY), 180000.00, '{"payment": "credit_card", "shipping": "normal"}'),
(3, 1, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 75 DAY), 420000.00, '{"payment": "bank_transfer", "shipping": "express"}'),

-- 優良顧客（id: 2）の注文
(4, 2, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 30 DAY), 150000.00, '{"payment": "credit_card", "shipping": "normal"}'),
(5, 2, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 120 DAY), 95000.00, '{"payment": "credit_card", "shipping": "express"}'),
(6, 2, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 180 DAY), 78000.00, '{"payment": "convenience_store", "shipping": "normal"}'),

-- 通常顧客（id: 3）の注文
(7, 3, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 150 DAY), 45000.00, '{"payment": "credit_card", "shipping": "normal"}'),
(8, 3, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 300 DAY), 32000.00, '{"payment": "convenience_store", "shipping": "normal"}'),

-- 離反顧客（id: 4）の注文
(9, 4, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 400 DAY), 28000.00, '{"payment": "credit_card", "shipping": "normal"}'),
(10, 4, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 500 DAY), 35000.00, '{"payment": "bank_transfer", "shipping": "normal"}'),

-- 新規顧客（id: 5）の注文
(11, 5, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 5 DAY), 320000.00, '{"payment": "credit_card", "shipping": "express"}');

-- 注文明細データの挿入
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
-- VIP顧客の注文明細
(1, 1, 1, 250000.00),
(2, 2, 2, 90000.00),
(3, 4, 6, 70000.00),

-- 優良顧客の注文明細
(4, 2, 1, 150000.00),
(5, 3, 5, 19000.00),
(6, 5, 1, 78000.00),

-- 通常顧客の注文明細
(7, 3, 3, 15000.00),
(8, 5, 1, 32000.00),

-- 離反顧客の注文明細
(9, 3, 2, 14000.00),
(10, 5, 1, 35000.00),

-- 新規顧客の注文明細
(11, 1, 1, 320000.00);

-- カテゴリマスタ
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO categories VALUES
(1, '時計'),
(2, 'バッグ'),
(3, '食品'),
(4, 'ワイン'),
(5, 'ガジェット');

-- 既存の顧客に加えて追加
INSERT INTO customers (customer_id, name, profile_data) VALUES
(6, '中村優子', '{"age": 42, "gender": "female", "hobbies": ["ワイン", "料理", "ガーデニング"], "occupation": "料理研究家"}'),
(7, '木村達也', '{"age": 38, "gender": "male", "hobbies": ["テニス", "時計収集"], "occupation": "銀行員"}'),
(8, '斎藤美穂', '{"age": 29, "gender": "female", "hobbies": ["ファッション", "スイーツ巡り"], "occupation": "会社員"}'),
(9, '高橋純平', '{"age": 45, "gender": "male", "hobbies": ["ゴルフ", "ワイン"], "occupation": "弁護士"}'),
(10, '伊藤さくら', '{"age": 31, "gender": "female", "hobbies": ["アウトドア", "カメラ"], "occupation": "フリーランス"}');

-- 既存の商品に加えて追加
INSERT INTO products (product_id, name, category_id, attributes) VALUES
(6, '限定版腕時計X', 1, '{"color": "gold", "material": "18k gold", "water_resistant": true}'),
(7, 'トートバッグP', 2, '{"color": "brown", "material": "canvas", "size": "large"}'),
(8, '高級茶葉セットM', 3, '{"type": "premium", "contents": ["緑茶", "紅茶", "烏龍茶"], "weight": "300g"}'),
(9, 'コレクターズワインR', 4, '{"origin": "Italy", "year": 2010, "type": "red"}'),
(10, 'スマートウォッチY', 5, '{"color": "silver", "warranty": "1year", "features": ["心拍計", "睡眠計測"]}');

-- 追加の注文データ（より多様な購買パターン）
INSERT INTO orders (order_id, customer_id, order_date, total_amount, order_details) VALUES
-- 木村達也（頻繁な高額購入）
(12, 7, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 10 DAY), 450000.00, '{"payment": "credit_card", "shipping": "express"}'),
(13, 7, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 40 DAY), 380000.00, '{"payment": "credit_card", "shipping": "express"}'),
(14, 7, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 70 DAY), 290000.00, '{"payment": "credit_card", "shipping": "express"}'),

-- 斎藤美穂（定期的な中額購入）
(15, 8, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 15 DAY), 85000.00, '{"payment": "credit_card", "shipping": "normal"}'),
(16, 8, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 45 DAY), 92000.00, '{"payment": "credit_card", "shipping": "normal"}'),
(17, 8, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 75 DAY), 78000.00, '{"payment": "credit_card", "shipping": "normal"}'),

-- 高橋純平（高額不定期購入）
(18, 9, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 20 DAY), 580000.00, '{"payment": "bank_transfer", "shipping": "express"}'),
(19, 9, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 180 DAY), 420000.00, '{"payment": "bank_transfer", "shipping": "express"}'),

-- 伊藤さくら（小額頻繁購入）
(20, 10, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 5 DAY), 25000.00, '{"payment": "credit_card", "shipping": "normal"}'),
(21, 10, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 25 DAY), 32000.00, '{"payment": "convenience_store", "shipping": "normal"}'),
(22, 10, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 45 DAY), 28000.00, '{"payment": "credit_card", "shipping": "normal"}'),

-- 中村優子（食品・ワイン中心の定期購入）
(23, 6, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 8 DAY), 125000.00, '{"payment": "credit_card", "shipping": "normal"}'),
(24, 6, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 38 DAY), 98000.00, '{"payment": "credit_card", "shipping": "normal"}'),
(25, 6, DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 68 DAY), 145000.00, '{"payment": "credit_card", "shipping": "normal"}');

-- 追加の注文明細
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
-- 木村達也の注文（時計とワイン中心）
(12, 6, 1, 350000.00),
(12, 9, 2, 50000.00),
(13, 1, 1, 250000.00),
(13, 4, 2, 65000.00),
(14, 6, 1, 290000.00),

-- 斎藤美穂の注文（バッグとガジェット中心）
(15, 7, 1, 55000.00),
(15, 10, 1, 30000.00),
(16, 2, 1, 92000.00),
(17, 7, 1, 48000.00),
(17, 5, 1, 30000.00),

-- 高橋純平の注文（高級時計とワイン）
(18, 6, 1, 350000.00),
(18, 9, 4, 57500.00),
(19, 1, 1, 250000.00),
(19, 4, 4, 42500.00),

-- 伊藤さくらの注文（食品とガジェット中心）
(20, 8, 2, 12500.00),
(21, 10, 1, 32000.00),
(22, 3, 2, 14000.00),

-- 中村優子の注文（食品とワイン中心）
(23, 4, 1, 75000.00),
(23, 8, 5, 10000.00),
(24, 3, 4, 15500.00),
(24, 9, 1, 36000.00),
(25, 4, 2, 42500.00),
(25, 8, 6, 10000.00);

