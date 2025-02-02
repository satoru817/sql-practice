以下は同程度の難易度のSQL問題です。実際にデータベースを作成して練習できるよう、完全なテーブル定義と問題文を提供します。

---

### データベース定義（図書館管理システム）
```sql
CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100) NOT NULL,
    genre VARCHAR(50) NOT NULL,
    published_year INT,
    is_available BOOLEAN DEFAULT true
);

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    membership_date DATE NOT NULL,
    membership_status VARCHAR(20) DEFAULT 'active' CHECK (membership_status IN ('active', 'expired', 'suspended'))
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reserve_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'fulfilled', 'cancelled')),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);
```

### 問題文
2023年度の図書館利用状況について、以下の分析を行ってください：

1. 各ジャンルごとに以下の指標を算出：
   - 総貸出数（返却済み＋未返却）
   - 返却遅延率（返却日が返却日より遅れた貸出数 ÷ 総貸出数）
   - 平均貸出期間（返却済みのもののみ、日数単位で小数点以下切り捨て）
   - 予約充足率（予約が実際の貸出に繋がった割合）
   - 会員あたりの平均貸出数（小数点以下第2位四捨五入）

2. レポート要件：
   - ジャンルごとに階層化（主要ジャンルとサブジャンルがあると仮定）
   - 現在利用可能な書籍のみを対象
   - アクティブ会員のみを集計対象
   - 貸出実績がないジャンルも表示
   - パーセンテージは全て小数点以下1桁表示
   - 各ジャンルの指標と、主要ジャンルごとの平均値を併記

### 期待する解答のポイント
1. 複数テーブルの適切な結合（書籍・会員・貸出・予約）
2. 階層化されたジャンルの扱い（自己結合）
3. 期間計算と条件付き集計
4. ゼロ除算の回避
5. 複数レベルの集計（サブジャンルと主要ジャンル）
6. ウィンドウ関数を活用した平均値計算

### 難易度向上要素
- 前年度同時期との比較（貸出数増減率）
- 人気著作者トップ3の特定（ウィンドウ関数使用）
- 貸出パターンの分析（連続貸出日数の算出）
- 予約と貸出の時系列関係分析

```sql
-- 解答例の一部（完全版ではありません）：
WITH genre_hierarchy AS (
    SELECT 
        genre,
        CASE 
            WHEN genre LIKE 'Fiction%' THEN 'Fiction'
            WHEN genre LIKE 'Non-Fiction%' THEN 'Non-Fiction'
            ELSE genre 
        END AS main_genre
    FROM books
    GROUP BY genre
),
loan_stats AS (
    SELECT
        b.genre,
        COUNT(l.loan_id) AS total_loans,
        ...
    FROM books b
    LEFT JOIN loans l ON b.book_id = l.book_id
    LEFT JOIN members m ON l.member_id = m.member_id
    WHERE b.is_available
      AND m.membership_status = 'active'
      AND EXTRACT(YEAR FROM l.loan_date) = 2023
    GROUP BY b.genre
)
...
```

この問題では、階層化されたデータの扱い、複数テーブルの時系列関係分析、条件付き集計など、実務で必要とされる高度なSQLスキルが要求されます。実際の図書館管理システムで必要な分析を想定して設計されています。
