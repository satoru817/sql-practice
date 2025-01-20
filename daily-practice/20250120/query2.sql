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
                            
