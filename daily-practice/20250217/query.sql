-- 1. 診療科別の統計情報を出力するクエリを作成してください。
-- - 診療科名
-- - 保有設備の一覧（カンマ区切りの文字列として。例："X線,MRI"）
-- - 所属医師数
-- - 予約総数
-- - 完了済み予約数
-- - 予約のキャンセル率（パーセンテージ）


WITH dept_stats AS (
	SELECT
		dep.name,
		CONCAT_WS(
			',',
			CASE WHEN JSON_CONTAINS(dep.settings,'{"has_xray":true}') THEN 'X線' ELSE NULL END,
			CASE WHEN JSON_CONTAINS(dep.settings,'{"has_mri":true}') THEN 'MRI' ELSE NULL END,
			CASE WHEN JSON_CONTAINS(dep.settings,'{"has_ct":true}') THEN 'CT' ELSE NULL END,
			CASE WHEN JSON_CONTAINS(dep.settings,'{"has_ultrasound":true}') THEN '超音波' ELSE NULL END
		) AS settings,
		COUNT(DISTINCT doc.doctor_id) AS doctors,
		COUNT(app.appointment_id) AS appointments,
		COUNT(CASE WHEN app.status='completed' THEN 1 END) AS completed_appointments,
		COUNT(CASE WHEN app.status='cancelled' THEN 1 END) AS cancelled_appointments
	FROM
		departments dep
		LEFT JOIN doctors doc ON doc.department_id = dep.department_id
		LEFT JOIN appointments app ON app.doctor_id = doc.doctor_id
	GROUP BY
		dep.department_id,
		dep.settings
)
SELECT
	ds.name AS department_name,
	ds.settings,
	ds.doctors,
	ds.appointments,
	ds.completed_appointments,
	CONCAT(ROUND(100.0*ds.cancelled_appointments/ds.appointments,2),'%') AS cancellation_rate
FROM
	dept_stats ds;

--実行結果
|department_name|settings     |doctors|appointments|completed_appointments|cancellation_rate|
|---------------|-------------|-------|------------|----------------------|-----------------|
|内科             |X線,CT,超音波    |2      |5           |3                     |20.00%           |
|整形外科           |X線,MRI,CT,超音波|2      |4           |3                     |25.00%           |
|小児科            |X線,超音波       |1      |2           |1                     |50.00%           |
|眼科             |             |1      |2           |1                     |0.00%            |



--不思議なこと
こんかい、GROUP BYにdep.nameを含めていなかったのに、正常に値を取得できた。これについてAIに質問した。

--AIの解答

そうですね。これは実は重要な観察です。

このケースで動いた理由は以下の通りです：

1. `department_id` は Primary Key として設定されています
2. `name` は `department_id` に対して関数従属性があります（department_idが決まれば必ずnameも一意に決まる）
3. MySQLは、GROUP BY句に主キーが含まれている場合、その主キーに関数従属する他のカラムの選択を許可します

しかし、これは MySQL の特殊な動作であり、標準SQLでは認められていません。また、他のDBMS（PostgreSQLなど）ではエラーとなります。

より厳密なSQLを書くためには：
```sql
GROUP BY
    dep.department_id,
    dep.name,
    dep.settings
```

このように、SELECT句で選択している非集約カラムは明示的にGROUP BYに含めるべきです。これにより：

1. SQLの標準規格に準拠
2. コードの意図が明確
3. 他のDBMSでも動作する移植性の高いコード

となります。

先ほどのクエリが動作したのは便利ですが、移植性や保守性を考慮すると、明示的にGROUP BYに含める方が良いプラクティスとされています。


--MySQLだけの特殊な動きらしい。ミスのおかげで発見できた。

--AIの総合的な批評
クエリの実装は良く考えられていますが、いくつかの改善点を提案させていただきます：

1. JSONの処理について
```sql
-- 現在の実装
JSON_CONTAINS(dep.settings,'{"has_xray":true}')

-- より効率的な実装
dep.settings->>'$.has_xray' = 'true'
```
この方が直接的に値にアクセスでき、パフォーマンスが向上する可能性があります。

2. キャンセル率の計算
現在の実装では予約が0件の場合にエラーとなる可能性があります。以下のように改善できます：
```sql
CASE 
    WHEN ds.appointments = 0 THEN '0.00%'
    ELSE CONCAT(ROUND(100.0*ds.cancelled_appointments/ds.appointments,2),'%')
END AS cancellation_rate
```

3. GROUP BY句の改善
```sql
-- 現在の実装
GROUP BY
    dep.department_id,
    dep.settings

-- より明確な実装
GROUP BY
    dep.department_id,
    dep.name,
    dep.settings
```
name も GROUP BY に含めることで、より意図が明確になります。

改善したクエリを提案させていただきます：

