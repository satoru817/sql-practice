-- 商品カテゴリ
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- 商品マスタ
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    specifications JSON,  -- {is_waterproof: true, has_warranty: true など}
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- ユーザー
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    user_type ENUM('regular', 'premium', 'vip') DEFAULT 'regular'
);

-- 注文
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 注文明細
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- レビュー
CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSON,  -- {verified_purchase: true, platform: "mobile", helpfulness_votes: 5}
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- カテゴリデータの挿入
INSERT INTO categories (category_id, name, parent_category_id) VALUES
(1, 'エレクトロニクス', NULL),
(2, 'スマートフォン', 1),
(3, 'タブレット', 1),
(4, 'ノートパソコン', 1),
(5, 'ファッション', NULL),
(6, 'メンズ', 5),
(7, 'レディース', 5),
(8, '子供服', 5),
(9, 'ホーム&キッチン', NULL),
(10, '家具', 9),
(11, '調理器具', 9),
(12, '家電', 9);

-- 商品データの挿入
INSERT INTO products (product_id, name, category_id, price, cost, stock_quantity, is_active, specifications) VALUES
(101, 'プレミアムスマートフォン', 2, 99800, 65000, 120, TRUE, '{"is_waterproof": true, "has_warranty": true, "color": "black", "memory": "128GB"}'),
(102, 'スタンダードスマートフォン', 2, 49800, 30000, 250, TRUE, '{"is_waterproof": false, "has_warranty": true, "color": "white", "memory": "64GB"}'),
(103, 'エコノミースマートフォン', 2, 29800, 18000, 180, TRUE, '{"is_waterproof": false, "has_warranty": true, "color": "blue", "memory": "32GB"}'),
(104, 'プロフェッショナルタブレット', 3, 89800, 55000, 85, TRUE, '{"is_waterproof": false, "has_warranty": true, "screen_size": "12.9inch", "memory": "256GB"}'),
(105, 'スタンダードタブレット', 3, 59800, 35000, 120, TRUE, '{"is_waterproof": false, "has_warranty": true, "screen_size": "10.2inch", "memory": "128GB"}'),
(106, 'ハイエンドノートPC', 4, 198000, 140000, 45, TRUE, '{"is_waterproof": false, "has_warranty": true, "cpu": "Core i9", "memory": "32GB"}'),
(107, 'ビジネスノートPC', 4, 128000, 85000, 75, TRUE, '{"is_waterproof": false, "has_warranty": true, "cpu": "Core i7", "memory": "16GB"}'),
(108, 'スタンダードノートPC', 4, 89800, 55000, 110, TRUE, '{"is_waterproof": false, "has_warranty": true, "cpu": "Core i5", "memory": "8GB"}'),
(109, 'メンズジャケット', 6, 19800, 8000, 65, TRUE, '{"is_waterproof": true, "size": "M,L,XL", "color": "black,navy"}'),
(110, 'メンズデニムパンツ', 6, 8900, 3500, 120, TRUE, '{"is_waterproof": false, "size": "S,M,L,XL", "color": "blue,black"}'),
(111, 'レディースコート', 7, 24800, 10000, 55, TRUE, '{"is_waterproof": true, "size": "S,M,L", "color": "beige,black"}'),
(112, 'レディースカーディガン', 7, 7900, 3000, 95, TRUE, '{"is_waterproof": false, "size": "S,M,L", "color": "pink,white,gray"}'),
(113, '子供用レインジャケット', 8, 5900, 2200, 75, TRUE, '{"is_waterproof": true, "size": "100,110,120,130", "color": "yellow,blue"}'),
(114, '子供用Tシャツ', 8, 2900, 1000, 150, TRUE, '{"is_waterproof": false, "size": "100,110,120,130,140", "color": "red,blue,green"}'),
(115, 'ソファーセット', 10, 129800, 75000, 20, TRUE, '{"is_waterproof": false, "has_warranty": true, "material": "leather", "color": "brown,black"}'),
(116, 'ダイニングテーブル', 10, 79800, 45000, 35, TRUE, '{"is_waterproof": false, "has_warranty": true, "material": "wood", "color": "brown,white"}'),
(117, '電気圧力鍋', 11, 19800, 9000, 85, TRUE, '{"is_waterproof": true, "has_warranty": true, "capacity": "5.5L"}'),
(118, 'フライパンセット', 11, 12800, 5500, 120, TRUE, '{"is_waterproof": false, "has_warranty": true, "material": "stainless"}'),
(119, '大型冷蔵庫', 12, 128000, 80000, 30, TRUE, '{"is_waterproof": false, "has_warranty": true, "capacity": "500L", "color": "silver,black"}'),
(120, '全自動洗濯機', 12, 89800, 55000, 40, TRUE, '{"is_waterproof": true, "has_warranty": true, "capacity": "10kg", "color": "white"}');

