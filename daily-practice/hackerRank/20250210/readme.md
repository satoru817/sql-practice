問題1

Samantha was tasked with calculating the average monthly salaries for all employees in the EMPLOYEES table, but did not realize her keyboard's  key was broken until after completing the calculation. She wants your help finding the difference between her miscalculation (using salaries with any zeros removed), and the actual average salary.

Write a query calculating the amount of error (i.e.:  average monthly salaries), and round it up to the next integer.



with zero_removed as (
    select
        id,
        cast(replace(cast(salary as char),'0','') as unsigned) as new_salary
    from
        employees
)
select
    ceil(avg(e.salary)-avg(z.new_salary))
from
    employees e
    inner join zero_removed z on z.id = e.id;

--コメント
round()とceil()の使い分けに注意
数字を処理するときには、文字列に変換してreplaceしてからまた数字に戻す作業が必要

問題2
Query the sum of Northern Latitudes (LAT_N) from STATION having values greater than  and less than . Truncate your answer to  decimal places.

Input Format

The STATION table is described as follows:

select
    truncate(sum(lat_n),4)
from
    station
where
    lat_n > 38.7880
    and lat_n < 137.2345;

truncate(),ceil(),round()の違いに注意
