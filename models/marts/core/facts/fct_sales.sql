with orders as (

    select * from {{ ref('stg_tungsten__orders') }}

),

order_details as (

    select * from {{ ref('stg_tungsten__order_details') }}

),

sales as (

    select
        od.order_detail_id,
        od.order_id,
        o.customer_id,
        o.employee_id,
        od.product_id,
        cast(o.order_date as date) as date_key,
        od.quantity,
        od.unit_price,
        od.quantity * od.unit_price as sales_amount,

        o.total_amount as order_total_amount

    from order_details od
    left join orders o
        on od.order_id = o.order_id

)

select * from sales