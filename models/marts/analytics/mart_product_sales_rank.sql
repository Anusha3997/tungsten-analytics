with sales as (

    select * from {{ ref('fct_sales') }}

),
products as (

    select * from {{ ref('dim_product') }}

),
final as (

    select
        s.product_id,
        p.product_name,
        sum(s.sales_amount) as revenue

    from sales s
    left join products p
        on s.product_id = p.product_id
    group by
        s.product_id,
        p.product_name

)
select *
from final
order by revenue desc