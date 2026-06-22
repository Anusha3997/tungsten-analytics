with date_spine as (

    select
        dateadd(day, seq4(), '2020-01-01'::date) as date_key
    from table(generator(rowcount => 3653))

),

final as (

    select
        date_key,

        year(date_key) as year,
        quarter(date_key) as quarter,

        month(date_key) as month_number,
        monthname(date_key) as month_name,

        week(date_key) as week_number,

        day(date_key) as day_of_month,
        dayofweek(date_key) as day_of_week,

        case
            when dayofweek(date_key) in (0, 6) then 'Weekend'
            else 'Weekday'
        end as day_type

    from date_spine

)

select * from final