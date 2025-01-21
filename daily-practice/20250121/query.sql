--カテゴリ分析
--各カテゴリ（親カテゴリを含む）の以下の情報を抽出してください：
--
--
--総売上額
--平均販売価格
--最も売れている本のTop3（売上金額ベース）
--カテゴリごとの平均レビュー評価


with book_stats as (
    select
        pc.category_name as parent_category_name,
        pc.category_id as parent_category_id,
        c.category_id,
        c.category_name,
        b.book_id,
        b.title,
        sum(oi.unit_price*oi.quantity) as total_sales
            from
                books b
                    inner join order_items oi on oi.book_id = b.book_id
                    inner join categories c on c.category_id = b.category_id
                    inner join categories pc on pc.category_id = c.parent_category_id
            group by
                pc.category_name,
                pc.category_id,
                c.category_id,
                c.category_name,
                b.book_id,
                b.title
),
book_rank_in_category as (
    select
        bs.*,
        rank() over (partition by bs.category_id order by bs.total_sales desc) as ranking
            from
                book_stats bs
),
book_rank_in_parent as (
    select
        bs.*,
        rank() over (partition by bs.parent_category_id order by bs.total_sales desc) as ranking
            from
                book_stats bs
),
top3_in_child as (
    select 
        bric.category_id,
        group_concat(
            bric.title,
            order by bric.ranking
        ) as top_3
            from 
                book_rank_in_category bric
            where
                bric.ranking <= 3
            group by bric.category_id
),
top3_in_parent as (
    select
        brip.parent_category_id,
        group_concat(
            brip.title,
            order by brip.ranking        
        ) as top_3
            from
                book_rank_in_parent brip
            where
                brip.ranking <= 3
            group by brip.parent_category_id
),
child_category_stats as (
    select
        c.category_id,
        c.category_name,
        sum(oi.unit_price*oi.quantity) as total_sales,
        sum(oi.unit_price*oi.quantity)/sum(oi.quantity) as avg_unit_price,
        avg(rev.rating) as avg_rating
            from
                categories c 
                    inner join books b on b.category_id = c.category_id
                    inner join order_items oi on oi.book_id = b.book_id
                    inner join reviews rev on rev.book_id = b.book_id
            group by
                c.category_id,
                c.category_name,
),
parent_category_stats as(
    select
        pc.category_id,
        pc.category_name,
        sum(oi.unit_price*oi.quantity) as total_sales,
        sum(oi.unit_price*oi.quantity)/sum(oi.quantity) as avg_unit_price,
        avg(rev.rating) as avg_rating
            from
                categories pc
                    inner join categories c on c.parent_category_id = pc.category_id
                    inner join books b on b.category_id = c.category_id
                    inner join order_items oi on oi.book_id = b.book_id
                    inner join reviews rev on rev.book_id = b.book_id
            group by 
                pc.category_id,
                pc.category_name
)
select
    


