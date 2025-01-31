with doc_app_stats as (
    select
        d.doctor_id,
        sum(case when a.status = 'cancelled' then 1 else 0 end)/nullif(count(a.appointment_id),0) as cancell_rate
    from
        doctors d
        inner join appointments a on a.doctor_id = d.doctor_id
    where
        date_format(a.appointment_date,'%Y-%m')='2024-01'
    group by
        d.doctor_id
)
select
    d.name,
    count(m.record_id) as total_record,
    round(coalesce(sum(m.fee),0),1) as total_fee,
    round(coalesce(avg(m.fee),0),1) as avg_fee,
    concat(round(coalesce(das.cancell_rate,0)*100.0,2),'%') as cancell_rate
from
    doctors d
    left join medical_records m
        on m.doctor_id = d.doctor_id
        and date_format(m.visit_date,'%Y-%m')= '2024-01'
    left join doc_app_stats das on das.doctor_id = d.doctor_id
group by 
    d.doctor_id
order by
    total_fee desc;
--実行結果
|name|total_record|total_fee|avg_fee|cancell_rate|
|----|------------|---------|-------|------------|
|山田太郎|3|14000.0|4666.7|25.00%|
|佐藤健一|1|8000.0|8000.0|50.00%|
|鈴木花子|2|7500.0|3750.0|0.00%|
|高橋誠|1|6000.0|6000.0|0.00%|
|田中美咲|0|0.0|0.0|100.00%|





















































