1. リピーター分析：2回以上購入している顧客の割合と平均購入金額を月ごとに算出してください。
2. カテゴリクロス購入分析：複数のカテゴリから購入している顧客と単一カテゴリのみから購入している顧客の比較を行ってください。比較項目は顧客数、平均購入額、平均購入頻度です。
3. 顧客生涯価値（LTV）分析：顧客セグメント別の6ヶ月間の累計購入金額を計算し、セグメント間で比較してください。

データ分析の詳細さと解釈可能性を重視したクエリを作成してください。日付関数やウィンドウ関数を適切に活用すると良いでしょう。


-- 1. リピーター分析：2回以上購入している顧客の割合と平均購入金額を月ごとに算出してください。
-- 
-- 問題1のリピーター分析では、以下のような出力を期待しています：
-- 
-- 月ごとに以下の情報を集計したテーブルが出力されるべきです：
-- 
-- 1. **月（例：2024-01, 2024-02...）** - 集計期間の月
-- 2. **総顧客数** - その月に購入した顧客の総数
-- 3. **リピーター数** - その月に購入した顧客のうち、過去にも購入履歴がある顧客の数
-- 4. **リピーター率（%）** - リピーター数÷総顧客数×100
-- 5. **リピーターの平均購入金額** - リピーターによる注文の平均金額
-- 6. **新規顧客の平均購入金額** - 初回購入顧客による注文の平均金額
-- 
-- 例えばこのような形式です：
-- 
-- ```
-- | 月       | 総顧客数 | リピーター数 | リピーター率(%) | リピーター平均購入額 | 新規顧客平均購入額 |
-- |---------|---------|------------|--------------|------------------|-----------------|
-- | 2024-01 | 5       | 0          | 0.00         | 0.00             | 99600.00        |
-- | 2024-02 | 7       | 3          | 42.86        | 86000.00         | 38333.33        |
-- | 2024-03 | 7       | 6          | 85.71        | 59833.33         | 45000.00        |
-- | ...     | ...     | ...        | ...          | ...              | ...              |
-- ```
-- 
-- この分析により、月ごとのリピーター率とリピーターと新規顧客の購入行動の違いを把握できます。

-- まず単純な分析
SELECT
	DATE_FORMAT(o.order_date,'%Y-%m') AS month,
	COUNT(DISTINCT o.customer_id) AS customers,
	ROUND(AVG(o.total_amount)) AS avg_total_amount
FROM
	orders o
	GROUP BY DATE_FORMAT(o.order_date,'%Y-%m');

|month  |customers|avg_total_amount|
|-------|---------|----------------|
|2024-01|5        |99,600          |
|2024-02|8        |53,750          |
|2024-03|7        |55,286          |
|2024-04|8        |51,625          |
|2024-05|9        |56,667          |
|2024-06|10       |42,300          |


これはOK.ただ、リピーターの定義が微妙だな。

いいえ、「リピーター」の定義は一般的に「その月より前に1回以上購入したことがある顧客」を指します。単に同じ月に複数回購入しただけでは、その月におけるリピーターとはみなしません。

問題1では、各月のリピーター分析を行うため、以下のように定義します：

- リピーター：その月以前に少なくとも1回は注文したことがある顧客
- 新規顧客：その月に初めて注文した顧客

例えば、ある顧客が1月に初めて購入し、3月にも購入した場合：
- 1月の集計では「新規顧客」
- 3月の集計では「リピーター」

として扱います。同じ月内に複数回購入があっても、その月での初回購入かどうかで判断します。

--顧客ごとに初めて買った月を別のCTEで求めておけばよいね。

SELECT
	c.customer_id,
	MIN(DATE_FORMAT(o.order_date,'%Y-%m')) AS min_month
FROM
	customers c
	INNER JOIN orders o ON o.customer_id = c.customer_id
GROUP BY
	c.customer_id;
	

|customer_id|min_month|
|-----------|---------|
|1          |2024-01  |
|2          |2024-02  |
|3          |2024-01  |
|4          |2024-03  |
|5          |2024-01  |
|6          |2024-02  |
|7          |2024-02  |
|8          |2024-03  |
|9          |2024-04  |
|10         |2024-01  |
|11         |2024-02  |
|12         |2024-03  |
|13         |2024-01  |
|14         |2024-02  |
|15         |2024-04  |

