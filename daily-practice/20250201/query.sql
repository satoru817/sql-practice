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

はい、2問目の要件を明確にします。
2問目の要件：2023年10月から2024年1月までの4ヶ月間における、診療科別の新規患者数を分析するクエリを作成してください。
求めるデータ

メインの表示項目

診療科名（department）
2023年10月の新規患者数
2023年11月の新規患者数
2023年12月の新規患者数
2024年1月の新規患者数
4ヶ月間の合計新規患者数


新規患者の定義

patientsテーブルのfirst_visit_dateがその月である患者

--私の解答(動かなかった)

with dep_month_stats as (
    select
        d.department,
        date_format(mr.visit_date,'%Y-%m') as month,
        count(
            distinct(
                case when date_format(p.first_visit_date,'%Y-%m')=date_format(mr.visit_date,'%Y-%m') then p.patient_id else NULL end
            )
        ) as first_visits
    from
        doctors d
        inner join medical_records mr on mr.doctor_id = d.doctor_id
        inner join patients p on p.patient_id = mr.patient_id
    group by
        d.department,
        date_format(mr.visit_date,'%Y-%m')
)
select
    department,
    case when month = '2023-10' 
        coalesce((select dms.first_visits from dep_month_stats dms where dms.department = department and dms.month = month),0) 
    as oct_2023,
    case when month = '2023-11' 
        coalesce((select dms.first_visits from dep_month_stats dms where dms.department = department and dms.month = month),0) 
    as nov_2023,
    case when month = '2023-12' 
        coalesce((select dms.first_visits from dep_month_stats dms where dms.department = department and dms.month = month),0) 
    as dec_2023,
    case when month = '2024-01' 
        coalesce((select dms.first_visits from dep_month_stats dms where dms.department = department and dms.month = month),0) 
    as jan_2024,
    sum(case when (month = '2023-10' or month = '2023-11' or month = '2023-12' or month = '2024-01') then first_visits else 0 end) as total_new_patients
from
    dep_month_stats
group by
    department;

--deepseekの解答

WITH dep_month_stats AS (
    SELECT
        d.department,
        DATE_FORMAT(mr.visit_date, '%Y-%m') AS month,
        COUNT(DISTINCT 
            CASE WHEN DATE_FORMAT(p.first_visit_date, '%Y-%m') = DATE_FORMAT(mr.visit_date, '%Y-%m') 
            THEN p.patient_id END
        ) AS first_visits
    FROM
        doctors d
        INNER JOIN medical_records mr ON mr.doctor_id = d.doctor_id
        INNER JOIN patients p ON p.patient_id = mr.patient_id
    GROUP BY
        d.department,
        DATE_FORMAT(mr.visit_date, '%Y-%m')
)
SELECT
    department,
    COALESCE(SUM(CASE WHEN month = '2023-10' THEN first_visits END) , 0) AS oct_2023,
    COALESCE(SUM(CASE WHEN month = '2023-11' THEN first_visits END)  , 0) AS nov_2023,
    COALESCE(SUM(CASE WHEN month = '2023-12' THEN first_visits END)  , 0) AS dec_2023,
    COALESCE(SUM(CASE WHEN month = '2024-01' THEN first_visits END) , 0) AS jan_2024,
    COALESCE(SUM(first_visits), 0) AS total_new_patients
FROM
    dep_month_stats
WHERE
    month BETWEEN '2023-10' AND '2024-01'
GROUP BY
    department;

--学んだこと
as year_monthはなぜかエラーを発生させた。ここをmonthにするとそのエラーは消えた　_　はエイリアスで使えないらしい。

最後のselect文で私はサブクエリを利用したが、これもエラーとなった。普通に集計関数とcase 式を利用したほうがきれいだ。SUMを利用しているが、これはMAXでもMINでもどれでも同じ結果を返す。

このクエリには複数の問題点があります。主な問題を箇条書きで説明します：

