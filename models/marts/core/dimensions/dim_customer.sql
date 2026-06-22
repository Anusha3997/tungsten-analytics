with source as (

    select * from {{ ref('stg_tungsten__customers') }}

),
final as (

    select
        c.customer_id,
        c.customer_name,
        c.email,
        c.phone_no,
        c.address,
        c.city,
        c.state,
        c.membership_id

    from source c

)

select * from final