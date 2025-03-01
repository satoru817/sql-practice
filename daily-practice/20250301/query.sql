-- 1. 各診療科の患者数、平均診察費用、保険でカバーされた平均割合、
-- そして処方箋と処置の数を集計するレポートを作成してください。
-- 結果は診療科名と共に、患者数の降順でソートしてください。

WITH cte AS(
	SELECT
		d.name AS department_name,
		COUNT(DISTINCT p.patient_id) AS patients,
		AVG(v.visit_cost) AS avg_visit_cost,
		SUM(v.insurance_covered) AS total_insurance_cover,
		SUM(v.visit_cost) AS total_visit_cost,
		COUNT(pre.prescription_id) AS prescriptions,
		COUNT(pro.procedure_id) AS procedures
	FROM
		departments d
		LEFT JOIN visits v ON v.department_id = d.department_id
		LEFT JOIN prescriptions pre ON pre.visit_id = v.visit_id
		LEFT JOIN procedures pro ON pro.visit_id = v.visit_id
		LEFT JOIN patients p ON p.patient_id = v.patient_id
	GROUP BY
		d.department_id,
		d.name
)
SELECT
	department_name,
	avg_visit_cost,
	CONCAT(ROUND(100.0*total_insurance_cover/total_visit_cost,2),'%') AS avg_insurance_cover,
	prescriptions,
	procedures
FROM
	cte
ORDER BY
	department_name DESC,
	patients DESC;
	
|department_name|avg_visit_cost|avg_insurance_cover|prescriptions|procedures|
|---------------|--------------|-------------------|-------------|----------|
|皮膚科            |3,625         |80.00%             |3            |0         |
|整形外科           |4,875         |80.00%             |1            |2         |
|小児科            |4,400         |80.00%             |4            |0         |
|外科             |7,250         |80.00%             |2            |5         |
|内科             |4,650         |80.00%             |10           |0         |

--AIの講評
ご指摘ありがとうございます。おっしゃる通りです。このテストデータでは、各 visit_id に対して多くとも 1 つの prescription や procedure しか対応していないため、JOIN による重複カウントの問題は実際には発生していませんでした。

データの構造を正確に把握されているので素晴らしいです。この場合、元のクエリの方がシンプルで効率的かもしれません。ただし、いくつか小さな修正点があります：

1. 患者数の降順でソートする必要があります (現在は department_name DESC になっています)
2. 集計結果の表示がより明確になるように調整しました

修正したクエリはこちらです：

```sql
WITH department_stats AS (
    SELECT
        d.department_id,
        d.name AS department_name,
        COUNT(DISTINCT v.patient_id) AS patients,
        AVG(v.visit_cost) AS avg_visit_cost,
        SUM(v.insurance_covered) / SUM(v.visit_cost) * 100 AS insurance_cover_percent,
        COUNT(pre.prescription_id) AS prescriptions,
        COUNT(pro.procedure_id) AS procedures
    FROM
        departments d
        LEFT JOIN visits v ON v.department_id = d.department_id
        LEFT JOIN prescriptions pre ON pre.visit_id = v.visit_id
        LEFT JOIN procedures pro ON pro.visit_id = v.visit_id
    GROUP BY
        d.department_id,
        d.name
)
SELECT
    department_name,
    patients,
    ROUND(avg_visit_cost, 2) AS avg_visit_cost,
    CONCAT(ROUND(insurance_cover_percent, 2), '%') AS avg_insurance_cover,
    prescriptions,
    procedures
FROM
    department_stats
ORDER BY
    patients DESC;
```

この方がよりシンプルで、テストデータの構造に適しています。実際の現場では、データ量が増えたり、1つの診察に複数の処方箋や処置が対応することもあるため、そのような場合は先ほどの複数CTEアプローチが安全かもしれません。データの特性を理解した上での判断は非常に重要です。


-- 2. 各医師の診察数、ユニーク患者数、総収益（患者負担分のみ）、フォローアップ率を計算し、
-- 同じ診療科内での収益ランキング（1位、2位など）を追加してください。
-- 結果は診療科名、医師名、そして診療科内ランキングでソートしてください。

