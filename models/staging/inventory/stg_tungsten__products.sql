with source as (

    select * from {{ source('raw_inventory', 'products') }}

),

renamed as (

    select
        prod_id as product_id,
        prod_name as product_name,
        price,
        category,
        stock_qty,
        supp_id as supplier_id

    from source

)

select * from renamed