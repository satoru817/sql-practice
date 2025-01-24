/*
問題：以下の分析クエリを作成してください

1. 出版社ごとの売上集計
   - 出版社別の総売上金額
   - 出版社別の売上冊数
   - 書籍の平均単価
   - 売上金額が多い順にランク付け

2. 会員ランク別の購入分析
   - 会員ランク別の総購入金額
   - 会員ランク別の平均購入金額
   - 1回の注文における平均購入金額
   - 購入回数

3. 売れ筋書籍ランキング
   - 書籍ごとの売上金額
   - 書籍ごとの販売数
   - 書籍の在庫回転率（販売数/在庫数）
   - 売上TOP3の書籍名
*/

--問題１
with publisher_stats as (
    select
        p.publisher_id,
        p.publisher_name,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity) as total_quantity
            from
                order_details oi
                    inner join books b on b.book_id = oi.book_id
                    inner join publishers p on p.publisher_id = b.publisher_id
             group by 
                p.publisher_id,
                p.publisher_name
),
publisher_rank as (
    select
        ps.*,
        round(ps.total_sales/ps.total_quantity,1) as avg_unit_price,
        rank() over (order by ps.total_sales desc) as ranking
            from publisher_stats ps
)
select
    pr.publisher_name,
    pr.total_sales,
    pr.total_quantity,
    pr.avg_unit_price,
    pr.ranking
        from 
            publisher_rank pr;

--問題２
--2. 会員ランク別の購入分析
--   - 会員ランク別の総購入金額
--   - 会員ランク別の平均購入金額（一人の）
--   - 1回の注文における平均購入金額
--   - 購入回数

with mem_rank_stats as (
    select
        c.membership_rank,
        sum(o.total_amount) as total_sales,
        count(distinct c.customer_id) as customer_count,
        count(o.order_id) as order_count
            from 
                customers c
                    inner join orders o on o.customer_id = c.customer_id
            group by
                c.membership_rank
)
select
    mrs.membership_rank,
    mrs.total_sales,
    round(mrs.total_sales/mrs.customer_count,1) as avg_per_person,
    round(mrs.total_sales/mrs.order_count,1) as avg_per_purchase,
    mrs.order_count
        from mem_rank_stats mrs;


--3. 売れ筋書籍ランキング
--   - 書籍ごとの売上金額
--   - 書籍ごとの販売数
--   - 書籍の在庫回転率（販売数/在庫数）
--   - 売上TOP3の書籍名


with book_stats as (
    select
        b.book_id,
        b.title,
        sum(od.quantity*od.unit_price) as total_sales,
        sum(od.quantity) as total_quantity,
        sum(od.quantity)/b.stock_quantity as turnover_rate
            from
                books b 
                    inner join order_details od on od.book_id = b.book_id
                group by
                    b.book_id,
                    b.title,
                    b.stock_quantity
)
select
    bs.*,
    rank() over (order by bs.total_sales desc) as sales_rank
        from book_stats bs;










