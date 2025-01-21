--顧客購買パターン分析
--以下の情報を抽出してください：
--
--
--顧客ごとの累計購入額
--最も最近の購入からの経過日数
--よく購入するカテゴリTop2
--平均購入頻度（日数）

with customer_category_stats as (
    select
        cust.customer_id,
        cat.category_id,
        sum(oi.quantity*oi.unit_price) as total_sales
            from 
                customers cust
                    inner join orders o on o.customer_id = cust.customer_id
                    inner join order_items oi on oi.order_id = o.order_id
                    inner join books b on b.book_id = oi.book_id
                    inner join categories cat on cat.category_id = b.category_id
            group by 
                cust.customer_id,
                cat.category_id
),
customer_category_ranks as (
    select
        ccs.*,
        rank() over (partition by ccs.customer_id order by ccs.total_sales desc) as ranking
            from
                customer_category_stats ccs
),
top_2_category as (
     select
        ccr.customer_id,
        group_concat(
            c.category_name,
            order by ccr.ranking asc) as top_2
                from
        customer_category_ranks ccr
            inner join categories c on c.category_id = ccr.category_id
                where
                    ccr.ranking <= 2
        group by
            ccr.customer_id
),
cust_stats as (
    select
        cust.customer_id,
        concat(cust.first_name,' ',cust.last_name) as full_name,
        sum(o.total_amount) as total_order_amount,
        timestampdiff(day,max(o.order_date),curdate()) as time_since_last_purchase,
        round(timestampdiff(day,min(o.order_date),max(o.order_date)/(count(o.order_id)-1)),1 ) as avg_vacancy
            from customers cust
                inner join orders o on o.customer_id = cust.customer_id
            group by 
                cust.customer_id
)
select
    cs.full_name,
    cs.total_order_amount,
    cs.time_since_last_purchase,
    cs.avg_vacancy,
    tpc.top_2
        from 
            cust_stats cs
                left join top_2_category tpc on tpc.customer_id = cs.customer_id;












        
