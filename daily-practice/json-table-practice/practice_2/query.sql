SELECT
	doc.name,
	sp.specialty
FROM
	doctors doc
	INNER JOIN JSON_TABLE(
		doc.profile->'$.specialties','$[*]' 
		COLUMNS(
			specialty VARCHAR(255) PATH '$'
		) 
	)AS sp;

|name|specialty|
|----|---------|
|山田医師|内科       |
|山田医師|循環器科     |
|鈴木医師|小児科      |
|佐藤医師|外科       |
|佐藤医師|整形外科     |

SELECT
	doc.name,
	lang.primary_language,
	flang.foreign_language
FROM
	doctors doc
	INNER JOIN JSON_TABLE(
		doc.profile->'$.languages','$'
		COLUMNS(
			primary_language VARCHAR(255) PATH '$.primary'
		)
	) AS lang
	INNER JOIN JSON_TABLE(
		doc.profile->'$.languages.foreign','$[*]'
		COLUMNS(
			foreign_language VARCHAR(255) PATH '$'
		)
	) AS flang;

|name|primary_language|foreign_language|
|----|----------------|----------------|
|山田医師|日本語             |英語              |
|山田医師|日本語             |中国語             |
|鈴木医師|日本語             |英語              |

２つ目のINNERをLEFTに変えると

Error occurred during SQL query execution

Reason:
SQL Error [1064] [42000]: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '' at line 18

このエラーがでる。難しい。このMySQLのJSON_TABLEの特殊な制約はよくわかんない。

WITH doc_foreign_languages AS (
	SELECT
		doc.doctor_id,
		flang.foreign_language
	FROM
		doctors doc,
		JSON_TABLE(
			doc.profile->'$.languages.foreign','$[*]'
			COLUMNS(
				foreign_language VARCHAR(255) PATH '$'
			)
		) AS flang
)
SELECT
	doc.name,
	doc.profile->>'$.languages.primary' AS primary_language,
	dfl.foreign_language
FROM
	doctors doc
	LEFT JOIN doc_foreign_languages dfl ON dfl.doctor_id = doc.doctor_id;


このようにCTEを利用することで、INNER JOINのみしか利用できない制約は回避できる。

--結果
|name|primary_language|foreign_language|
|----|----------------|----------------|
|山田医師|日本語             |英語              |
|山田医師|日本語             |中国語             |
|鈴木医師|日本語             |英語              |
|佐藤医師|日本語             |                |



--問題：患者ごとの血圧測定記録を時系列で表示し、測定日ごとの投薬情報も合わせて表示するクエリを作成してください。
--
--期待される出力イメージ：
--```
--name     date        systolic  diastolic  medication_info
--山田太郎  2025-02-01  135       85        降圧剤A(10mg,朝食後), 降圧剤B(5mg,夕食後)
--山田太郎  2025-02-14  128       82        降圧剤A(10mg,朝食後), 降圧剤B(5mg,夕食後)
--鈴木花子  2025-02-01  142       88        降圧剤A(5mg,朝食後)
--鈴木花子  2025-02-14  138       86        降圧剤A(5mg,朝食後)
--```
--
--この問題では：
--1. JSON配列からの時系列データの展開
--2. 複数の情報の結合
--3. GROUP_CONCATによる情報の集約
--を実践できます。

WITH patient_medication_infos AS (
	SELECT
		p.patient_id,
		p.name,
		GROUP_CONCAT(CONCAT(mi.name,'(',mi.dosage,mi.timing,')') SEPARATOR',') AS medication_info
	FROM
		patients p
		INNER JOIN JSON_TABLE(
			p.medical_record->'$.medications','$[*]'
			COLUMNS(
				name VARCHAR(255) PATH '$.name',
				dosage VARCHAR(255) PATH '$.dosage',
				timing VARCHAR(255) PATH '$.timing'
			)
		) AS mi
	GROUP BY 
		p.patient_id,
		p.name
),
patient_blood_pressure_infos AS(
	SELECT
		p.patient_id,
		bi.measure_date,
		bi.systolic,
		bi.diastolic
	FROM
		patients p
		INNER JOIN JSON_TABLE(
			p.medical_record->'$.vitals.blood_pressure','$[*]'
			COLUMNS(
				measure_date VARCHAR(255) PATH '$.date',
				systolic VARCHAR(255) PATH '$.systolic',
				diastolic VARCHAR(255) PATH '$.diastolic'
			)
		)AS bi
)
SELECT
	pmi.name,
	pbpi.measure_date,
	pbpi.systolic,
	pbpi.diastolic,
	pmi.medication_info
FROM
	patient_medication_infos pmi
	LEFT JOIN patient_blood_pressure_infos pbpi 
		ON pbpi.patient_id = pmi.patient_id;

--実行結果
|name|measure_date|systolic|diastolic|medication_info           |
|----|------------|--------|---------|--------------------------|
|山田太郎|2025-02-01  |135     |85       |降圧剤A(10mg朝食後),降圧剤B(5mg夕食後)|
|山田太郎|2025-02-14  |128     |82       |降圧剤A(10mg朝食後),降圧剤B(5mg夕食後)|
|鈴木花子|2025-02-01  |142     |88       |降圧剤A(5mg朝食後)              |
|鈴木花子|2025-02-14  |138     |86       |降圧剤A(5mg朝食後)              |



