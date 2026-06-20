with source as (

    select * from {{ source('raw_sales', 'orders') }}

),

renamed as (

    select
        order_id,
        cust_id as customer_id,
        order_date,
        total_amount,
        emp_id as employee_id

    from source

)

select * from renamed