```sql
WITH dept_stats AS (
    SELECT
        dep.department_id,
        dep.name,
        CONCAT_WS(
            ',',
            CASE WHEN dep.settings->>'$.has_xray' = 'true' THEN 'X線' END,
            CASE WHEN dep.settings->>'$.has_mri' = 'true' THEN 'MRI' END,
            CASE WHEN dep.settings->>'$.has_ct' = 'true' THEN 'CT' END,
            CASE WHEN dep.settings->>'$.has_ultrasound' = 'true' THEN '超音波' END
        ) AS settings,
        COUNT(DISTINCT doc.doctor_id) AS doctors,
        COUNT(app.appointment_id) AS appointments,
        COUNT(CASE WHEN app.status = 'completed' THEN 1 END) AS completed_appointments,
        COUNT(CASE WHEN app.status = 'cancelled' THEN 1 END) AS cancelled_appointments
    FROM
        departments dep
        LEFT JOIN doctors doc ON doc.department_id = dep.department_id
        LEFT JOIN appointments app ON app.doctor_id = doc.doctor_id
    GROUP BY
        dep.department_id,
        dep.name,
        dep.settings
)
SELECT
    ds.name AS department_name,
    COALESCE(NULLIF(ds.settings,''), 'なし') AS settings,
    ds.doctors,
    ds.appointments,
    ds.completed_appointments,
    CASE 
        WHEN ds.appointments = 0 THEN '0.00%'
        ELSE CONCAT(ROUND(100.0*ds.cancelled_appointments/ds.appointments,2),'%')
    END AS cancellation_rate
FROM
    dept_stats ds;
```

主な改善点：
1. JSONアクセスの最適化
2. 0件の場合のエラー処理
3. 設備なしの場合の表示改善（'なし'と表示）
4. GROUP BY句の明確化

これらの改善により、より堅牢で保守性の高いクエリになりました。2番目の問題に進む前に、この改善についてご意見をいただけますでしょうか？






-- 申し訳ありません。問題で「月間の予約完了率」と「診療完了数」を要求していましたが、より明確に説明すべきでした。
-- 
-- 1. 診療完了率（より正確な定義）
-- - その月の予約総数のうち、status = 'completed' となった予約の割合
-- - 例：10件の予約のうち8件が完了 → 80%
-- - キャンセルされた予約も分母に含める
-- 
-- 計算式：
-- ```sql
-- (その月の完了した予約数 / その月の全予約数) * 100
-- ```
-- 
-- 2. 診療完了数
-- - 単純にstatus = 'completed'の予約の合計数
-- 
-- では問題2を書き換えさせていただきます：
-- 
-- 以下のレポートを作成してください：
-- - 医師名
-- - 診療科名
-- - 資格・言語能力の一覧（"資格：内科, 循環器 | 言語：英語, 中国語" の形式）
-- - 主な症状のTOP3（medical_notesから抽出、頻度順）
-- - 予約完了率（completedの予約数/全予約数）
-- - 完了した診療の総数


とりあえず、資格・言語能力の一覧を取得する方法を考える。JSON_TABLEでJSON配列を展開しておく必要がある。


SELECT
    d.doctor_id,
    d.name,
    GROUP_CONCAT(DISTINCT ct.certified SEPARATOR ', ') AS certified_specialties,
    GROUP_CONCAT(DISTINCT lg.lang SEPARATOR ',') AS languages
FROM
    doctors d
INNER JOIN
    JSON_TABLE(
        JSON_EXTRACT(d.specialties, '$.certified'),
        '$[*]' COLUMNS(
            certified VARCHAR(255) PATH '$'
        )
    ) AS ct
INNER JOIN
	JSON_TABLE(
		d.specialties->'$.languages',
		'$[*]' COLUMNS(
			lang VARCHAR(255) PATH '$'
		)
	) AS lg
GROUP BY
    d.doctor_id, d.name;

--JSON_TABLE関数がよくわからない

|id |order_details                                                 |
|---|--------------------------------------------------------------|
|1  |"{\"price\": 10.99, \"product\": \"book\", \"quantity\": 2}"  |
|2  |"{\"price\": 500.0, \"product\": \"phone\", \"quantity\": 1}" |
|3  |"{\"price\": 800.0, \"product\": \"laptop\", \"quantity\": 1}"|

こんなテーブルがあったとき、

SELECT
	jt.*
FROM
	orders o
	INNER JOIN 
	JSON_TABLE(
		o.order_details,'$'
		COLUMNS(
			product VARCHAR(255) PATH '$.product',
			quantity INT PATH '$.quantity',
			price decimal(10,2) PATH '$.price'
		) 
	) AS jt;

これで、

|product|quantity|price|
|-------|--------|-----|
|book   |2       |10.99|
|phone  |1       |500  |
|laptop |1       |800  |


こんな結果を得られる。


-- 以下のレポートを作成してください：
-- - 医師名
-- - 診療科名
-- - 資格・言語能力の一覧（"資格：内科, 循環器 | 言語：英語, 中国語" の形式）
-- - 主な症状のTOP3（medical_notesから抽出、頻度順）
-- - 予約完了率（completedの予約数/全予約数）
-- - 完了した診療の総数