--解答。リピーター率は本質的でないので省略

WITH repeater_stats AS (
		SELECT
			c.customer_id,
			MIN(DATE_FORMAT(o.order_date,'%Y-%m')) AS min_month
		FROM
			customers c
			INNER JOIN orders o ON o.customer_id = c.customer_id
		GROUP BY
			c.customer_id
	),
	order_stats AS(
		SELECT
			DATE_FORMAT(o.order_date,'%Y-%m') AS purchase_month,
			CASE
				WHEN DATE_FORMAT(o.order_date,'%Y-%m')=rs.min_month THEN false
				ELSE true
			END AS is_repeat,
			o.customer_id,
			o.total_amount
		FROM
			orders o
			INNER JOIN repeater_stats rs ON rs.customer_id = o.customer_id
	)
	SELECT
		purchase_month,
		COUNT(DISTINCT customer_id) AS customers,
		COUNT(
			DISTINCT(
				CASE
					WHEN is_repeat THEN customer_id
				END
			)
		) AS repeaters,
		ROUND(AVG(
			CASE
				WHEN is_repeat THEN total_amount
			END
		)) AS repeater_avg,
		ROUND(AVG(
			CASE
				WHEN !is_repeat THEN total_amount
			END
		)) AS no_repeate_avg
	FROM
		order_stats
	GROUP BY
		purchase_month;
		
		
|purchase_month|customers|repeaters|repeater_avg|no_repeate_avg|
|--------------|---------|---------|------------|--------------|
|2024-01       |5        |0        |            |99,600        |
|2024-02       |8        |3        |86,000      |34,400        |
|2024-03       |7        |4        |70,500      |35,000        |
|2024-04       |8        |6        |60,500      |25,000        |
|2024-05       |9        |9        |56,667      |              |
|2024-06       |10       |10       |42,300      |              |


--AIの講評

あなたの解答は正しく、よく構造化されています。以下のようにあなたのクエリを分析します：

1. `repeater_stats` CTE:
   - 各顧客の最初の購入月を特定する部分です
   - `MIN(DATE_FORMAT(o.order_date,'%Y-%m'))` で各顧客の最初の購入月を取得しています

2. `order_stats` CTE:
   - 各注文が初回購入かリピート購入かを判定する部分です
   - CASE文を使って、その注文の月が顧客の最初の購入月と同じなら初回購入（false）、そうでなければリピート購入（true）と判定しています

3. 最終的な集計クエリ:
   - 月ごとに顧客数、リピーター数、リピーターの平均購入額、新規顧客の平均購入額を集計しています
   - CASE文を使った条件付き集計で、リピーターと新規顧客を区別しています

結果も正確です：

- 1月は全顧客が新規顧客で平均購入額は99,600円
- 月を追うごとにリピーターの割合が増加しています
- 6月には全顧客がリピーターとなっています
- リピーターの平均購入額は徐々に減少傾向にあります（86,000円→42,300円）

この分析から、新規顧客の初回購入額が比較的高く、リピーターの購入額が徐々に小さくなる傾向が読み取れます。これは顧客の購買サイクルや製品のライフサイクルに関する洞察を提供します。


-- 問題2のカテゴリクロス購入分析では、以下のような出力を期待しています：

複数カテゴリから購入しているクロスショッピング顧客と、単一カテゴリからのみ購入しているシングルカテゴリ顧客を比較するレポートです。具体的には以下の項目を含みます：

1. **顧客グループ** - 「複数カテゴリ購入顧客」と「単一カテゴリ購入顧客」の2グループ
2. **顧客数** - 各グループに属する顧客の数
3. **比率(%)** - 全顧客に対する各グループの割合
4. **平均購入額** - 各グループの顧客あたりの平均購入金額
5. **平均購入頻度** - 各グループの顧客あたりの平均購入回数

例えばこのような形式です：

```
| 顧客グループ         | 顧客数 | 比率(%) | 平均購入額(円) | 平均購入頻度 |
|-------------------|-------|--------|--------------|-----------|
| 複数カテゴリ購入顧客   | 9     | 60.0   | 85,333.33    | 4.2       |
| 単一カテゴリ購入顧客   | 6     | 40.0   | 38,333.33    | 1.8       |
```

