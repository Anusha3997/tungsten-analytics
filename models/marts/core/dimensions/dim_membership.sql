with source as (

    select * from {{ ref('stg_tungsten__membership') }}

),
final as (

    select
        membership_id,
        customer_id,
        membership_status,
        registration_date,
        points_balance
       
    from source

)

select * from final
