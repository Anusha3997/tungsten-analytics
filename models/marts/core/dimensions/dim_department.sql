with source as (

    select * from {{ ref('stg_tungsten__departments') }}

),
final as (

    select
        department_id,
        department_name

    from source

)

select * from final
