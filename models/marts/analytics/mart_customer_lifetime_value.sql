with sales as (

    select * from {{ ref('fct_sales') }}

),
customers as (
    
    select * from {{ ref('dim_customer') }}

),
final as (

    select
        s.customer_id,
        c.customer_name,
        sum(s.sales_amount) as lifetime_value

    from sales s
    left join customers c
        on s.customer_id = c.customer_id

    group by
        s.customer_id,
        c.customer_name

)
select *
from final
order by lifetime_value desc