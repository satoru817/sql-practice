--各診療科ごとの予約数を、過去30日間で集計してください。診療科名と予約数を表示し、予約数が多い順に並べ替えてください。

with dept_stats as (
    select
        dep.name as department_name,
        count(case when 
                    curdate() - interval 30 day <= app.appointment_date
                        then 1  end
        ) as appointment_within_30days
            from
                departments dep
                    inner join doctors doc on doc.department = dep.name
                    left join appointments app on app.doctor_id = doc.doctor_id
            group by 
                dep.department_id,
                dep.name 
)
select
    ds.*
        from dept_stats ds
            order by
                ds.appointment_within_30days desc;
