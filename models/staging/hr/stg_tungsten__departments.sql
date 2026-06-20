with source as (

    select * from {{ source('raw_hr', 'departments') }}

),

renamed as (

    select
        deptno as department_id,
        dept_name as department_name

    from source

)

select * from renamed