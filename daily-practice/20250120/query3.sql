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