--私の解答。CTEが多いな。。。

WITH doc_infos AS (
	SELECT
	    d.doctor_id,
	    dep.name AS department,
	    d.name AS doctor,
	    GROUP_CONCAT(DISTINCT ct.certified SEPARATOR ', ') AS certified_specialties,
	    GROUP_CONCAT(DISTINCT lg.lang SEPARATOR ',') AS languages
	FROM
	    doctors d
	INNER JOIN departments dep ON dep.department_id = d.department_id
	INNER JOIN
	    JSON_TABLE(
	        JSON_EXTRACT(d.specialties, '$.certified'),
	        '$[*]' COLUMNS(
	            certified VARCHAR(255) PATH '$'
	        )
	    ) AS ct
	INNER JOIN
		JSON_TABLE(
			d.specialties->'$.languages',
			'$[*]' COLUMNS(
				lang VARCHAR(255) PATH '$'
			)
		) AS lg
	GROUP BY
	    d.doctor_id, d.name
),
doc_app_stats AS (
	SELECT 
		d.doctor_id,
		COUNT(app.appointment_id) AS appointments,
		COUNT(CASE WHEN app.status = 'completed' THEN 1 END) AS completed_appointments
	FROM
		doctors d
		INNER JOIN appointments app ON app.doctor_id = d.doctor_id
	GROUP BY
		d.doctor_id
),
doc_med_stats AS(
	SELECT
		d.doctor_id,
		app.medical_notes->>'$.primary_symptom' AS primary_symptom,
		COUNT(*) AS symptom_count
	FROM
		doctors d
		INNER JOIN appointments app ON app.doctor_id = d.doctor_id
	GROUP BY
		d.doctor_id,
		app.medical_notes->>'$.primary_symptom'
),
doc_med_ranks AS (
	SELECT
		doctor_id,
		primary_symptom,
		RANK() OVER (PARTITION BY doctor_id ORDER BY symptom_count DESC) AS rank_in_doctor
	FROM doc_med_stats
),
doc_top_symptoms AS(
	SELECT
		doctor_id,
		GROUP_CONCAT(primary_symptom ORDER BY rank_in_doctor SEPARATOR ',') AS top_symptoms
	FROM
		doc_med_ranks
	WHERE
		rank_in_doctor <= 3
	GROUP BY
		doctor_id
)
SELECT
	di.doctor,
	di.department,
	di.certified_specialties,
	di.languages,
	dts.top_symptoms,
	CONCAT(ROUND(100.0*das.completed_appointments/das.appointments,2),'%') AS completion_rate,
	das.completed_appointments
FROM
	doc_infos di
	LEFT JOIN doc_top_symptoms dts ON dts.doctor_id = di.doctor_id
	LEFT JOIN doc_app_stats das ON das.doctor_id = di.doctor_id;


--結果


|doctor|department|certified_specialties|languages|top_symptoms|completion_rate|completed_appointments|
|------|----------|---------------------|---------|------------|---------------|----------------------|
|山田太郎  |内科        |内科, 循環器              |中国語,英語   |発熱,めまい,頭痛   |66.67%         |2                     |
|鈴木花子  |内科        |内科, 糖尿病              |英語       |高血圧,糖尿病     |50.00%         |1                     |
|佐藤健一  |整形外科      |リハビリテーション, 整形外科      |英語       |膝の痛み,腰痛     |50.00%         |1                     |
|田中美咲  |整形外科      |スポーツ医学, 整形外科         |英語,韓国語   |捻挫,肩こり      |100.00%        |2                     |
|高橋優子  |小児科       |アレルギー, 小児科           |英語       |咳,発熱        |50.00%         |1                     |

--claude.aiの批評
とても良い実装ですね。特にJSON_TABLEを使用して配列データを行に展開する手法は効率的です。
いくつかの観察と提案をさせていただきます：

1. CTEの使用について
複数のCTEを使用することは、この場合は適切だと考えられます：
- 処理が論理的に分割されて理解しやすい
- 各段階の結果が明確
- 保守性が高い

2. 改善提案：
```sql
-- 資格・言語を結合して1つのフィールドに
CONCAT(
    '資格：', di.certified_specialties,
    ' | 言語：', di.languages
) AS specialties_and_languages,

-- 完了率の NULL 対策
CASE 
    WHEN das.appointments = 0 THEN '0.00%'
    ELSE CONCAT(ROUND(100.0*das.completed_appointments/das.appointments,2),'%')
END AS completion_rate
```

3. パフォーマンスについて：
- JSON_TABLEの使用は正しい選択
- GROUP_CONCATの使用も適切
- LEFT JOINの使用で欠損データにも対応

4. 特に優れている点：
- JSON配列の展開方法
- 症状のランキング処理
- GROUP_CONCATでの順序の保持

実装は非常に堅牢で、実務でも十分に使える品質だと評価できます。





