-- 1. 親カテゴリー別の合計売上金額と利益金額を計算し、利益率の高い順に表示してください。
--    - 必要な情報：親カテゴリー名、売上合計、利益合計、利益率（%）
--    - 利益率 = (売上金額 - 原価) / 売上金額 * 100
-- 
-- 2. 各親カテゴリーにおいて、売上金額が上位3位までの商品をカンマ区切りで表示してください。
--    - 必要な情報：親カテゴリー名、売上上位商品名（カンマ区切り）

WITH parent_prod_stats AS (
	SELECT
		pc.name AS parent_category_name,
		pr.name AS product_name,
		SUM(s.quantity*s.unit_price) AS total_sales
	FROM
		sales s
		INNER JOIN products pr ON pr.product_id = s.product_id
		INNER JOIN categories c ON c.category_id = pr.category_id
		INNER JOIN categories pc ON pc.category_id = c.parent_category_id
	GROUP BY
		pc.name,
		pr.name
),
parent_prod_ranks AS (
	SELECT
		parent_category_name,
		product_name,
		RANK() OVER (PARTITION BY parent_category_name ORDER BY total_sales DESC) AS rank_in_parent_category
	FROM
		parent_prod_stats
),
parent_top_sellings AS(
	SELECT
		parent_category_name,
		GROUP_CONCAT(product_name ORDER BY rank_in_parent_category ASC SEPARATOR ',') AS tops
	FROM
		parent_prod_ranks
	WHERE
		rank_in_parent_category <= 3
	GROUP BY parent_category_name
),
parent_stats AS (
	SELECT
		pc.name AS parent_category_name,
		SUM(s.quantity*s.unit_price) AS total_sales,
		SUM(s.quantity*pr.cost) AS total_costs
	FROM 
		sales s
		INNER JOIN products pr ON pr.product_id = s.product_id
		INNER JOIN categories c ON c.category_id = pr.category_id
		INNER JOIN categories pc ON pc.category_id = c.parent_category_id
	GROUP BY
		pc.name
)
SELECT
	ps.parent_category_name,
	ps.total_sales,
	ps.total_sales-ps.total_costs AS total_profit,
	CONCAT(ROUND(100.0*(ps.total_sales-ps.total_costs)/ps.total_sales,2),'%') AS profit_rate,
	pts.tops AS top_selling_products
FROM
	parent_stats ps
	LEFT JOIN parent_top_sellings pts ON pts.parent_category_name = ps.parent_category_name;

--実行結果

|parent_category_name|total_sales|total_profit|profit_rate|top_selling_products         |
|--------------------|-----------|------------|-----------|-----------------------------|
|本・雑誌                |22,800     |11,400      |50.00%     |7つの習慣,データベース実践入門,影響力の武器      |
|電化製品                |375,000    |95,000      |25.33%     |iPhone 14,Galaxy S23,iPad Air|
|文具                  |3,300      |1,650       |50.00%     |Campusノート,マルチペン              |
















