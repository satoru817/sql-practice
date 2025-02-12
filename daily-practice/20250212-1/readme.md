はい、受注データの分析に関する問題を作成します。

```sql
-- schema.sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    delivery_status JSON NOT NULL,  -- 配送状況の履歴
    order_details JSON NOT NULL,    -- 注文の詳細情報
    total_amount DECIMAL(10,2) NOT NULL
);

CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE shipping_addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    prefecture VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    is_default BOOLEAN DEFAULT false
);
```

```sql
-- data.sql
INSERT INTO shipping_addresses (address_id, user_id, prefecture, city, is_default) VALUES
(1, 1, '東京都', '渋谷区', true),
(2, 1, '神奈川県', '横浜市', false),
(3, 2, '大阪府', '大阪市', true),
(4, 3, '福岡県', '福岡市', true);

INSERT INTO orders (order_id, user_id, order_date, delivery_status, order_details, total_amount) VALUES
(1, 1, '2024-02-01 10:00:00', 
   '{"status": "delivered", "history": [
        {"status": "ordered", "timestamp": "2024-02-01 10:00:00"},
        {"status": "shipped", "timestamp": "2024-02-02 15:00:00"},
        {"status": "delivered", "timestamp": "2024-02-03 14:00:00"}
    ]}',
   '{"payment_method": "credit_card", "shipping_type": "normal", "gift": false}',
   25800),
(2, 2, '2024-02-05 11:30:00',
   '{"status": "shipped", "history": [
        {"status": "ordered", "timestamp": "2024-02-05 11:30:00"},
        {"status": "shipped", "timestamp": "2024-02-06 13:00:00"}
    ]}',
   '{"payment_method": "convenience_store", "shipping_type": "express", "gift": true}',
   89800),
(3, 1, '2024-02-10 15:45:00',
   '{"status": "ordered", "history": [
        {"status": "ordered", "timestamp": "2024-02-10 15:45:00"}
    ]}',
   '{"payment_method": "credit_card", "shipping_type": "normal", "gift": false}',
   12800);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 4, 2, 12900),
(2, 1, 1, 89800),
(3, 4, 1, 12800);
```

問題：
ECサイトの受注データから以下の情報を抽出してください：

1. 各注文について以下の情報を取得：
   - 注文ID
   - 注文日時（YYYY-MM-DD HH:mm形式）
   - 配送先都道府県
   - 配送先市区町村
   - 商品名（複数ある場合はカンマ区切り）
   - 注文ステータス（delivery_status->'$.status'）
   - 配送タイプ（order_details->'$.shipping_type'）
   - ギフトフラグ（order_details->'$.gift'）

2. 以下の条件で抽出：
   - 2024年2月の注文のみ
   - 配送先は各ユーザーのデフォルト住所を使用
   - 商品名は価格の高い順で連結

3. 結果は以下の順でソート：
   - 注文日時の降順
   - 注文IDの降順

ヒント：
- GROUP_CONCATで商品名を連結
- JSONデータの抽出には -> や ->> を使用
- デフォルト住所の結合にはJOINの条件を工夫
