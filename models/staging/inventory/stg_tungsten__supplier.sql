with source as (

    select * from {{ source('raw_inventory', 'suppliers') }}

),

renamed as (

    select
        supp_id as supplier_id,
        sname as supplier_name,
        contactname as contact_name,
        supp_phone as supplier_phone,
        supp_address as supplier_address

    from source

)

select * from renamed