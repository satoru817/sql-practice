はい、SQLの学習進捗を確認させていただきました。RFM分析とJSON処理を組み合わせた、実践的なECサイトのデータ分析の問題を出題させていただきます。

以下のテーブル構造で、顧客の購買行動とプロファイルデータを分析する問題です：


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


問題：以下の分析を行うSQLクエリを作成してください。

1. 各顧客のRFMスコアを計算し、以下の情報を含むJSONとして出力してください：
   - 最終購入日（Recency）
   - 購入頻度（Frequency）
   - 総購入金額（Monetary）
   - 購入した商品カテゴリの分布
   - 顧客の趣味（profile_dataから抽出）

2. 分析結果から以下の条件で顧客をセグメント化してください：
   - VIP：過去3ヶ月以内に購入があり、総購入回数が10回以上、総購入金額が100万円以上
   - 優良顧客：過去6ヶ月以内に購入があり、総購入回数が5回以上、総購入金額が50万円以上
   - 通常顧客：上記以外で過去1年以内に購入がある
   - 離反顧客：1年以上購入がない

注意点：
- 現在の日付は CURRENT_TIMESTAMP を使用
- JSONデータの抽出にはJSON_EXTRACT関数を使用
- 金額はすべて日本円とする
- NULL値の適切な処理を行う

このクエリでは、以下のような新しい要素が含まれています：
- JSON型データの処理
- RFM分析の実装
- 複数の条件による顧客セグメント化
- 日付計算と条件分岐の組み合わせ
- 集計結果のJSON形式での出力
