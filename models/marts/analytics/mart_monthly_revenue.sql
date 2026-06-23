with sales as (

    select * from {{ ref('fct_sales') }}

),

final as (

    select
        date_trunc('month', date_key) as month,
        sum(sales_amount) as revenue

    from sales

    group by 1

)

select * from final
order by month