/*
問題1: カテゴリー階層ごとの売上分析
- 親カテゴリーと子カテゴリーの両方の売上を集計
- 以下の情報を表示
  - カテゴリー名
  - 親カテゴリー名（該当する場合）
  - 総売上金額
  - 総販売数
  - 平均販売単価
- キャンセルされた注文は除外
- カテゴリー階層ごとにソート
*/

with family_cat_stats as(
    select
        pc.name as parent_name,
        pc.category_id as parent_id,--child_idがparentのものの場合、ここはNULLが来る
        c.name as category_name,
        c.category_id ,--ここにすべてのcategory_idが来る（parentも含めて）
        oi.unit_price,
        oi.quantity
            from
                categories c 
                    left join products p on p.category_id = c.category_id
                    left join order_items oi on oi.product_id = p.product_id
                    left join orders o on o.order_id = oi.order_id and o.order_status != 'cancelled'
                    left join categories pc on pc.category_id = c.parent_category_id
)
select
    distinct concat(fcs.category_name,'id:',fcs.category_id),--親カテゴリも子カテゴリもすべてとってくる
    coalesce(fcs.parent_name,'親カテゴリなし') as parent_name,
    case when fcs.parent_id IS NOT NULL 
        then sum(fcs.unit_price*fcs.quantity) over (partition by fcs.category_id)
        else
            select(
                sum(fcs1.unit_price*fcs1.quantity) 
                    from family_cat_stats fcs1 
                       where fcs1.parent_id = fcs.category_id)
         end 
    as category_total_sales,
    case when fcs.parent_id IS NOT NULL
        then sum(fcs.quantity) over (partition by fcs.category_id)
        else
            select(
                sum(fcs1.unit_price*fcs1.quantity)
                from family_cat_stats fcs1
                    where fcs1.parent_id = fcs.category_id)
        end
    as category_total_quantity,
    case when fcs.parent_id IS NOT NULL 
        then sum(fcs.unit_price*fcs.quantity)/sum(fcs.quantity) over (partition by fcs.category_id)
        else
            select(
                sum(fcs1.unit_price*fcs1.quantity) /sum(fcs1.quantity)
                    from family_cat_stats fcs1 
                       where fcs1.parent_id = fcs.category_id)
         end 
    as category_avg_unit_price
        from
            family_cat_stats fcs;

--AIによる改善提案

WITH category_stats AS (
    -- まず子カテゴリーレベルでの集計を行う
    SELECT 
        c.category_id,
        c.name AS category_name,
        c.parent_category_id,
        pc.name AS parent_category_name,
        SUM(oi.quantity * oi.unit_price) AS total_sales,
        SUM(oi.quantity) AS total_quantity
    FROM categories c
        LEFT JOIN products p ON p.category_id = c.category_id
        LEFT JOIN order_items oi ON oi.product_id = p.product_id
        LEFT JOIN orders o ON o.order_id = oi.order_id
        LEFT JOIN categories pc ON pc.category_id = c.parent_category_id
    WHERE o.order_status != 'cancelled' OR o.order_status IS NULL
    GROUP BY 
        c.category_id,
        c.name,
        c.parent_category_id,
        pc.name
),
parent_category_stats AS (
    -- 親カテゴリーレベルでの集計
    SELECT 
        pc.category_id,
        pc.name AS category_name,
        NULL AS parent_category_id,
        NULL AS parent_category_name,
        SUM(cs.total_sales) AS total_sales,
        SUM(cs.total_quantity) AS total_quantity
    FROM categories pc
        JOIN category_stats cs ON cs.parent_category_id = pc.category_id
    WHERE pc.parent_category_id IS NULL
    GROUP BY 
        pc.category_id,
        pc.name
)

-- 両方の結果を結合
SELECT 
    cs.category_name,
    COALESCE(cs.parent_category_name, '親カテゴリー') AS parent_category_name,
    COALESCE(cs.total_sales, 0) AS total_sales,
    COALESCE(cs.total_quantity, 0) AS total_quantity,
    CASE 
        WHEN cs.total_quantity > 0 
        THEN ROUND(cs.total_sales / cs.total_quantity, 2)
        ELSE 0 
    END AS avg_unit_price
FROM category_stats cs
UNION ALL
SELECT 
    pcs.category_name,
    pcs.parent_category_name,
    COALESCE(pcs.total_sales, 0) AS total_sales,
    COALESCE(pcs.total_quantity, 0) AS total_quantity,
    CASE 
        WHEN pcs.total_quantity > 0 
        THEN ROUND(pcs.total_sales / pcs.total_quantity, 2)
        ELSE 0 
    END AS avg_unit_price
FROM parent_category_stats pcs
ORDER BY 
    parent_category_name,
    category_name;










           
     