-- ユーザーデータの挿入
INSERT INTO users (user_id, name, email, created_at, last_login, user_type) VALUES
(1001, '田中健太', 'tanaka@example.com', '2024-01-05 10:20:30', '2024-02-15 18:30:15', 'premium'),
(1002, '佐藤美咲', 'sato@example.com', '2024-01-08 09:15:45', '2024-02-14 20:45:10', 'regular'),
(1003, '鈴木一郎', 'suzuki@example.com', '2024-01-10 14:30:00', '2024-02-16 12:10:30', 'regular'),
(1004, '伊藤花子', 'ito@example.com', '2024-01-12 11:25:35', '2024-02-13 22:05:40', 'vip'),
(1005, '渡辺拓也', 'watanabe@example.com', '2024-01-15 16:40:20', '2024-02-12 08:55:25', 'regular'),
(1006, '加藤夏希', 'kato@example.com', '2024-01-18 13:10:15', '2024-02-15 15:30:50', 'premium'),
(1007, '山田太郎', 'yamada@example.com', '2024-01-20 10:05:30', '2024-02-14 19:40:15', 'regular'),
(1008, '中村綾', 'nakamura@example.com', '2024-01-22 15:50:45', '2024-02-13 21:25:30', 'regular'),
(1009, '小林誠', 'kobayashi@example.com', '2024-01-25 12:35:10', '2024-02-16 11:15:45', 'premium'),
(1010, '吉田優子', 'yoshida@example.com', '2024-01-28 09:20:25', '2024-02-15 17:00:20', 'vip'),
(1011, '高橋健', 'takahashi@example.com', '2024-02-01 14:15:40', '2024-02-14 13:50:35', 'regular'),
(1012, '松本さくら', 'matsumoto@example.com', '2024-02-03 11:00:55', '2024-02-13 10:40:50', 'regular'),
(1013, '井上大輔', 'inoue@example.com', '2024-02-05 17:45:10', '2024-02-16 23:30:15', 'premium'),
(1014, '木村真理子', 'kimura@example.com', '2024-02-08 08:30:25', '2024-02-15 16:20:30', 'regular'),
(1015, '斎藤雄大', 'saito@example.com', '2024-02-10 13:25:40', '2024-02-14 09:10:45', 'vip');

-- 注文データの挿入
INSERT INTO orders (order_id, user_id, order_date, status, total_amount) VALUES
(10001, 1001, '2024-01-10 14:25:30', 'completed', 99800),
(10002, 1002, '2024-01-11 10:15:45', 'completed', 49800),
(10003, 1004, '2024-01-12 16:30:00', 'completed', 148000),
(10004, 1001, '2024-01-15 11:20:15', 'completed', 19800),
(10005, 1003, '2024-01-16 09:45:30', 'completed', 89800),
(10006, 1005, '2024-01-18 13:10:45', 'completed', 32700),
(10007, 1006, '2024-01-20 15:55:00', 'completed', 138700),
(10008, 1002, '2024-01-22 10:40:15', 'cancelled', 89800),
(10009, 1007, '2024-01-23 14:25:30', 'completed', 29800),
(10010, 1004, '2024-01-25 09:10:45', 'completed', 209600),
(10011, 1008, '2024-01-26 16:35:00', 'completed', 28700),
(10012, 1009, '2024-01-28 12:20:15', 'completed', 198000),
(10013, 1010, '2024-01-30 10:05:30', 'completed', 248600),
(10014, 1001, '2024-02-01 15:50:45', 'completed', 89800),
(10015, 1011, '2024-02-03 11:35:00', 'completed', 19800),
(10016, 1012, '2024-02-04 09:20:15', 'completed', 79800),
(10017, 1005, '2024-02-05 13:05:30', 'completed', 49800),
(10018, 1013, '2024-02-07 16:50:45', 'completed', 217800),
(10019, 1014, '2024-02-08 10:35:00', 'pending', 12800),
(10020, 1015, '2024-02-10 14:20:15', 'completed', 257800),
(10021, 1001, '2024-02-12 09:05:30', 'completed', 59800),
(10022, 1010, '2024-02-13 15:50:45', 'completed', 128000),
(10023, 1003, '2024-02-14 11:35:00', 'completed', 24800),
(10024, 1006, '2024-02-15 09:20:15', 'pending', 19800);

