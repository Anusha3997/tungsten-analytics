with sales as (

    select * from {{ ref('fct_sales') }}

)

select
    sum(sales_amount) as total_revenue,
    count(distinct order_id) as total_orders,
    count(distinct customer_id) as total_customers
from sales