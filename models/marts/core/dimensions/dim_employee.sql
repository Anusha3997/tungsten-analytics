with source as (

    select * from {{ ref('stg_tungsten__employees') }}

),
final as (

    select
        employee_id,
        employee_name,
        job_role,
        department_id,
        hire_date

    from source

)

select * from final