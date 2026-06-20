with source as (

    select * from {{ source('raw_hr', 'employees') }}

),

renamed as (

    select
        emp_id as employee_id,
        ename as employee_name,
        job_role,
        dept_no as department_id,
        hire_date as hire_date

    from source

)

select * from renamed