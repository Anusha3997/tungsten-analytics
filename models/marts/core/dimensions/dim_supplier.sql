with source as (

    select * from {{ ref('stg_tungsten__supplier') }}

),
final as (

    select
        supplier_id,
        supplier_name,
        contact_name,
        supplier_phone,
        supplier_address

    from source

)

select * from final
