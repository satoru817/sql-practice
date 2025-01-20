--3. 在庫金額分析
--   - 各カテゴリの現在の在庫金額を計算してください
--   - 以下の情報を含めてください：
--     * カテゴリ名（親カテゴリ含む）
--     * 在庫数合計
--     * 在庫金額合計
--     * 在庫金額の割合（全体に対する％）

with total_stock as(
    select
        sum(p.stock_quantity*p.price) as stock
    from
        products p
),
child_category_stats as (
    select
        c.category_id,
        c.category_name,
        sum(p.stock_quantity) as total_stock,
        sum(p.stock_quantity*p.price)  as total_stock_price,
        concat(round(100.0*sum(p.stock_quantity*p.price) /ts.stock,1),'%') as ratio
            from
                products p
                    inner join categories c on c.category_id = p.category_id
                    cross join total_stock ts
            group by 
                c.category_id,
                c.category_name
),
parent_category_stats as (
    select
        pc.category_id,
        pc.category_name,
        sum(ccs.total_stock) as total_stock,
        sum(ccs.total_stock_price) as total_stock_price,
        concat(round(100.0*sum(ccs.total_stock_price)/ts.stock,1),'%') as ratio
            from
                child_category_stats ccs
                    inner join categories c on c.category_id = ccs.category_id
                    inner join categories pc on pc.category_id = c.parent_category_id
            group by 
                pc.category_id,
                pc.category_name
)
select
    c.category_name,
    coalesce(pcs.total_stock,ccs.total_stock) as total_stock,
    coalesce(pcs.total_stock_price,ccs.total_stock_price) as total_stock_price,
    coalesce(pcs.ratio,ccs.ratio) as ratio
        from
            categories c
                left join child_category_stats ccs on ccs.category_id = c.category_id
                left join parent_category_stats pcs on pcs.category_id = c.category_id;
                            


--AIによる改善案
WITH stock_summary AS (
    SELECT
        SUM(p.stock_quantity * p.price) as total_stock_value
    FROM products p
),
child_category_stats AS (
    SELECT
        c.category_id,
        c.category_name,
        SUM(p.stock_quantity) as total_stock,
        SUM(p.stock_quantity * p.price) as total_stock_price,
        CONCAT(
            ROUND(
                100.0 * SUM(p.stock_quantity * p.price) / 
                FIRST_VALUE(SUM(p.stock_quantity * p.price)) OVER (ORDER BY NULL),
                1
            ),
            '%'
        ) as ratio
    FROM
        products p
        INNER JOIN categories c ON c.category_id = p.category_id
    GROUP BY 
        c.category_id,
        c.category_name
),
parent_category_stats AS (
    SELECT
        pc.category_id,
        pc.category_name,
        SUM(ccs.total_stock) as total_stock,
        SUM(ccs.total_stock_price) as total_stock_price,
        CONCAT(
            ROUND(
                100.0 * SUM(ccs.total_stock_price) / 
                (SELECT total_stock_value FROM stock_summary),
                1
            ),
            '%'
        ) as ratio
    FROM
        child_category_stats ccs
        INNER JOIN categories c ON c.category_id = ccs.category_id
        INNER JOIN categories pc ON pc.category_id = c.parent_category_id
    GROUP BY 
        pc.category_id,
        pc.category_name
)
SELECT
    c.category_name,
    COALESCE(pcs.total_stock, ccs.total_stock) as total_stock,
    FORMAT(COALESCE(pcs.total_stock_price, ccs.total_stock_price), 0) as total_stock_price,
    COALESCE(pcs.ratio, ccs.ratio) as ratio
FROM
    categories c
    LEFT JOIN child_category_stats ccs ON ccs.category_id = c.category_id
    LEFT JOIN parent_category_stats pcs ON pcs.category_id = c.category_id
ORDER BY 
    COALESCE(pcs.total_stock_price, ccs.total_stock_price) DESC;

https://claude.ai/chat/023a59ae-ff97-42f3-a419-1479cec24738
