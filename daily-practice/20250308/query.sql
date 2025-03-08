--  Challenge
-- 
-- Write a SQL query that analyzes customer purchase behavior with the following requirements:
-- 
-- 1. For each product category (including parent categories), calculate:
--    - Total revenue
--    - Total profit
--    - Number of unique customers
--    - Average order value
--    - Percentage of total store revenue
-- 
-- 2. For each parent category, identify the top 3 subcategories by revenue
-- 
-- 3. Calculate the customer retention rate by showing what percentage of customers who purchased in one month also made a purchase in the following month
-- 
-- 4. Include only completed orders (status = 'completed')
-- 
-- 5. Use window functions and CTEs for better organization
-- 
-- 6. Handle cases where products may belong to subcategories that have been deleted (orphaned products)
-- 
-- 7. Format monetary values with 2 decimal places and percentages with 1 decimal place
-- 
-- This query should provide a comprehensive analysis that could be used by business stakeholders to understand product category performance and customer retention patterns.


 -- かなりきついので、要件3以外をとりあえず実装

WITH subcategory_orders AS ( -- 一つのorderに複数のorder_itemが結びつきうるわけだが、そのorder_itemが同一のcategoryのproductに結びつく場合まとめないといけない
	SELECT
		oi.order_id,
		p.category_id,
		SUM(oi.price_paid) AS one_order_value_by_category,
		SUM(oi.price_paid-p.cost*oi.quantity) AS one_order_profit_by_category
	FROM
		order_items oi
		INNER JOIN products p ON p.product_id = oi.product_id
	GROUP BY
		oi.order_id,
		p.category_id
),
subcategory_stats AS (
	SELECT
		c.category_id,
		c.name AS subcategory_name,
		c.parent_category_id,
		SUM(so.one_order_profit_by_category) AS total_profit_by_subcategory,
		SUM(so.one_order_value_by_category) AS total_revenue_by_subcategory,
		AVG(so.one_order_value_by_category) AS avg_revenue_by_subcategory
	FROM
		subcategory_orders so
		INNER JOIN categories c ON c.category_id = so.category_id
	GROUP BY
		c.category_id,
		c.name,
		c.parent_category_id
),
parent_category_orders AS( -- 一つのorderに同一の親カテゴリーのorder_itemが結びつくときそれをまとめないといけない
	SELECT
		pc.category_id,
		oi.order_id,
		SUM(oi.price_paid) AS one_order_revenue_by_parent_category,
		SUM(oi.price_paid-p.cost*oi.quantity) AS one_order_profit_by_parent_category
	FROM
		categories pc
		INNER JOIN categories c ON c.parent_category_id = pc.category_id
		INNER JOIN products p ON p.category_id = c.category_id
		INNER JOIN order_items oi ON oi.product_id = p.product_id
	GROUP BY
		pc.category_id,
		oi.order_id
),
parent_category_stats AS(
	SELECT
		category_id AS parent_category_id,
		SUM(one_order_revenue_by_parent_category) AS total_revenue_by_parent_category,
		SUM(one_order_profit_by_parent_category) AS total_profit_by_parent_category,
		AVG(one_order_revenue_by_parent_category) AS avg_revenue_by_parent_category
	FROM
		parent_category_orders
	GROUP BY
		category_id
),
subcategory_rank_in_parent_category AS (
	SELECT
		ss.subcategory_name,
		ss.parent_category_id,
		RANK() OVER (PARTITION BY ss.parent_category_id ORDER BY ss.total_revenue_by_subcategory) AS rank_in_parent_category
	FROM
		subcategory_stats ss
),
top_subcategories_in_parent_category AS (
	SELECT
		parent_category_id,
		GROUP_CONCAT(subcategory_name ORDER BY rank_in_parent_category ASC) AS top_subcategories
	FROM
		subcategory_rank_in_parent_category
),
unique_customers_in_subcategories AS(
	SELECT
		p.category_id,
		COUNT(DISTINCT o.user_id) AS unique_customers
	FROM
		products p
		INNER JOIN order_items oi ON oi.product_id = p.product_id
		INNER JOIN orders o ON o.order_id = oi.order_id
	GROUP BY
		p.category_id
),
unique_customers_in_parent_categories AS(
	SELECT
		pc.category_id,
		COUNT(DISTINCT o.user_id) AS unique_customers
	FROM
		categories pc
		INNER JOIN categories c ON c.parent_category_id = pc.category_id
		INNER JOIN products p ON p.category_id = c.category_id
		INNER JOIN order_items oi ON oi.product_id = p.product_id
		INNER JOIN orders o ON o.order_id = oi.order_id
	GROUP BY
		pc.category_id
)
SELECT
	c.name AS category_name,
	COALESCE(pc.name,'NO PARENT') AS parent_category_name,
	COALESCE(ss.total_revenue_by_subcategory,pcs.total_revenue_by_parent_category) AS total_revenue,
	COALESCE(ss.total_profit_by_subcategory,pcs.total_profit_by_parent_category) AS total_profit,
	COALESCE(ss.avg_revenue_by_subcategory,pcs.avg_revenue_by_parent_category) AS avg_order_value,
	CONCAT(ROUND(100.0*COALESCE(ss.total_revenue_by_subcategory,pcs.total_revenue_by_parent_category)/SUM(pcs.total_revenue_by_parent_category) OVER () ,1),'%') AS percentage_of_revenue
FROM
	categories c
	LEFT JOIN categories pc ON pc.category_id = c.parent_category_id
	LEFT JOIN subcategory_stats ss ON ss.category_id = c.category_id
	LEFT JOIN parent_category_stats pcs ON pcs.parent_category_id = c.category_id
	LEFT JOIN top_subcategories_in_parent_category tsipc ON tsipc.parent_category_id = c.category_id
	LEFT JOIN unique_customers_in_subcategories ucis ON ucis.category_id = c.category_id
	LEFT JOIN unique_customers_in_parent_categories ucipc ON ucipc.category_id = c.category_id;

--　実行結果

|category_name      |parent_category_name|total_revenue|total_profit|avg_order_value|percentage_of_revenue|
|-------------------|--------------------|-------------|------------|---------------|---------------------|
|Electronics        |NO PARENT           |9,780        |3,781       |978            |74.8%                |
|Clothing           |NO PARENT           |285          |130         |95             |2.2%                 |
|Home & Garden      |NO PARENT           |2,810        |1,250       |468            |21.5%                |
|Books              |NO PARENT           |197          |110         |66             |1.5%                 |
|Smartphones        |Electronics         |4,600        |1,750       |920            |35.2%                |
|Laptops            |Electronics         |4,300        |1,550       |1,433          |32.9%                |
|Accessories        |Electronics         |880          |481         |176            |6.7%                 |
|Men's Clothing     |Clothing            |100          |56          |50             |0.8%                 |
|Women's Clothing   |Clothing            |130          |64          |65             |1.0%                 |
|Children's Clothing|Clothing            |55           |10          |55             |0.4%                 |
|Furniture          |Home & Garden       |2,600        |1,120       |650            |19.9%                |
|Kitchen            |Home & Garden       |210          |130         |105            |1.6%                 |
|Gardening          |Home & Garden       |             |            |               |                     |
|Fiction            |Books               |55           |37          |27             |0.4%                 |
|Non-Fiction        |Books               |82           |38          |41             |0.6%                 |
|Academic           |Books               |60           |35          |60             |0.5%                 |












