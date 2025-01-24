インデントの統一について、一般的なSQLスタイルガイドに基づいたルールをご説明します。



## SQLインデントの基本ルール

1. 主要キーワードは左端から開始
   - SELECT, FROM, WHERE, GROUP BY, ORDER BY など
   - WITH句の開始も左端から

2. 結合条件は親テーブルより4スペース下げる
   - INNER JOIN, LEFT JOIN など
   - ON句はさらに4スペース下げる

3. 選択列（SELECT句以下）は4スペースでインデント
   - カンマは前置または後置で統一
   - 長い列名は複数行に分けて記述

以下、あなたの問題1のクエリを例にインデントルールを適用してみましょう：


WITH publisher_stats AS (
    SELECT
        p.publisher_id,
        p.publisher_name,
        SUM(oi.quantity * oi.unit_price) AS total_sales,
        SUM(oi.quantity) AS total_quantity
    FROM
        order_details oi
        INNER JOIN books b 
            ON b.book_id = oi.book_id
        INNER JOIN publishers p 
            ON p.publisher_id = b.publisher_id
    GROUP BY
        p.publisher_id,
        p.publisher_name
),
publisher_rank AS (
    SELECT
        ps.*,
        ROUND(ps.total_sales/ps.total_quantity, 1) AS avg_unit_price,
        RANK() OVER (ORDER BY ps.total_sales DESC) AS ranking
    FROM
        publisher_stats ps
)
SELECT
    pr.publisher_name,
    pr.total_sales,
    pr.total_quantity,
    pr.avg_unit_price,
    pr.ranking
FROM 
    publisher_rank pr
ORDER BY
    pr.ranking;


## インデントのポイント解説

1. キーワードの配置
```sql
WITH    -- 左端から開始
SELECT  -- 左端から開始
FROM    -- 左端から開始
GROUP BY-- 左端から開始
```

2. SELECT句内の列指定
```sql
SELECT
    column1,    -- 4スペースインデント
    column2,    -- 揃える
    column3     -- 揃える
```

3. JOIN句の配置
```sql
FROM
    table1
    INNER JOIN table2    -- メインテーブルと同じ位置
        ON condition     -- JOINより4スペース
    INNER JOIN table3    -- 同じレベルで揃える
        ON condition     -- JOINより4スペース
```

4. 条件式や関数
```sql
WHERE
    column1 = value
    AND column2 IN (     -- AND/ORは条件と同じ位置
        select1,
        select2          -- サブクエリは4スペース
    )
```

これらのルールを一貫して適用することで、コードの可読性が大きく向上します。特に：
- 論理的な階層が視覚的に分かりやすくなる
- コードの構造が理解しやすくなる
- メンテナンスが容易になる

実際の開発では、チームで統一したスタイルガイドを決めることが多いですが、上記のルールは広く使われている標準的なものです。SQL整形ツールを使用する場合でも、これらの基本原則を理解しておくと、出力されたコードの意図が理解しやすくなります。
