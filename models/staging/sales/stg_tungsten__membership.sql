with source as (

    select * from {{ source('raw_sales', 'membership') }}

),

renamed as (

    select
        mem_id as membership_id,
        cust_id as customer_id,
        mem_status as membership_status,
        reg_date as registration_date,
        points_balance as points_balance

    from source

)

select * from renamed