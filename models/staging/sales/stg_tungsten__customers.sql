with source as (

    select * from {{ source('raw_sales', 'customers') }}

),

renamed as (

    select
        cust_id as customer_id,
        cust_name as customer_name,
        email,
        phone_no,
        address,
        city,
        state,
        mem_id as membership_id,
        total_spent

    from source

)

select * from renamed