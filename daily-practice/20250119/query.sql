--カテゴリ別の売上分析
--
--親カテゴリごとの総売上額
--カテゴリ別の平均購入単価
--最も売れている商品TOP3（カテゴリごと）
--データ期間：2024年第1四半期

with prod_stats2024Q1 as (
    select
        p.product_id,
        p.product_name
        c.parent_category_id,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity) as total_quantity
            from 
                products p
                    inner join categories c on c.category_id = p.category_id
                    inner join order_items oi on oi.product_id = p.product_id
                    inner join orders o on o.order_id = oi.order_id 
                where
                    year(o.order_date) = 2024
                    and quarter(o.order_date) = 1
                    and o.status != 'CANCELLED'
                group by 
                    p.product_id,
                    p.product_name,
                    c.parent_category_id
),
prod_rank2024Q1 as (
    select
        ps.*,
        rank() over (partition by ps.parent_category_id order by ps.total_sales desc) as ranking_in_parent
            from
                prod_stats2024Q1 ps
),
parent_category_stats as (
    select
        ps.parent_category_id,
        sum(ps.total_sales) as total_sales,
        sum(ps.total_quantity) as total_quantity,
        sum(ps.total_sales)/sum(ps.total_quantity) as avg_unit_price,
            from
                prod_stats2024Q1 ps
                    group by ps.parent_category_id
)
select
    c.category_name as parent_category_name,
    round(psc.total_sales,2) as total_sales,
    psc.total_quantity,
    round(psc.avg_unit_price) as avg_unit_price,
    group_concat(
        pr.product_name
        order by pr.ranking_in_parent
    ) as top_3
            from
                parent_category_stats pcs
                    inner join categories c on pcs.parent_category_id = c.category_id
                    inner join prod_rank2024Q1 pr on pr.parent_category_id = pcs.parent_category_id 
                                                    and pr.ranking_in_parent <= 3
            group by 
                c.category_name,
                c.category_id;
             
        
    
                
    

