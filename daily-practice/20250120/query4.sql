--問題1: リピート購入分析
--- 2回以上購入している顧客のリストを作成してください
--- 表示項目：
--  * 顧客名（フルネーム）
--  * 総注文回数
--  * 総購入金額
--  * 平均購入金額
--  * 最も最近の注文日
--- 総購入金額が高い順にソート

with cust_stats as (
    select
        c.customer_id,
        concat(c.first_name,' ',c.last_name) as full_name,
        count(o.order_id) as order_count,
        sum(o.total_amount) as total_amount,
        avg(o.total_amount) as avg_amount,
        date_format(max(o.order_date),'%Y-%m-%d') as last_order_date
            from
                customers c
                    inner join orders o on o.customer_id = c.customer_id
            group by 
                c.customer_id,
                concat(c.first_name,' ',c.last_name)
)
select
    full_name,
    order_count,  
    total_amount,   
    avg_amount,
    last_order_date
        from
            cust_stats
                where
                    order_count >= 2;


--AIによる改善提案
WITH cust_stats AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name,' ',c.last_name) as full_name,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_amount,
        ROUND(AVG(o.total_amount), 2) as avg_amount,
        DATE_FORMAT(MAX(o.order_date), '%Y-%m-%d') as last_order_date
    FROM
        customers c
        INNER JOIN orders o ON o.customer_id = c.customer_id
            AND o.status = 'completed'  -- 完了した注文のみカウント
    GROUP BY 
        c.customer_id,
        CONCAT(c.first_name,' ',c.last_name)
    HAVING 
        COUNT(o.order_id) >= 2  -- WHEREの代わりにHAVINGを使用
)
SELECT
    full_name,
    order_count,
    FORMAT(total_amount, '#,##0') as total_amount,   -- 金額フォーマット
    FORMAT(avg_amount, '#,##0.00') as avg_amount,    -- 平均金額フォーマット
    last_order_date
FROM
    cust_stats
ORDER BY
    total_amount DESC;  -- 総購入金額順のソート
