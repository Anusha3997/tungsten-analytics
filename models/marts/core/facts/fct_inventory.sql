with inventory as (

    select * from {{ ref('stg_tungsten__inventory') }}

),

products as (

    select * from {{ ref('stg_tungsten__products') }}

),

final as (

    select
        i.inventory_id,
        i.product_id,
        p.product_name,
        i.stock_qty,
        i.last_restocked

    from inventory i
    left join products p
        on i.product_id = p.product_id

)

select * from final