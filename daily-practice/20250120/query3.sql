--4. 商品売上ランキング
--   - 商品ごとの売上実績を分析してください
--   - 以下の情報を含めてください：
--     * 商品名
--     * カテゴリ名
--     * 売上個数
--     * 売上金額
--     * 売上金額の順位


with prod_stats as (
    select 
        p.product_id,
        p.product_name,
        c.category_name,
        sum(oi.quantity) as total_quantity,
        sum(oi.quantity*oi.unit_price) as total_sales
            from 
                products p 
                    inner join categories c on c.category_id = p.category_id
                    inner join order_items oi on oi.product_id = p.product_id
            group by 
                p.product_id,
                p.product_name,
                c.category_name
)
select
    product_name,
    category_name,
    total_quantity,
    total_sales,
    rank() over (order by total_sales desc) as total_sales_rank
        from 
            prod_stats
        order by
            total_sales_rank,
            product_name;


--AIによる改善提案
WITH sales_summary AS (
    SELECT 
        p.product_id,
        p.product_name,
        c.category_name,
        COALESCE(SUM(oi.quantity), 0) AS total_quantity,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_sales,
        COUNT(DISTINCT o.order_id) AS order_count,
        COALESCE(MIN(o.order_date), 'データなし') AS first_sale_date,
        COALESCE(MAX(o.order_date), 'データなし') AS last_sale_date
    FROM 
        products p 
        INNER JOIN categories c ON c.category_id = p.category_id
        LEFT JOIN order_items oi ON oi.product_id = p.product_id
        LEFT JOIN orders o ON o.order_id = oi.order_id AND o.status = 'completed'
    GROUP BY 
        p.product_id,
        p.product_name,
        c.category_name
),
sales_with_stats AS (
    SELECT
        product_name,
        category_name,
        total_quantity,
        FORMAT(total_sales, '##,###') AS formatted_sales,
        RANK() OVER (ORDER BY total_sales DESC) AS sales_rank,
        CASE 
            WHEN total_sales > 0 THEN
                CONCAT(
                    ROUND(100.0 * total_sales / SUM(total_sales) OVER (), 1),
                    '%'
                )
            ELSE '0.0%'
        END AS sales_percentage,
        order_count,
        first_sale_date,
        last_sale_date,
        CASE
            WHEN total_sales = 0 THEN '未販売'
            WHEN DATEDIFF(NOW(), last_sale_date) > 30 THEN '30日以上販売なし'
            ELSE '直近で販売あり'
        END AS sales_status
    FROM 
        sales_summary
)
SELECT
    sales_rank,
    product_name,
    category_name,
    total_quantity,
    formatted_sales AS total_sales,
    sales_percentage,
    order_count AS unique_orders,
    first_sale_date,
    last_sale_date,
    sales_status
FROM 
    sales_with_stats
ORDER BY
    sales_rank,
    product_name;
