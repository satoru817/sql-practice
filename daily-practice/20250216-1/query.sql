1. 診療科ごとの統計情報を出力してください：
   - 診療科名
   - 所属医師数
   - 予約件数
   - 実際の受診件数（status = 'completed'のみ）
   - 診療科の特殊機器の有無（X線, MRI, CTの各機器の有無をカンマ区切りで表示）
   条件：アクティブな診療科（is_active = true）のみを対象とし、予約件数順にソート

特殊機器に関するところが難しそう。とりあえずこれに関して実験
SELECT
	d.name as department_name,
	CONCAT_WS(
		',',
		(CASE WHEN JSON_CONTAINS(d.settings,'{"has_xray":true}') THEN 'X線有り'　ELSE 'X線無し' END),
		(CASE WHEN JSON_CONTAINS(d.settings,'{"has_mri":true}') THEN 'MRI有り'　ELSE 'MRI無し'　END),
		(CASE WHEN JSON_CONTAINS(d.settings,'{"has_ct":true}') THEN 'CT有り'　ELSE 'CT無し'　END)
	) AS setting
FROM 
	departments d;

これで行けると思ったが、エラー。全角スペースが入っていた。全角スペースの間違いは本当に気づきにくい。。。

--修正版

SELECT
	d.name as department_name,
	CONCAT_WS(
		',',
		CASE WHEN JSON_CONTAINS(d.settings,'{"has_xray":true}') THEN 'X線有り' ELSE 'X線無し' END,
		CASE WHEN JSON_CONTAINS(d.settings,'{"has_mri":true}') THEN 'MRI有り' ELSE 'MRI無し' END,
		CASE WHEN JSON_CONTAINS(d.settings,'{"has_ct":true}') THEN 'CT有り' ELSE 'CT無し' END
	) AS setting
FROM 
	departments d;

--実行結果

|department_name|setting        |
|---------------|---------------|
|内科             |X線有り,MRI無し,CT無し|
|小児科            |X線無し,MRI無し,CT無し|
|整形外科           |X線有り,MRI有り,CT無し|
|歯科             |X線無し,MRI無し,CT無し|


これでOK.

じゃあ、答えを書こう。

SELECT
	dep.name as department_name,
	CONCAT_WS(
		',',
		CASE WHEN JSON_CONTAINS(dep.settings,'{"has_xray":true}') THEN 'X線有り' ELSE 'X線無し' END,
		CASE WHEN JSON_CONTAINS(dep.settings,'{"has_mri":true}') THEN 'MRI有り' ELSE 'MRI無し' END,
		CASE WHEN JSON_CONTAINS(dep.settings,'{"has_ct":true}') THEN 'CT有り' ELSE 'CT無し' END
	) AS setting,
	COUNT(DISTINCT doc.doctor_id) AS doctors,
	COUNT(app.appointment_id) AS appointments,
	COUNT(CASE WHEN app.status='completed' THEN app.appointment_id END) AS real_appointments
FROM 
	departments dep
	INNER JOIN doctors doc ON doc.department_id = dep.department_id
	INNER JOIN appointments app ON app.doctor_id = doc.doctor_id
WHERE
	dep.is_active=true
GROUP BY
	dep.name,
	dep.department_id;

--実行結果
|department_name|setting        |doctors|appointments|real_appointments|
|---------------|---------------|-------|------------|-----------------|
|内科             |X線有り,MRI無し,CT無し|2      |3           |3                |
|小児科            |X線無し,MRI無し,CT無し|1      |1           |0                |





2. 医師ごとの受診実績を分析してください：
   - 医師名
   - 診療科名
   - 保有資格数（specialties.certifiedの配列の要素数）
   - 対応可能言語数（specialties.languagesの配列の要素数）
   - 主な症状の集計（medical_notes.primary_symptomの出現回数）
   条件：完了した予約（status = 'completed'）のみを対象とし、JSON_TABLE等は使用せず実装してください