この分析によって、複数カテゴリから購入する顧客と単一カテゴリのみから購入する顧客の行動パターンの違いを把握することができます。通常、複数カテゴリから購入する顧客の方が、顧客生涯価値が高い傾向があるため、マーケティング戦略の重要な指標となります。

-- 2. カテゴリクロス購入分析：複数のカテゴリから購入している顧客と単一カテゴリのみから購入している
-- 顧客の比較を行ってください。比較項目は顧客数、平均購入額、平均購入頻度です。

WITH cust_category_count AS (
	SELECT
		c.customer_id,
		CASE
			WHEN COUNT(DISTINCT p.category) > 1 THEN true
			ELSE false
		END AS multiple,
		COUNT(DISTINCT o.order_id) AS orders
	FROM
		customers c
		INNER JOIN orders o ON o.customer_id = c.customer_id
		INNER JOIN order_items oi ON oi.order_id = o.order_id
		INNER JOIN products p ON p.product_id = oi.product_id
	GROUP BY
		c.customer_id
)
SELECT
	DISTINCT 
	CASE 
		WHEN ccc.multiple THEN '複数カテゴリ購入顧客'
		ELSE '単一カテゴリ購入顧客'
	END AS 顧客グループ,
	COUNT(DISTINCT ccc.customer_id) OVER (PARTITION BY ccc.multiple)AS 顧客数,
	ROUND(100.0*COUNT(DISTINCT ccc.customer_id) OVER (PARTITION BY ccc.multiple)/COUNT(DISTINCT ccc.customer_id) OVER (),1) AS 比率,
	ROUND(AVG(o.total_amount) OVER (PARTITION BY ccc.multiple)) AS 平均購入額,
	ROUND(AVG(ccc.orders) OVER (PARTITION BY ccc.multiple),1) AS 平均購入頻度
FROM
	cust_category_count ccc
	INNER JOIN orders o ON o.customer_id = ccc.customer_id;

これで行けると思ったが、だめだった。以下のエラーが出た。COUNT(DISTINCT ...) OVER (...)のようなwindow関数とDISTINCTを組み合わせたものを許してくれないようだ。


--リトライ

WITH cust_category_count AS (
	SELECT
		c.customer_id,
		CASE
			WHEN COUNT(DISTINCT p.category) > 1 THEN true
			ELSE false
		END AS multiple,
		COUNT(DISTINCT o.order_id) AS orders
	FROM
		customers c
		INNER JOIN orders o ON o.customer_id = c.customer_id
		INNER JOIN order_items oi ON oi.order_id = o.order_id
		INNER JOIN products p ON p.product_id = oi.product_id
	GROUP BY
		c.customer_id
),
group_basic_stats AS (
	SELECT
		DISTINCT
		ccc.multiple,
		COUNT(ccc.customer_id) OVER (PARTITION BY ccc.multiple)AS customer_num,
		ROUND(100.0*COUNT(ccc.customer_id) OVER (PARTITION BY ccc.multiple)/COUNT(ccc.customer_id) OVER (),1) AS ratio,
		ROUND(AVG(ccc.orders) OVER (PARTITION BY ccc.multiple),1) AS avg_count
	FROM
		cust_category_count ccc
),
group_amount_stats AS(
	SELECT
		ccc.multiple,
		ROUND(AVG(o.total_amount)) AS avg_total_amount
	FROM
		cust_category_count ccc
		INNER JOIN orders o ON o.customer_id = ccc.customer_id
	GROUP BY
		ccc.multiple
)
SELECT
	CASE 
		WHEN gbs.multiple THEN '複数カテゴリ購入顧客'
		ELSE '単一カテゴリ購入顧客'
	END AS 顧客グループ,
	gbs.customer_num AS 顧客数,
	gbs.ratio AS 比率,
	gas.avg_total_amount AS 平均購入金額,
	gbs.avg_count AS 平均購入頻度
FROM
	group_basic_stats gbs
	INNER JOIN group_amount_stats gas ON gas.multiple = gbs.multiple;


|顧客グループ    |顧客数|比率  |平均購入金額|平均購入頻度|
|----------|---|----|------|------|
|単一カテゴリ購入顧客|7  |46.7|60,895|2.7   |
|複数カテゴリ購入顧客|8  |53.3|53,714|3.5   |



