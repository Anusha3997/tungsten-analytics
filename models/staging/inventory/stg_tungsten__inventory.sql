with source as (

    select * from {{ source('raw_inventory', 'inventory') }}

),

renamed as (

    select
        inv_id as inventory_id,
        prod_id as product_id,
        stock_qty,
        last_restocked

    from source

)

select * from renamed