with source as (

    select * from {{ source('raw_sales', 'order_details') }}

),

renamed as (

    select
        detail_id as order_detail_id,
        order_id,
        prod_id as product_id,
        quantity,
        unit_price

    from source

)

select * from renamed