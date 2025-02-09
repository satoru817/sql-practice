question 1
Query the list of CITY names from STATION that either do not start with vowels or do not end with vowels. Your result cannot contain duplicates.

Input Format

The STATION table is described as follows:


--my answer

select
    distinct
        city
from
    station
where
    city not regexp '^[aeiouAEIOU]'
    OR city not regexp '[aeiouAEIOU]$';

--AIの改善提案
はい、以下のように書き換えることができます：

```sql
SELECT DISTINCT city
FROM station
WHERE city REGEXP '^[^aeiou]|[^aeiou]$';
```

主な改善点：
1. `[^aeiou]` で「母音以外」を表現（大文字小文字の区別が不要な場合）
2. `|` でOR条件を表現
3. 1つのREGEXPで条件を統合

必要に応じて大文字小文字も含める場合は：

```sql
SELECT DISTINCT city
FROM station
WHERE city REGEXP '^[^aeiouAEIOU]|[^aeiouAEIOU]$';
```

このように書くことで、より簡潔で読みやすいクエリになります。

問題2
Query the list of CITY names from STATION that either do not start with vowels or do not end with vowels. Your result cannot contain duplicates.

select
    distinct
        city
from
    station
where
    lower(city) regexp '^[^aeiou].+[^aeiou]$'

->>PASS
--コメント
[aeiou]の否定が[^aeiou]であることをすぐ使えるようにしたい。

問題3
Query the Name of any student in STUDENTS who scored higher than  Marks. Order your output by the last three characters of each name. If two or more students both have names ending in the same last three characters (i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID.

select
    name
from
    students
where
    marks > 75
order by
    right(name,3) asc,
    id asc;

--コメント
right(),left()の利用（カラム、文字数) に慣れよう。

問題4

	Submissions	Leaderboard	Discussions
P(R) represents a pattern drawn by Julia in R rows. The following pattern represents P(5):

* 
* * 
* * * 
* * * * 
* * * * *
Write a query to print the pattern P(20).


with recursive pre_table as (
    select
        1 as n,
        cast('* ' as char(40)) as mark
    union all
        SELECT 
            n+1,
            concat(mark,'* ')
        from
            pre_table
        where
            n < 20
)
select
    mark
from
    pre_table;


--コメント
castで大きくすることに注意。そうしないとdata too longが出る。

