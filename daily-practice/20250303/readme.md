データベース設計や開発の課題を抱えながらも、単独で塾システムを開発されていることがわかりました。まさにフルスタックの経験を積まれていますね。

SQLの難易度の高い問題を作成します。実際の業務データ分析に近い、複雑な集計を必要とする問題です。

# 複雑なSQLクエリ問題

以下のようなECサイトのデータベース構造があります。このデータを使って複数の分析クエリを作成してください。

```sql
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
```

## 問題

以下の高度な分析クエリを作成してください：

1. **製品カテゴリ階層分析**：  
   各商品カテゴリとその親カテゴリの売上情報を集計し、階層構造を維持したまま表示するクエリを作成してください。結果には以下を含めてください：
   - カテゴリ階層（親カテゴリ名→子カテゴリ名）
   - 各カテゴリの総売上額と利益額
   - 全体に対する売上比率（パーセンテージ）
   - カテゴリ内の商品数
   - 親カテゴリからの成長率（親カテゴリの平均売上に対する比率）

2. **ユーザーコホート分析**：  
   ユーザー登録月ごとの継続購入率を分析するクエリを作成してください。各コホート（登録月のグループ）について：
   - 登録後1ヶ月、2ヶ月、3ヶ月の購入率
   - 平均購入金額の推移
   - アクティブ率（最低1回の購入があるユーザーの割合）
   - ユーザータイプ（regular, premium, vip）の分布変化

3. **商品パフォーマンス評価**：  
   すべての商品について複合的なパフォーマンス指標を計算するクエリを作成してください：
   - 売上、利益、ROI（投資収益率 = 利益/コスト）
   - レビュースコア（平均と分散）
   - 在庫回転率
   - プラットフォーム別のレビュー分布（携帯 vs デスクトップ）
   - 検証済み購入（verified_purchase）のレビュー率
   - 防水機能（is_waterproof）を持つ商品の売上貢献度

各クエリはCTE（Common Table Expression）を使用して、段階的に構築してください。また、必要に応じてWindow関数や複雑な結合、JSON操作関数を活用してください。