### 1. **CASE式の構文エラー**
```sql
case when dms.month = '2023-10' 
    coalesce(...)  -- THENが欠落している
```
**問題**：  
`CASE WHEN [条件] THEN [値] END` の構文が崩れています。`THEN` が完全に欠落しています。

**修正例**：
```sql
CASE 
    WHEN dms.month = '2023-10' THEN coalesce(...)
END
```

---

### 2. **サブクエリのロジックエラー**
```sql
(coalesce((select dms1.first_visits 
          from dep_month_stats dms1 
          where dms1.month = dms.month),0))
```
**問題**：  
- サブクエリが同じ月の全データを取得しようとしていますが、`department` の条件がありません
- 結果的に **複数行を返す可能性** がありエラーになります

**具体例**：  
内科の2023-10と外科の2023-10が両方存在する場合、サブクエリが複数行を返しエラーになります。

---

### 3. **GROUP BYの不整合**
```sql
GROUP BY dms.department
```
**問題**：  
SELECT句に `dms.month` が含まれていないため、**集約レベルが不整合** になります。月ごとのデータを横展開したい場合、月単位の集計はできません。

---

### 4. **パフォーマンス問題**
**問題**：  
- 同じCTEに対して複数回サブクエリを実行（4回のサブクエリ）
- 非効率で大規模データで深刻な速度低下を引き起こします

---

### 修正後のクエリ
```sql
WITH dep_month_stats AS (
    SELECT
        d.department,
        DATE_FORMAT(mr.visit_date, '%Y-%m') AS month,
        COUNT(DISTINCT 
            CASE WHEN DATE_FORMAT(p.first_visit_date, '%Y-%m') = DATE_FORMAT(mr.visit_date, '%Y-%m') 
            THEN p.patient_id END
        ) AS first_visits
    FROM
        doctors d
        INNER JOIN medical_records mr ON mr.doctor_id = d.doctor_id
        INNER JOIN patients p ON p.patient_id = mr.patient_id
    GROUP BY
        d.department,
        DATE_FORMAT(mr.visit_date, '%Y-%m')
)
SELECT
    department,
    COALESCE(SUM(CASE WHEN month = '2023-10' THEN first_visits END), 0) AS oct_2023,
    COALESCE(SUM(CASE WHEN month = '2023-11' THEN first_visits END), 0) AS nov_2023,
    COALESCE(SUM(CASE WHEN month = '2023-12' THEN first_visits END), 0) AS dec_2023,
    COALESCE(SUM(CASE WHEN month = '2024-01' THEN first_visits END), 0) AS jan_2024,
    COALESCE(SUM(first_visits), 0) AS total_new_patients
FROM
    dep_month_stats
WHERE
    month BETWEEN '2023-10' AND '2024-01'
GROUP BY
    department;
```

---

### **主な修正点**

1. **ピボット処理の改善**  
   - サブクエリではなく `SUM(CASE WHEN ...)` で条件付き集計
   - 例：`SUM(CASE WHEN month='2023-10' THEN first_visits END)`

2. **NULL値の扱い**  
   - `COALESCE()` でNULLを0に変換

3. **パフォーマンス最適化**  
   - WHERE句で期間を限定（`BETWEEN`）
   - CTEを1回だけ参照

4. **集約レベルの明確化**  
   - `GROUP BY department` のみで十分

---

### **期待される出力**
| department | oct_2023 | nov_2023 | dec_2023 | jan_2024 | total_new_patients |
|------------|----------|----------|----------|----------|--------------------|
| 内科       | 15       | 20       | 18       | 22       | 75                |
| 外科       | 10       | 12       | 9        | 15       | 46                |

---

### **追加検証が必要なポイント**
1. **初診患者の定義**  
   - `first_visit_date` と `visit_date` が厳密に同じ月か？
   - 例：`2023-10-31` vs `2023-11-01` の境界条件

2. **データ結合の正当性**  
   - `medical_records` に初診以外の記録が含まれる可能性
   - 患者と医師の紐付けが正しいか

3. **インデックスの有無**  
   - `visit_date` と `first_visit_date` にインデックスが必要





















































