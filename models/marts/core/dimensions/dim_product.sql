with source as (

    select * from {{ ref('stg_tungsten__products') }}

),
final as (

    select
        product_id,
        product_name,
        price,
        category,
        stock_qty,
        supplier_id

    from source

)

select * from final