-- 注文明細データの挿入
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(10001, 101, 1, 99800),
(10002, 102, 1, 49800),
(10003, 106, 1, 148000),
(10004, 109, 1, 19800),
(10005, 108, 1, 89800),
(10006, 110, 2, 8900),
(10006, 114, 5, 2900),
(10007, 115, 1, 129800),
(10007, 109, 0.45, 19800),
(10008, 108, 1, 89800),
(10009, 103, 1, 29800),
(10010, 101, 1, 99800),
(10010, 104, 1, 89800),
(10010, 118, 1, 12800),
(10010, 109, 0.36, 19800),
(10011, 112, 2, 7900),
(10011, 114, 4.45, 2900),
(10012, 106, 1, 198000),
(10013, 104, 1, 89800),
(10013, 120, 1, 89800),
(10013, 111, 1, 24800),
(10013, 117, 1, 19800),
(10013, 114, 8.34, 2900),
(10014, 105, 1, 59800),
(10014, 108, 1, 0), -- フリーギフト
(10015, 109, 1, 19800),
(10016, 116, 1, 79800),
(10017, 102, 1, 49800),
(10018, 107, 1, 128000),
(10018, 111, 1, 24800),
(10018, 117, 1, 19800),
(10018, 118, 1, 12800),
(10018, 114, 11.03, 2900),
(10019, 118, 1, 12800),
(10020, 119, 1, 128000),
(10020, 107, 1, 128000),
(10020, 109, 0.09, 19800),
(10021, 105, 1, 59800),
(10022, 107, 1, 128000),
(10023, 111, 1, 24800),
(10024, 117, 1, 19800);

-- レビューデータの挿入
INSERT INTO reviews (review_id, product_id, user_id, rating, comment, review_date, metadata) VALUES
(1, 101, 1001, 5, '期待通りの最高のスマートフォンです！', '2024-01-15 10:20:30', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 12}'),
(2, 102, 1002, 4, '価格を考えれば十分な性能です。', '2024-01-16 15:45:20', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 8}'),
(3, 106, 1004, 5, '仕事が捗る素晴らしいノートPCです。', '2024-01-17 09:30:15', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 15}'),
(4, 109, 1001, 4, 'デザインも良く、防水性能も確かです。', '2024-01-20 14:25:40', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 6}'),
(5, 108, 1003, 3, '基本性能は良いが、バッテリーがやや持たない。', '2024-01-21 11:10:35', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 9}'),
(6, 110, 1005, 5, 'サイズ感も良く、履き心地最高です！', '2024-01-23 16:55:50', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 7}'),
(7, 114, 1005, 4, '子供が喜んで着ています。', '2024-01-23 17:00:25', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 4}'),
(8, 115, 1006, 5, 'リビングが一気に高級感が出ました。', '2024-01-25 10:35:20', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 11}'),
(9, 103, 1007, 4, 'コスパ最高のスマートフォンです。', '2024-01-28 09:20:15', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 6}'),
(10, 101, 1004, 5, '写真の画質が特に素晴らしいです。', '2024-01-30 15:40:30', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 14}'),
(11, 104, 1004, 4, '画面が綺麗で使いやすいです。', '2024-01-30 15:50:45', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 8}'),
(12, 112, 1008, 5, '肌触りが良く、デザインも気に入っています。', '2024-01-31 12:15:10', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 5}'),
(13, 106, 1009, 5, '仕事用に購入しましたが大満足です。', '2024-02-02 08:30:25', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 13}'),
(14, 104, 1010, 4, '持ち運びに便利で画面も綺麗です。', '2024-02-03 14:25:40', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 7}'),
(15, 105, 1001, 4, '子どもの勉強用に最適です。', '2024-02-05 10:10:35', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 9}'),
(16, 109, 1011, 5, '防水性能が素晴らしく、雨の日も安心です。', '2024-02-07 16:55:50', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 6}'),
(17, 116, 1012, 4, '組み立ては少し大変でしたが、出来上がりは満足です。', '2024-02-08 11:40:15', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 8}'),
(18, 102, 1005, 4, '2台目として購入しましたが、コスパ良いです。', '2024-02-09 09:25:30', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 5}'),
(19, 107, 1013, 5, 'ビジネス用として最高のパフォーマンスです。', '2024-02-11 14:20:45', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 12}'),
(20, 118, 1013, 4, '使いやすく、お手入れも簡単です。', '2024-02-11 14:30:10', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 7}'),
(21, 119, 1015, 5, '大容量で家族全員の食材が余裕で入ります。', '2024-02-14 10:15:25', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 9}'),
(22, 111, 1003, 4, 'デザインも良く、保温性も高いです。', '2024-02-18 15:40:50', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 6}'),
(23, 117, 1006, 5, '料理の時短になり、大変重宝しています。', '2024-02-19 11:25:15', '{"verified_purchase": true, "platform": "mobile", "helpfulness_votes": 11}'),
(24, 102, 1014, 3, '概ね満足ですが、バッテリーの持ちが想像より短いです。', '2024-02-12 09:10:30', '{"verified_purchase": false, "platform": "desktop", "helpfulness_votes": 4}'),
(25, 107, 1010, 5, '仕事効率が格段に上がりました。', '2024-02-17 14:35:55', '{"verified_purchase": true, "platform": "desktop", "helpfulness_votes": 10}');p
