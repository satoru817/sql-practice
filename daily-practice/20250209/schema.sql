-- 商品テーブル
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2)
);

-- レビューテーブル
CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT,
    review_date TIMESTAMP,
    content TEXT,
    meta_data JSON,  -- レビュー関連のメタデータ（デバイス情報、購入確認情報など）
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 商品データの挿入
INSERT INTO products (product_id, name, category_id, price) VALUES
(1, 'ワイヤレスイヤホン', 1, 15000),
(2, 'スマートウォッチ', 1, 25000),
(3, '防水スピーカー', 1, 8000),
(4, 'バックパック', 2, 12000),
(5, 'ランニングシューズ', 3, 9800),
(6, 'ヨガマット', 3, 3000),
(7, '保温水筒', 4, 4500),
(8, 'ノイズキャンセリングヘッドホン', 1, 28000),
(9, 'スポーツサングラス', 3, 15000),
(10, 'ワイヤレス充電器', 1, 5000);

-- レビューデータの挿入
INSERT INTO reviews (review_id, product_id, user_id, rating, review_date, content, meta_data) VALUES
-- ワイヤレスイヤホン のレビュー
(1, 1, 101, 5, '2024-01-01 10:00:00', '音質が素晴らしい',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'mobile', 'os', 'iOS', 'version', '15.0'),
        'verified_purchase', true,
        'photos', JSON_ARRAY('photo1.jpg', 'photo2.jpg'),
        'helpful_votes', 5,
        'tags', JSON_ARRAY('sound_quality', 'comfortable', 'good_battery')
    )),
(2, 1, 102, 4, '2024-01-02 11:00:00', 'バッテリーの持ちが良い',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'desktop', 'os', 'Windows', 'version', '11'),
        'verified_purchase', true,
        'photos', JSON_ARRAY(),
        'helpful_votes', 3,
        'tags', JSON_ARRAY('good_battery', 'good_value')
    )),
(3, 1, 103, 5, '2024-01-03 12:00:00', '装着感が快適',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'mobile', 'os', 'Android', 'version', '13'),
        'verified_purchase', true,
        'photos', JSON_ARRAY('photo3.jpg'),
        'helpful_votes', 7,
        'tags', JSON_ARRAY('comfortable', 'good_quality')
    )),

-- スマートウォッチ のレビュー
(4, 2, 104, 3, '2024-01-04 13:00:00', 'バッテリーがイマイチ',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'mobile', 'os', 'iOS', 'version', '16.0'),
        'verified_purchase', true,
        'photos', JSON_ARRAY('photo4.jpg'),
        'helpful_votes', 10,
        'tags', JSON_ARRAY('battery_issue', 'expensive')
    )),
(5, 2, 105, 5, '2024-01-05 14:00:00', '機能が充実している',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'mobile', 'os', 'Android', 'version', '12'),
        'verified_purchase', false,
        'photos', JSON_ARRAY('photo5.jpg', 'photo6.jpg'),
        'helpful_votes', 15,
        'tags', JSON_ARRAY('feature_rich', 'good_quality')
    )),

-- 防水スピーカー のレビュー
(6, 3, 106, 4, '2024-01-06 15:00:00', '防水性能が高い',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'mobile', 'os', 'iOS', 'version', '15.0'),
        'verified_purchase', true,
        'photos', JSON_ARRAY(),
        'helpful_votes', 8,
        'tags', JSON_ARRAY('waterproof', 'good_sound', 'portable')
    )),

-- バックパック のレビュー
(7, 4, 107, 5, '2024-01-07 16:00:00', '収納力抜群',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'mobile', 'os', 'Android', 'version', '13'),
        'verified_purchase', true,
        'photos', JSON_ARRAY('photo7.jpg'),
        'helpful_votes', 20,
        'tags', JSON_ARRAY('spacious', 'good_quality', 'comfortable')
    )),

-- ランニングシューズ のレビュー
(8, 5, 108, 4, '2024-01-08 17:00:00', 'クッション性が良い',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'mobile', 'os', 'iOS', 'version', '16.0'),
        'verified_purchase', true,
        'photos', JSON_ARRAY('photo8.jpg', 'photo9.jpg'),
        'helpful_votes', 12,
        'tags', JSON_ARRAY('comfortable', 'good_quality', 'size_fits')
    )),

-- ノイズキャンセリングヘッドホン のレビュー
(9, 8, 109, 5, '2024-01-09 18:00:00', 'ノイズキャンセリングが素晴らしい',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'desktop', 'os', 'Windows', 'version', '10'),
        'verified_purchase', true,
        'photos', JSON_ARRAY('photo10.jpg'),
        'helpful_votes', 25,
        'tags', JSON_ARRAY('noise_cancelling', 'sound_quality', 'comfortable')
    )),
(10, 8, 110, 4, '2024-01-10 19:00:00', '音質は良いが少し重い',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'mobile', 'os', 'Android', 'version', '12'),
        'verified_purchase', true,
        'photos', JSON_ARRAY(),
        'helpful_votes', 18,
        'tags', JSON_ARRAY('sound_quality', 'bit_heavy')
    )),

-- 追加のレビュー
(11, 1, 111, 4, '2024-01-11 20:00:00', '良い買い物でした',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'mobile', 'os', 'iOS', 'version', '15.0'),
        'verified_purchase', true,
        'photos', JSON_ARRAY(),
        'helpful_votes', 3,
        'tags', JSON_ARRAY('good_value', 'good_quality')
    )),
(12, 2, 112, 4, '2024-01-12 21:00:00', 'デザインが気に入りました',
    JSON_OBJECT(
        'device', JSON_OBJECT('type', 'mobile', 'os', 'Android', 'version', '13'),
        'verified_purchase', true,
        'photos', JSON_ARRAY('photo11.jpg'),
        'helpful_votes', 7,
        'tags', JSON_ARRAY('good_design', 'comfortable')
    ));
