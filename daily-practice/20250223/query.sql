-- 1. 各診療科について以下の情報を集計してください：
--    - 診療科名
--    - 保有する医療機器（カンマ区切りで「X線,MRI,CT,超音波」のような形式）
--    - 所属医師数
--    - 予約総数
--    - 完了した予約数
--    - キャンセル率（パーセント表示で小数点2桁まで。予約が0件の場合は"0.00%"と表示）

SELECT
	dep.name as department_name,
	CONCAT_WS(',',
		CASE WHEN dep.settings->>'$.has_xray'='true' THEN 'X線' END,
		CASE WHEN dep.settings->>'$.has_mri'='true' THEN 'MRI' END,
		CASE WHEN dep.settings->>'$.has_ct'='true' THEN 'CT' END,
		CASE WHEN dep.settings->>'$.has_ultrasound'='true' THEN '超音波' END
	) AS setting,
	COUNT(DISTINCT doc.doctor_id) AS doctors,
	COUNT(app.appointment_id) AS appointments,
	COUNT(CASE WHEN app.status='completed' THEN 1 END) AS completed_appointments,
	CASE 
		WHEN COUNT(app.appointment_id) = 0 THEN '0.00%'
		ELSE CONCAT(ROUND(COUNT(CASE WHEN app.status='cancelled' THEN 1 END)*100.0/COUNT(app.appointment_id),2),'%')
	END AS cancell_rate
FROM 
	departments dep
	LEFT JOIN doctors doc ON doc.department_id = dep.department_id
	LEFT JOIN appointments app ON app.doctor_id = doc.doctor_id
GROUP BY
	dep.department_id,
	dep.name;


--実行結果
|department_name|setting      |doctors|appointments|completed_appointments|cancell_rate|
|---------------|-------------|-------|------------|----------------------|------------|
|内科             |X線,CT,超音波    |2      |5           |3                     |20.00%      |
|整形外科           |X線,MRI,CT,超音波|2      |4           |3                     |25.00%      |
|小児科            |X線,超音波       |1      |2           |1                     |50.00%      |
|眼科             |             |1      |2           |1                     |0.00%       |


-- 2. 各医師について以下の情報を分析してください：
--    - 医師名
--    - 所属診療科
--    - 資格と対応言語（"資格：内科, 循環器 | 言語：英語, 中国語" のような形式）
--    - 上位3つの主要症状（診察完了した予約の medical_notes から primary_symptom を抽出し、頻度順で最大3つをカンマ区切り）
--    - 予約完了率（パーセント表示で小数点2桁まで。予約が0件の場合は"0.00%"と表示）
--    - 完了した予約数

--まずJSONの処理。JSON_TABLEにまだ慣れていない。

SELECT
	doc.name,
	CONCAT('資格:',GROUP_CONCAT(DISTINCT ct.certified SEPARATOR ','),' | 言語:',GROUP_CONCAT(DISTINCT lg.lang SEPARATOR ',')) AS specialties
FROM
	doctors doc
	INNER JOIN 
		JSON_TABLE(
			JSON_EXTRACT(doc.specialties,'$.certified'),
			'$[*]' COLUMNS (
				certified VARCHAR(255) PATH '$'
			)
		) AS ct
	INNER JOIN
		JSON_TABLE(
			JSON_EXTRACT(doc.specialties,'$.languages'),
			'$[*]' COLUMNS(
				lang VARCHAR(255) PATH '$'
			)
		) AS lg
GROUP BY
	doc.name;

--結果。
|name|specialties               |
|----|--------------------------|
|佐藤健一|資格:リハビリテーション,整形外科 | 言語:英語 |
|山田太郎|資格:内科,循環器 | 言語:中国語,英語     |
|田中美咲|資格:スポーツ医学,整形外科 | 言語:英語,韓国語|
|鈴木花子|資格:内科,糖尿病 | 言語:英語         |
|高橋優子|資格:アレルギー,小児科 | 言語:英語      |


