--問題2: カテゴリ別在庫回転率
--- 各カテゴリの在庫回転率を計算してください
--- 在庫回転率 = 売上数量 / 現在庫数
--- 表示項目：
--  * カテゴリ名
--  * 現在庫数
--  * 売上数量
--  * 在庫回転率
--  * 在庫金額
--- 在庫回転率が低い順にソート


select
    c.category_name,
    sum(p.stock_quantity) as total_stock_quantity,
    sum(oi.quantity) as total_sold_quantity,
    sum(oi.quantity)/sum(p.stock_quantity) as ratio,
    sum(p.price*p.stock_quantity) as total_stock_price
        from
            categories c
                inner join products p on p.category_id = c.category_id
                inner join order_items oi on oi.product_id = p.product_id
        group by 
            c.category_id;
