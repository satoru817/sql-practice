-- 1. 防水機能がある商品（specifications.is_waterproof = true）について、カテゴリごとの以下の情報を集計してください：
--    - カテゴリ名
--    - レビュー数
--    - 平均評価（小数点2位で四捨五入）
--    ただし、レビュー数が10件未満のカテゴリは除外し、検証済み購入（metadata.verified_purchase = true）のレビューのみを対象としてください。

--サンプルデータが少ないので、とりあえず、１０件未満のカテゴリを除くという条件を無視。

SELECT
	c.name AS category_name,
	count(r.review_id) AS reviews,
	round(avg(r.rating),2) as avg_rating
FROM
	products p
	INNER JOIN categories c
		ON c.category_id = p.category_id 
		AND JSON_CONTAINS(p.specifications,'{"is_waterproof":true}')
	INNER JOIN reviews r
		ON r.product_id = p.product_id
		AND JSON_CONTAINS(r.metadata,'{"verified_purchase":true}')
GROUP BY
	c.name,
	c.category_id;

--実行結果
|category_name|reviews|avg_rating|
|-------------|-------|----------|
|ケース          |2      |4.5       |
|スマートフォン      |1      |5         |


--10件未満を除くと、

SELECT
	c.name AS category_name,
	count(r.review_id) AS reviews,
	round(avg(r.rating),2) as avg_rating
FROM
	products p
	INNER JOIN categories c
		ON c.category_id = p.category_id 
		AND JSON_CONTAINS(p.specifications,'{"is_waterproof":true}')
	INNER JOIN reviews r
		ON r.product_id = p.product_id
		AND JSON_CONTAINS(r.metadata,'{"verified_purchase":true}')
GROUP BY
	c.name,
	c.category_id
HAVING
   count(r.review_id) >= 10;



--こちらもサンプルデータが少ないので、５件以上という条件を無視する。
-- 2. 商品ごとのプラットフォーム別（mobile vs web）のレビュー比較を行ってください：
--    - 商品名
--    - モバイルでの平均評価
--    - 非モバイルでの平均評価
--    - モバイルでのレビュー数
--    - 非モバイルでのレビュー数
--    ただし、各プラットフォームで最低5件以上のレビューがある商品のみを対象としてください。

-- 2. 商品ごとのプラットフォーム別（mobile vs web）のレビュー比較を行ってください：
--    - 商品名
--    - モバイルでの平均評価
--    - 非モバイルでの平均評価
--    - モバイルでのレビュー数
--    - 非モバイルでのレビュー数
--    ただし、各プラットフォームで最低5件以上のレビューがある商品のみを対象としてください。

WITH mobile_stats AS(
	SELECT
		p.product_id,
		p.name AS product_name,
		AVG(r.rating) AS mobile_avg,
		COUNT(r.review_id) AS mobile_count
	FROM
		products p
		LEFT JOIN reviews r 
			ON r.product_id = p.product_id 
			AND JSON_CONTAINS(r.metadata,'{"platform":"mobile"}')
	GROUP BY
		p.name,
		p.product_id
),
non_mobile_stats AS(
	SELECT
		p.product_id,
		AVG(r.rating) AS non_mobile_avg,
		COUNT(r.review_id) AS non_mobile_count
	FROM
		products p
		LEFT JOIN reviews r
			ON r.product_id  = p.product_id
			AND !JSON_CONTAINS(r.metadata,'{"platform":"mobile"}')
	GROUP BY
		p.product_id
)
SELECT
	ms.product_name,
	ms.mobile_avg,
	ms.mobile_count,
	nms.non_mobile_avg,
	nms.non_mobile_count
FROM
	mobile_stats ms
	INNER JOIN non_mobile_stats nms
		ON nms.product_id = ms.product_id;




|product_name|mobile_avg|mobile_count|non_mobile_avg|non_mobile_count|
|------------|----------|------------|--------------|----------------|
|防水スマートフォンケース|5         |1           |4             |1               |
|スタンダードケース   |3         |1           |              |0               |
|高級スマートフォン   |          |0           |5             |1               |















