--1. カテゴリ分析
--   - 親カテゴリごとの総売上と販売個数を算出してください
--   - 結果には以下を含めてください：
--     * 親カテゴリ名
--     * 総売上額（降順でソート）
--     * 販売個数
--     * 平均販売価格


select
    pc.category_name as parent_category_name,
    sum(oi.unit_price*oi.quantity) as total_sales,
    sum(oi.quantity) as total_quantity,
    sum(oi.unit_price*oi.quantity)/sum(oi.quantity) as avg_sales
        from
            order_items oi
                inner join products p on p.product_id = oi.product_id
                inner join categories c on c.category_id = p.category_id
                inner join categories pc on pc.category_id = c.parent_category_id
        group by 
            pc.category_id,
            pc.category_name;


--実行結果
--エレクトロニクス	319400.00	3	106466.666667
--衣類	12800.00	1	12800.000000