--ここまでは　上手くいった。
-- 2. 各医師について以下の情報を分析してください：
--    - 医師名
--    - 所属診療科
--    - 資格と対応言語（"資格：内科, 循環器 | 言語：英語, 中国語" のような形式）
--    - 上位3つの主要症状（診察完了した予約の medical_notes から primary_symptom を抽出し、頻度順で最大3つをカンマ区切り）
--    - 予約完了率（パーセント表示で小数点2桁まで。予約が0件の場合は"0.00%"と表示）
--    - 完了した予約数
WITH doc_infos AS(
	SELECT
		doc.name AS doctor_name,
		doc.doctor_id,
		CONCAT('資格:',GROUP_CONCAT(DISTINCT ct.certified SEPARATOR ','),' | 言語:',GROUP_CONCAT(DISTINCT lg.lang SEPARATOR ',')) AS specialties,
		dep.name AS department_name
	FROM
		doctors doc
		INNER JOIN departments dep ON doc.department_id = dep.department_id
		INNER JOIN 
			JSON_TABLE(
				JSON_EXTRACT(doc.specialties,'$.certified'),
				'$[*]' COLUMNS (
					certified VARCHAR(255) PATH '$'
				)
			) AS ct
		INNER JOIN
			JSON_TABLE(
				JSON_EXTRACT(doc.specialties,'$.languages'),
				'$[*]' COLUMNS(
					lang VARCHAR(255) PATH '$'
				)
			) AS lg
	GROUP BY
		doc.doctor_id,
		doc.name,
		dep.name
),
doc_symptom_dists AS (
	SELECT
		doc.doctor_id,
		app.medical_notes->>'$.primary_symptom' AS symptom,
		COUNT(*) AS symptom_count
	FROM
		doctors doc
		INNER JOIN appointments app ON app.doctor_id = doc.doctor_id
	GROUP BY
		doc.doctor_id,
		app.medical_notes->>'$.primary_symptom'
),
doc_symptom_ranks AS (
	SELECT
		doctor_id,
		symptom,
		RANK() OVER (PARTITION BY doctor_id ORDER BY symptom_count DESC) AS symp_rank
	FROM
		doc_symptom_dists 
),
doc_top_symptoms AS(
	SELECT
		doctor_id,
		GROUP_CONCAT(symptom ORDER BY symp_rank ASC SEPARATOR ',' ) AS top_symptom
	FROM
		doc_symptom_ranks 
	WHERE
		symp_rank <= 3
	GROUP BY
		doctor_id
),
doc_app_stats AS (
	SELECT
		doc.doctor_id,
		COUNT(*) AS total_appointments,
		COUNT(CASE WHEN app.status='completed' THEN 1 END) AS completed_appointments
	FROM
		doctors doc
		INNER JOIN appointments app ON app.doctor_id = doc.doctor_id
	GROUP BY
		doc.doctor_id
),
doc_app_infos AS (
	SELECT
		doctor_id,
		CASE
			WHEN total_appointments = 0 THEN '0.00%'
			ELSE CONCAT(ROUND(completed_appointments*100.0/total_appointments,2),'%') 
		END AS completion_rate,
		completed_appointments
	FROM
		doc_app_stats
)
SELECT
	di.doctor_name,
	di.department_name,
	di.specialties,
	dts.top_symptom,
	dai.completion_rate,
	dai.completed_appointments
FROM
	doc_infos di
	LEFT JOIN doc_top_symptoms dts ON dts.doctor_id = di.doctor_id
	LEFT JOIN doc_app_infos dai ON dai.doctor_id = di.doctor_id;

--結果

|doctor_name|department_name|specialties               |top_symptom|completion_rate|completed_appointments|
|-----------|---------------|--------------------------|-----------|---------------|----------------------|
|山田太郎       |内科             |資格:内科,循環器 | 言語:中国語,英語     |発熱,めまい,頭痛  |66.67%         |2                     |
|鈴木花子       |内科             |資格:内科,糖尿病 | 言語:英語         |高血圧,糖尿病    |50.00%         |1                     |
|佐藤健一       |整形外科           |資格:リハビリテーション,整形外科 | 言語:英語 |膝の痛み,腰痛    |50.00%         |1                     |
|田中美咲       |整形外科           |資格:スポーツ医学,整形外科 | 言語:英語,韓国語|捻挫,肩こり     |100.00%        |2                     |
|高橋優子       |小児科            |資格:アレルギー,小児科 | 言語:英語      |咳,発熱       |50.00%         |1                     |


--AIの採点

クエリの実装、とても良くできています。いくつかの改善点や最適化のポイントについてコメントさせていただきます：

### 診療科の集計について - 優れている点
1. `CONCAT_WS`の使用
   - CASEとCONCAT_WSの組み合わせで、余分なカンマを避けつつ医療機器を結合
   - 設備がない場合も適切に処理

2. LEFT JOINの適切な使用
   - 予約や医師が存在しない診療科も漏れなく表示
   - COUNT(DISTINCT)での医師数カウント

### 医師の分析について - 優れている点
1. CTEの効果的な使用
   - 複雑なクエリを論理的な単位に分割
   - 可読性と保守性の向上
   - 中間結果の再利用

2. JSON_TABLEの適切な使用
   - 配列データの展開
   - GROUP_CONCATとの組み合わせ

### 改善の提案

1. パフォーマンス最適化
```sql
-- JSON_TABLEでの結合を1回にまとめる
JSON_TABLE(
    specialties,
    '$' COLUMNS(
        NESTED PATH '$.certified[*]' COLUMNS(certified VARCHAR(255) PATH '$'),
        NESTED PATH '$.languages[*]' COLUMNS(lang VARCHAR(255) PATH '$')
    )
) AS jt
```

2. 症状の集計
```sql
-- WHEREでstatusを絞り込んでから集計
WHERE app.status = 'completed'
```

3. NULL値の処理
```sql
-- 設備なしの表示を改善
COALESCE(NULLIF(settings,''), 'なし') AS settings
```

全体的に非常によく考えられた実装です。特にJSONデータの処理とCTEの使用が効果的です。

--JSON_TABLEの扱いが未だによくわからん。。。


		


