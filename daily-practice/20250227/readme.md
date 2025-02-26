MySQLの問題を作成します。以下は医療分析以外の、ECサイトの顧客行動分析に関する問題です。

# ECサイトの顧客行動分析問題

あなたはECサイトのデータアナリストです。過去12ヶ月間の購入データを分析して、顧客行動パターンを理解するよう依頼されました。

## テーブル構造

```sql
-- 顧客テーブル
CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  registration_date DATE,
  customer_segment VARCHAR(50),
  total_purchases DECIMAL(10,2)
);

-- 製品テーブル
CREATE TABLE products (
  product_id INT PRIMARY KEY,
  name VARCHAR(100),
  category VARCHAR(50),
  subcategory VARCHAR(50),
  price DECIMAL(10,2)
);

-- 注文テーブル
CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  total_amount DECIMAL(10,2),
  payment_method VARCHAR(50),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 注文明細テーブル
CREATE TABLE order_items (
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  discount DECIMAL(10,2),
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

## 課題

以下の分析を行うためのSQLクエリを書いてください：

1. リピーター分析：2回以上購入している顧客の割合と平均購入金額を月ごとに算出してください。
2. カテゴリクロス購入分析：複数のカテゴリから購入している顧客と単一カテゴリのみから購入している顧客の比較を行ってください。比較項目は顧客数、平均購入額、平均購入頻度です。
3. 顧客生涯価値（LTV）分析：顧客セグメント別の6ヶ月間の累計購入金額を計算し、セグメント間で比較してください。

データ分析の詳細さと解釈可能性を重視したクエリを作成してください。日付関数やウィンドウ関数を適切に活用すると良いでしょう。