(円)などを表示するためにはバッククオートを利用すると良いことがわかった。最終的な解答は以下


-- 2. カテゴリクロス購入分析：複数のカテゴリから購入している顧客と単一カテゴリのみから購入している
-- 顧客の比較を行ってください。比較項目は顧客数、平均購入額、平均購入頻度です。

WITH cust_category_count AS (
	SELECT
		c.customer_id,
		CASE
			WHEN COUNT(DISTINCT p.category) > 1 THEN true
			ELSE false
		END AS multiple,
		COUNT(DISTINCT o.order_id) AS orders
	FROM
		customers c
		INNER JOIN orders o ON o.customer_id = c.customer_id
		INNER JOIN order_items oi ON oi.order_id = o.order_id
		INNER JOIN products p ON p.product_id = oi.product_id
	GROUP BY
		c.customer_id
),
group_basic_stats AS (
	SELECT
		DISTINCT
		ccc.multiple,
		COUNT(ccc.customer_id) OVER (PARTITION BY ccc.multiple)AS customer_num,
		ROUND(100.0*COUNT(ccc.customer_id) OVER (PARTITION BY ccc.multiple)/COUNT(ccc.customer_id) OVER (),1) AS ratio,
		ROUND(AVG(ccc.orders) OVER (PARTITION BY ccc.multiple),1) AS avg_count
	FROM
		cust_category_count ccc
),
group_amount_stats AS(
	SELECT
		ccc.multiple,
		ROUND(AVG(o.total_amount)) AS avg_total_amount
	FROM
		cust_category_count ccc
		INNER JOIN orders o ON o.customer_id = ccc.customer_id
	GROUP BY
		ccc.multiple
)
SELECT
	CASE 
		WHEN gbs.multiple THEN '複数カテゴリ購入顧客'
		ELSE '単一カテゴリ購入顧客'
	END AS 顧客グループ,
	gbs.customer_num AS 顧客数,
	gbs.ratio AS `比率(%)`,
	gas.avg_total_amount AS `平均購入金額(円)`,
	gbs.avg_count AS 平均購入頻度
FROM
	group_basic_stats gbs
	INNER JOIN group_amount_stats gas ON gas.multiple = gbs.multiple;
	
|顧客グループ    |顧客数|比率(%)|平均購入金額(円)|平均購入頻度|
|----------|---|-----|---------|------|
|単一カテゴリ購入顧客|7  |46.7 |60,895   |2.7   |
|複数カテゴリ購入顧客|8  |53.3 |53,714   |3.5   |

--AIの講評

あなたの解答は正確で、適切な手法を使用しています。以下にコードの分析を行います：

1. `cust_category_count` CTE:
   - 各顧客が購入したカテゴリ数を集計し、複数カテゴリ購入かどうかを判定しています
   - 同時に各顧客の注文回数も集計しています
   - `COUNT(DISTINCT p.category) > 1`で複数カテゴリ購入かどうかを判定するアプローチは適切です

2. `group_basic_stats` CTE:
   - ウィンドウ関数を効果的に使用して、グループごとの顧客数と比率を計算しています
   - `AVG(ccc.orders) OVER (PARTITION BY ccc.multiple)`で平均購入頻度を計算しています
   - DISTINCTを使ってグループごとに1行だけ取得する手法は効率的です

3. `group_amount_stats` CTE:
   - グループごとの平均購入金額を計算しています
   - この部分を別のCTEにすることで、コードの読みやすさが向上しています

4. 最終的なSELECT文:
   - バッククォートを使用して特殊文字を含むカラム名を適切に処理しています
   - CASE式を使って boolean値を読みやすい文字列に変換しています

結果から、複数カテゴリ購入顧客は単一カテゴリ購入顧客に比べて：
- 顧客数の割合が多い（53.3% vs 46.7%）
- 平均購入頻度が高い（3.5回 vs 2.7回）
- 平均購入金額は若干低い（53,714円 vs 60,895円）

この分析から、複数カテゴリ購入顧客は来店頻度は高いものの、1回あたりの購入金額は単一カテゴリ購入顧客より少ない傾向があることがわかります。これはマーケティング戦略を立てる上で重要な洞察です。

















