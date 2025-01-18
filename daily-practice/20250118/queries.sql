with child_category_stats as (
    select
        c.category_id,
        c.parent_category_id,
        pc.name as parent_category_name,
        c.name as child_category_name,
        sum(oi.quantity*oi.unit_price) as total_sales,
        sum(oi.quantity) as total_quantity
            from
                categories c
                    inner join products p on p.category_id = c.category_id
                    left join categories pc on pc.category_id = c.parent_category_id
                    inner join order_items oi on oi.product_id = p.product_id
            group by 
                c.category_id,
                c.parent_category_id,
                c.name
),
parent_category_stats as(
    select
        pc.category_id,
        pc.name as parent_category_name,
        sum(ccs.total_sales) as total_sales,
        sum(ccs.total_quantity) as total_quantity
            from 
                categories pc
                    left join categories cc on cc.parent_category_id = pc.category_id
                    inner join child_category_stats ccs on ccs.category_id = cc.category_id
            group by 
                pc.category_id,
                pc.name
)
select
    coalesce(pcs.parent_category_name,ccs.child_category_name) as category_name,
    ccs.parent_category_name,
    coalesce(pcs.total_sales,ccs.total_sales),
    coalesce(pcs.total_quantity,ccs.total_quantity),
    coalesce(ccs.total_sales/ccs.total_quantity,pcs.total_sales/pcs.total_quantity) as avg_price
        from
            categories c
                left join child_category_stats ccs on ccs.category_id = c.category_id
                left join parent_category_stats pcs on pcs.category_id = c.category_id;
