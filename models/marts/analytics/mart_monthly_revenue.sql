with sales as (

    select * from {{ ref('fct_sales') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        d.year,
        d.month_number,
        d.month_name,

        sum(s.sales_amount) as revenue

    from sales s
    left join dates d
        on s.date_key = d.date_key

    group by
        d.year,
        d.month_number,
        d.month_name

)

select *
from final
order by year, month_number