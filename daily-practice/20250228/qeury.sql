-- 1. 製品ごとに以下の情報を含むレポートを作成してください：
--    - 製品名
--    - カテゴリ
--    - 全体評価の平均スコア
--    - 検証済み購入のレビュー数（verified_purchase = true）
--    - 各使用コンテキスト（usage_context）の数（例：「家庭での使用」の数）
--    - 最も高いスコアを持つ詳細評価の側面（aspect）

WITH basic_product_stats AS (
	SELECT
		p.product_id,
		p.name AS product_name,
		p.category,
		ROUND(
			AVG(
				r.review_data->>'$.overall_rating'
			)
		) AS avg_overall_rating,
		COUNT(
			CASE 
				WHEN r.review_data->'$.verified_purchase' THEN 1
			END
		) AS verified_purchases
	FROM
		products p
		INNER JOIN reviews r ON r.product_id = p.product_id
	GROUP BY
		p.product_id,
		p.name,
		p.category
),
product_context_stats AS(
	SELECT
		p.product_id,
		COUNT(DISTINCT jt.context) AS contexts
	FROM
		products p
		INNER JOIN reviews r ON r.product_id = p.product_id
		INNER JOIN JSON_TABLE(
			r.review_data->'$.usage_context','$[*]'
			COLUMNS(
				context VARCHAR(50) PATH '$'
			)
		) AS jt
	GROUP BY
		p.product_id
),
product_aspect_stats AS(
	SELECT
		p.product_id,
		dr.aspect,
		AVG(dr.score) AS avg_score
	FROM
		products p
		INNER JOIN reviews r ON r.product_id = p.product_id
		INNER JOIN JSON_TABLE(
			r.review_data->'$.detailed_ratings','$[*]'
			COLUMNS(
				aspect VARCHAR(50) PATH '$.aspect',
				score INT PATH '$.score'
			)
		) AS dr
	GROUP BY
		p.product_id,
		dr.aspect
),
product_aspect_ranks AS (
	SELECT
		product_id,
		aspect,
		RANK() OVER (PARTITION BY product_id ORDER BY avg_score DESC) AS rank_in_product
	FROM
		product_aspect_stats
),
product_top_aspects AS (
	SELECT
		product_id,
		GROUP_CONCAT(aspect ORDER BY aspect SEPARATOR ',') AS top_aspects
	FROM
		product_aspect_ranks
	WHERE
		rank_in_product = 1
	GROUP BY
		product_id
)
SELECT
	bps.product_name,
	bps.category,
	bps.avg_overall_rating,
	bps.verified_purchases,
	pcs.contexts,
	pta.top_aspects
FROM
	basic_product_stats bps
	LEFT JOIN product_context_stats pcs ON pcs.product_id = bps.product_id
	LEFT JOIN product_top_aspects pta ON pta.product_id = pcs.product_id;
--実行結果

|product_name                        |category   |avg_overall_rating|verified_purchases|contexts|top_aspects                     |
|------------------------------------|-----------|------------------|------------------|--------|--------------------------------|
|Ultra HD Smart TV 50"               |Electronics|4                 |3                 |2       |quality                         |
|Wireless Noise-Cancelling Headphones|Electronics|4                 |2                 |3       |comfort,usability               |
|Professional Chef Knife Set         |Kitchen    |5                 |2                 |2       |quality,sharpness               |
|Ergonomic Office Chair              |Furniture  |4                 |2                 |3       |comfort                         |
|Smart Fitness Tracker               |Wearables  |3                 |2                 |2       |accuracy                        |
|Portable Bluetooth Speaker          |Electronics|5                 |1                 |4       |quality                         |
|Organic Cotton Bed Sheets           |Home       |5                 |1                 |2       |comfort,durability,quality,value|
|Stainless Steel Water Bottle        |Kitchen    |4                 |1                 |4       |leak-proof,quality              |
|Wireless Gaming Mouse               |Electronics|5                 |1                 |2       |quality,responsiveness,usability|
|Indoor Plant Collection             |Home       |4                 |2                 |3       |appearance,health               |