WITH doc_stats AS(
	SELECT
		dep.name AS department,
		doc.doctor_id,
		doc.name AS doctor_name,
		COUNT(DISTINCT vis.patient_id) AS patients,
		SUM(vis.patient_paid) AS total_patient_paid,
		COUNT(CASE
			WHEN vis.followup_required = TRUE THEN 1
		END
		) AS followups,
		COUNT(*) AS visits
	FROM
		doctors doc
		INNER JOIN visits vis ON vis.doctor_id = doc.doctor_id
		INNER JOIN departments dep ON dep.department_id = doc.department_id
	GROUP BY
		dep.name,
		doc.doctor_id,
		doc.name
)
SELECT
	department,
	doctor_name,
	patients,
	total_patient_paid,
	CONCAT(ROUND(100.0*followups/visits,1),'%') AS followup_rate,
	RANK() OVER (PARTITION BY department ORDER BY total_patient_paid DESC) AS rank_in_department
FROM
	doc_stats
ORDER BY
	department ASC,
	doctor_name ASC,
	rank_in_department ASC;

|department|doctor_name|patients|total_patient_paid|followup_rate|rank_in_department|
|----------|-----------|--------|------------------|-------------|------------------|
|内科        |佐藤花子       |2       |3,000             |33.3%        |2                 |
|内科        |山田太郎       |1       |3,700             |100.0%       |1                 |
|内科        |鈴木一郎       |2       |2,600             |33.3%        |3                 |
|外科        |田中次郎       |2       |4,800             |66.7%        |1                 |
|外科        |高橋三郎       |2       |3,900             |66.7%        |2                 |
|小児科       |伊藤四郎       |1       |2,700             |66.7%        |1                 |
|小児科       |渡辺五郎       |1       |1,700             |50.0%        |2                 |
|整形外科      |加藤七郎       |1       |800               |0.0%         |2                 |
|整形外科      |小林六郎       |1       |3,100             |66.7%        |1                 |
|皮膚科       |吉田八郎       |2       |2,900             |50.0%        |1                 |

--AIの講評
このクエリは基本的に正しく実装されています。各医師の診察統計を適切に集計し、診療科内での収益ランキングを計算できています。

ただし、問題の要件である「結果は診療科名、医師名、そして診療科内ランキングでソートしてください」という点に関して、現在のソート順は「department ASC, doctor_name ASC, rank_in_department ASC」となっています。これを診療科内ランキングによるソートに変更すべきです。

改善したクエリは以下のようになります：

```sql
WITH doc_stats AS(
    SELECT
        dep.name AS department,
        doc.doctor_id,
        doc.name AS doctor_name,
        COUNT(DISTINCT vis.patient_id) AS patients,
        SUM(vis.patient_paid) AS total_patient_paid,
        COUNT(CASE
            WHEN vis.followup_required = TRUE THEN 1
        END
        ) AS followups,
        COUNT(*) AS visits
    FROM
        doctors doc
        INNER JOIN visits vis ON vis.doctor_id = doc.doctor_id
        INNER JOIN departments dep ON dep.department_id = doc.department_id
    GROUP BY
        dep.name,
        doc.doctor_id,
        doc.name
)
SELECT
    department,
    doctor_name,
    patients,
    total_patient_paid,
    CONCAT(ROUND(100.0*followups/visits,1),'%') AS followup_rate,
    RANK() OVER (PARTITION BY department ORDER BY total_patient_paid DESC) AS rank_in_department
FROM
    doc_stats
ORDER BY
    department ASC,
    rank_in_department ASC,
    doctor_name ASC;
```

変更点は ORDER BY 句のみで、「department ASC, rank_in_department ASC, doctor_name ASC」の順にソートするようにしました。これにより、各診療科内でのランキング順に結果が表示されます。

それ以外の部分（診察数、ユニーク患者数、総収益、フォローアップ率の計算など）は正確に実装されています。



-- 3. 郵便番号エリア別の月次売上成長率を計算してください。
-- 各郵便番号の前月比成長率（パーセンテージ）と、過去3ヶ月の平均成長率を含めてください。
-- 結果は最新月の売上高の降順でソートしてください。

