--2. 顧客購買分析
--   - 2024年1月の顧客ごとの購買状況を分析してください
--   - 以下の情報を含めてください：
--     * 顧客のフルネーム
--     * 購入回数
--     * 総購入額
--     * 平均購入額
--     * 最も高額な購入商品名


with cust_stats_202401 as (
    select
        cust.customer_id,
        concat(cust.first_name,' ',cust.last_name) as full_name,
        count(o.order_id) as order_count,
        sum(o.total_amount) as total_order_amount,
        avg(o.total_amount) as avg_order_amount
            from
                customers cust
                    left join orders o on o.customer_id = cust.customer_id
                        AND date_format(o.order_date,'%Y-%m') = '2024-01'
            group by
                cust.customer_id,
                concat(cust.first_name,' ',cust.last_name)
),
rank_per_cust_202401 as (
    select
        cust.customer_id,
        oi.product_id,
        p.product_name,
        rank() over(partition by cust.customer_id order by oi.unit_price desc) as ranking
            from
                customers cust
                    inner join orders o on o.customer_id = cust.customer_id
                    inner join order_items oi on oi.order_id = o.order_id
                    inner join products p on p.product_id = oi.product_id
            where
                date_format(o.order_date,'%Y-%m') = '2024-01'
)
select
    cs.full_name,
    cs.order_count,
    cs.total_order_amount,
    cs.avg_order_amount,
    rpc.product_name
        from 
            cust_stats_202401 cs
                left join rank_per_cust_202401 rpc on rpc.customer_id = cs.customer_id
        where
            rpc.ranking = 1;

--実行結果
--太郎 山田	2	102600.00	51300.000000	iPhone 14
--花子 田中	1	134800.00	134800.000000	MacBook Air
--一郎 鈴木	1	94800.00	94800.000000	Galaxy S23
--

 