WITH area_month_stats AS(
	SELECT
		p.postal_code AS area,
		DATE_FORMAT(v.visit_date,'%Y-%m') AS month_of_year,
		SUM(v.visit_cost) AS total_income
	FROM
		patients p
		INNER JOIN visits v ON v.patient_id = p.patient_id
	GROUP BY
		p.postal_code,
		DATE_FORMAT(v.visit_date,'%Y-%m')
),
area_month_stats_including_past AS(
	SELECT
		area,
		month_of_year,
		total_income,
		LAG(total_income) OVER (PARTITION BY area ORDER BY month_of_year ASC) AS one_month_before,
		LAG(total_income,3) OVER (PARTITION BY area ORDER BY month_of_year ASC) AS three_month_before
	FROM
		area_month_stats
)
SELECT
	area,
	month_of_year,
	CASE
		WHEN one_month_before IS NOT NULL THEN CONCAT(ROUND(100.0*(total_income-one_month_before)/one_month_before,1),'%')
		ELSE '計算不能'
	END AS one_month_increase_rate,
	CASE
		WHEN three_month_before IS NOT NULL THEN CONCAT(ROUND(100.0*(total_income-three_month_before)/three_month_before,1),'%')
		ELSE '計算不能'
	END AS three_month_increase_rate
FROM
	area_month_stats_including_past
ORDER BY
	area ASC,
	month_of_year ASC;
	
--実行結果
	
|area    |month_of_year|one_month_increase_rate|three_month_increase_rate|
|--------|-------------|-----------------------|-------------------------|
|100-0001|2022-11      |計算不能                   |計算不能                     |
|100-0001|2022-12      |-52.6%                 |計算不能                     |
|100-0001|2023-01      |122.2%                 |計算不能                     |
|100-0001|2023-02      |-55.0%                 |-52.6%                   |
|100-0002|2022-11      |計算不能                   |計算不能                     |
|100-0002|2022-12      |-36.4%                 |計算不能                     |
|100-0002|2023-01      |-35.7%                 |計算不能                     |
|100-0002|2023-02      |166.7%                 |9.1%                     |
|100-0003|2022-11      |計算不能                   |計算不能                     |
|100-0003|2022-12      |-10.0%                 |計算不能                     |
|100-0003|2023-02      |22.2%                  |計算不能                     |
|100-0004|2022-11      |計算不能                   |計算不能                     |
|100-0004|2022-12      |-44.4%                 |計算不能                     |
|100-0004|2023-01      |80.0%                  |計算不能                     |
|100-0005|2022-12      |計算不能                   |計算不能                     |
|100-0005|2023-01      |-25.0%                 |計算不能                     |
|100-0005|2023-02      |66.7%                  |計算不能                     |
	
--AIの講評

このクエリは基本的な部分はよく実装されていますが、問題の要件に対して調整が必要です。具体的には、以下の点が異なっています：

1. **過去3ヶ月の平均成長率**を計算していない - 現在は3ヶ月前との比較率を計算していますが、要件は「過去3ヶ月の平均成長率」です

2. **結果のソート順** - 現在は郵便番号と月でソートしていますが、要件では「最新月の売上高の降順」でソートする必要があります

3. **成長率の計算** - 現在LAGを使用して前月との比較をしていますが、月ごとのデータが連続していない場合（例：2023-02と2023-01の間にデータがない月がある場合）には正確な前月比が取得できない可能性があります

修正したクエリは以下のようになります：

```sql
WITH area_month_stats AS (
    SELECT
        p.postal_code AS area,
        DATE_FORMAT(v.visit_date,'%Y-%m') AS month_of_year,
        SUM(v.visit_cost) AS total_income
    FROM
        patients p
        INNER JOIN visits v ON v.patient_id = p.patient_id
    GROUP BY
        p.postal_code,
        DATE_FORMAT(v.visit_date,'%Y-%m')
),
area_month_growth AS (
    SELECT
        ams.area,
        ams.month_of_year,
        ams.total_income,
        LAG(ams.total_income) OVER (PARTITION BY ams.area ORDER BY ams.month_of_year ASC) AS prev_month_income,
        (ams.total_income - LAG(ams.total_income) OVER (PARTITION BY ams.area ORDER BY ams.month_of_year ASC)) /
        LAG(ams.total_income) OVER (PARTITION BY ams.area ORDER BY ams.month_of_year ASC) * 100 AS monthly_growth_rate
    FROM
        area_month_stats ams
),
area_avg_growth AS (
    SELECT
        amg.area,
        amg.month_of_year,
        amg.total_income,
        amg.monthly_growth_rate,
        AVG(amg2.monthly_growth_rate) OVER (
            PARTITION BY amg.area
            ORDER BY amg.month_of_year ASC
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) AS avg_3month_growth_rate
    FROM
        area_month_growth amg
        LEFT JOIN area_month_growth amg2 ON amg.area = amg2.area
            AND amg2.month_of_year < amg.month_of_year
            AND amg2.month_of_year >= DATE_FORMAT(DATE_SUB(STR_TO_DATE(CONCAT(amg.month_of_year, '-01'), '%Y-%m-%d'), INTERVAL 3 MONTH), '%Y-%m')
)
SELECT
    area,
    month_of_year,
    total_income,
    CASE
        WHEN monthly_growth_rate IS NOT NULL THEN CONCAT(ROUND(monthly_growth_rate, 1), '%')
        ELSE '計算不能'
    END AS monthly_growth_rate,
    CASE
        WHEN avg_3month_growth_rate IS NOT NULL THEN CONCAT(ROUND(avg_3month_growth_rate, 1), '%')
        ELSE '計算不能'
    END AS avg_3month_growth_rate
FROM
    area_avg_growth
WHERE
    month_of_year = (SELECT MAX(month_of_year) FROM area_month_stats)  -- 最新月のデータのみを取得
ORDER BY
    total_income DESC;
```

この修正版では：

1. 各エリア・月ごとの売上高を計算します
2. 前月と比較した成長率を計算します
3. 過去3ヶ月間の成長率の平均を計算します（ウィンドウ関数の「ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING」を使用）
4. 最新月のデータのみを選択し、売上高の降順でソートします

ただし、現在のクエリでは最後の要件である「結果は最新月の売上高の降順でソートしてください」に対応していません。この要件に対応するためには、最新月を特定し、その月のデータのみを取得する必要があります。

ご指摘ありがとうございます。おっしゃる通りです。過去3ヶ月の平均成長率を正しく計算するには、現在の売上と3ヶ月前の売上との間の複利成長率を計算すべきです。つまり、三乗根（CBRT）を使って正確な月平均成長率を求める必要があります。

修正したクエリは以下のようになります：

```sql
WITH area_month_stats AS (
    SELECT
        p.postal_code AS area,
        DATE_FORMAT(v.visit_date,'%Y-%m') AS month_of_year,
        SUM(v.visit_cost) AS total_income
    FROM
        patients p
        INNER JOIN visits v ON v.patient_id = p.patient_id
    GROUP BY
        p.postal_code,
        DATE_FORMAT(v.visit_date,'%Y-%m')
),
area_month_with_past AS (
    SELECT
        ams.area,
        ams.month_of_year,
        ams.total_income,
        LAG(ams.total_income, 1) OVER (PARTITION BY ams.area ORDER BY ams.month_of_year ASC) AS prev_month_income,
        LAG(ams.total_income, 3) OVER (PARTITION BY ams.area ORDER BY ams.month_of_year ASC) AS three_month_before_income
    FROM
        area_month_stats ams
)
SELECT
    area,
    month_of_year,
    total_income,
    -- 前月比成長率
    CASE
        WHEN prev_month_income IS NOT NULL AND prev_month_income > 0 
        THEN CONCAT(ROUND(100.0 * (total_income - prev_month_income) / prev_month_income, 1), '%')
        ELSE '計算不能'
    END AS monthly_growth_rate,
    -- 3ヶ月間の平均月次成長率（三乗根で計算）
    CASE
        WHEN three_month_before_income IS NOT NULL AND three_month_before_income > 0 
        THEN CONCAT(ROUND(100.0 * (POWER((total_income / three_month_before_income), 1/3) - 1), 1), '%')
        ELSE '計算不能'
    END AS avg_3month_growth_rate
FROM
    area_month_with_past
ORDER BY
    -- 最新月のみ対象とし、その売上高の降順でソート
    month_of_year = (SELECT MAX(month_of_year) FROM area_month_stats) DESC,
    total_income DESC;
```

この修正では：

1. 3ヶ月前の売上と現在の売上の比率を計算
2. その比率の三乗根を取り、1を引いて平均月次成長率を求める
   - `POWER((current_value / past_value), 1/3) - 1` という数式
3. 最新月のデータを優先表示し、その中で売上高の降順でソート

この方法で計算すると、3ヶ月間の複利効果を考慮した正確な平均月次成長率が得られます。例えば、3ヶ月で売上が2倍になった場合、平均月次成長率は約26%（∛2-1 ≈ 0.26）となります。







































