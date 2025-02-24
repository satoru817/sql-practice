-- 1. 診療科別の統計情報
--    - 診療科名
--    - 保有設備のリスト（カンマ区切り）
--    - 所属医師数
--    - 完了した予約数
--    - キャンセル率
--    - 保険適用率
--    - 総診療収入

WITH dept_settings AS (
	SELECT
		department_id,
		CONCAT_WS(',',
			CASE WHEN settings->>'$.has_xray'='true' THEN 'X線' END,
			CASE WHEN settings->>'$.has_mri'='true' THEN 'MRI' END,
			CASE WHEN settings->>'$.has_ultrasound'='true' THEN '超音波' END,
			CASE WHEN settings->>'$.has_ct'='true' THEN 'CT' END
		) AS settings
	FROM
		departments
)
SELECT
	dep.name,
	CASE
		WHEN ds.settings = '' THEN '設備無し'
		ELSE ds.settings
	END AS settings,
	COUNT(DISTINCT doc.doctor_id) AS doctors,
	COUNT(CASE WHEN app.status='completed' THEN 1 END) AS completed_appointments,
	CASE
		WHEN COUNT(app.appointment_id)=0 THEN '0.00%'
		ELSE CONCAT(ROUND(COUNT(CASE WHEN app.status='cancelled' THEN 1 END)*100.0/COUNT(app.appointment_id),2),'%')
	END AS cancellation_rate,
	CASE
		WHEN COUNT(app.appointment_id)=0 THEN '0.00%'
		ELSE CONCAT(ROUND(COUNT(CASE WHEN app.insurance_applied = TRUE THEN 1 END)*100.0/COUNT(app.appointment_id),2),'%')
	END AS insurance_application_rate,
	SUM(app.billing_amount) AS total_billing
FROM
	departments dep
	INNER JOIN dept_settings ds ON ds.department_id = dep.department_id
	LEFT JOIN doctors doc ON doc.department_id = dep.department_id
	LEFT JOIN appointments app ON app.doctor_id = doc.doctor_id
GROUP BY
	dep.name,
	ds.settings;

--実行結果
|name |settings     |doctors|completed_appointments|cancellation_rate|insurance_application_rate|total_billing|
|-----|-------------|-------|----------------------|-----------------|--------------------------|-------------|
|内科   |X線,超音波,CT    |2      |5                     |14.29%           |71.43%                    |25,000       |
|小児科  |X線,超音波       |1      |2                     |33.33%           |66.67%                    |9,000        |
|循環器内科|X線,MRI,超音波,CT|1      |3                     |0.00%            |100.00%                   |20,000       |
|整形外科 |X線,MRI,超音波,CT|2      |4                     |33.33%           |66.67%                    |28,000       |
|消化器内科|X線,MRI,超音波,CT|1      |1                     |50.00%           |50.00%                    |7,000        |
|皮膚科  |超音波          |1      |3                     |0.00%            |100.00%                   |18,000       |
|眼科   |設備無し         |1      |2                     |0.00%            |66.67%                    |11,000       |
|耳鼻咽喉科|X線,超音波,CT    |1      |2                     |33.33%           |66.67%                    |12,500       |


--AIの採点

素晴らしい実装ですね。重要なポイントを分析させていただきます：

### 優れている点

1. **CTEの効果的な活用**
   - 設備情報の整形を別途処理することで可読性が向上
   - メインクエリがシンプルに

2. **NULL/空文字の適切な処理**
   ```sql
   CASE
       WHEN ds.settings = '' THEN '設備無し'
       ELSE ds.settings
   END AS settings
   ```

3. **パーセンテージ計算の堅牢性**
   - ゼロ除算を防ぐための条件分岐
   - 小数点以下2桁での表示
   - %記号の付加

4. **適切なJOINの使用**
   - 診療科情報取得のためのINNER JOIN
   - 医師・予約情報取得のためのLEFT JOIN

### さらなる改善案

1. **パフォーマンス最適化**
```sql
WITH dept_settings AS (
    SELECT
        department_id,
        name,
        CONCAT_WS(',',
            CASE WHEN settings->>'$.has_xray'='true' THEN 'X線' END,
            CASE WHEN settings->>'$.has_mri'='true' THEN 'MRI' END,
            CASE WHEN settings->>'$.has_ultrasound'='true' THEN '超音波' END,
            CASE WHEN settings->>'$.has_ct'='true' THEN 'CT' END
        ) AS settings
    FROM
        departments
),
appointment_stats AS (
    SELECT 
        d.department_id,
        COUNT(a.appointment_id) as total_appointments,
        COUNT(CASE WHEN a.status='completed' THEN 1 END) as completed_appointments,
        COUNT(CASE WHEN a.status='cancelled' THEN 1 END) as cancelled_appointments,
        COUNT(CASE WHEN a.insurance_applied = TRUE THEN 1 END) as insurance_applied,
        SUM(a.billing_amount) as total_billing
    FROM doctors d
    LEFT JOIN appointments a ON a.doctor_id = d.doctor_id
    GROUP BY d.department_id
)
```

2. **金額のフォーマット**
```sql
FORMAT(SUM(app.billing_amount), 0) AS total_billing
```

3. **可読性の向上**
```sql
ROUND(
    NULLIF(COUNT(CASE WHEN app.status='cancelled' THEN 1 END), 0) * 100.0 /
    NULLIF(COUNT(app.appointment_id), 0),
    2
) AS cancellation_rate
```

このクエリは非常に良く実装されていますが、上記のような改善を加えることで、より堅牢で保守性の高いものになると考えます。


-- 2. 医師別の詳細統計
--    - 医師名と所属診療科
--    - 資格・言語情報（整形して表示）
--    - 診療実績（患者数、完了率）
--    - 主な症状TOP3（出現回数順）
--    - 平均診療時間
--    - 総診療収入と保険適用率
-- 	
-- 	

WITH doc_basic_infos AS(
	SELECT
		doc.doctor_id,
		doc.name AS doctor_name,
		dep.name AS department_name,
		CONCAT('専門: ',GROUP_CONCAT(DISTINCT ct.certified),' | 言語: ',GROUP_CONCAT(DISTINCT lg.lang)) AS specialties
	FROM
		doctors doc
		LEFT JOIN departments dep ON dep.department_id = doc.department_id
		INNER JOIN JSON_TABLE(
			doc.specialties->'$.certified','$[*]'
			COLUMNS(
				certified VARCHAR(255) PATH '$'
			)
		)AS ct
		INNER JOIN JSON_TABLE(
			doc.specialties->'$.languages','$[*]'
			COLUMNS(
				lang VARCHAR(255) PATH '$'
			)
		)AS lg
	GROUP BY
		doc.doctor_id,
		doc.name,
		dep.name
),
doc_symptom_stats AS (
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
doc_symptom_ranks AS(
	SELECT
		doctor_id,
		symptom,
		RANK() OVER (PARTITION BY doctor_id ORDER BY symptom_count DESC) AS rank_in_doctor
	FROM
		doc_symptom_stats
),
doc_top_symptoms AS(
	SELECT
		doctor_id,
		GROUP_CONCAT(symptom ORDER BY rank_in_doctor ASC) AS top_symptom
	FROM
		doc_symptom_ranks
	WHERE
		rank_in_doctor <= 3
	GROUP BY
		doctor_id
),
doc_app_stats AS(
	SELECT
		doc.doctor_id,
		COUNT(DISTINCT app.patient_id) AS patients,
		CASE
			WHEN COUNT(app.appointment_id) = 0 THEN '0.00%'
			ELSE CONCAT(ROUND(100.0*COUNT(CASE WHEN app.status='completed' THEN 1 END)/COUNT(app.appointment_id),2),'%')
		END AS completion_rate,
		AVG(TIMESTAMPDIFF(MINUTE,app.start_time,app.end_time)) AS avg_consultation_time,
		SUM(CASE WHEN app.status = 'completed' THEN app.billing_amount END) AS sum_billing,
		CASE
			WHEN COUNT(app.appointment_id)=0 THEN '0.00%'
			ELSE CONCAT(ROUND(100.0*COUNT(CASE WHEN app.insurance_applied THEN 1 END)/COUNT(app.appointment_id),2),'%')
		END AS insurance_application_rate
	FROM
		doctors doc
		LEFT JOIN appointments app ON doc.doctor_id = app.doctor_id
	GROUP BY
		doc.doctor_id
)
SELECT
	dbi.doctor_name,
	dbi.department_name,
	dbi.specialties,
	das.patients,
	das.completion_rate,
	das.insurance_application_rate,
	dts.top_symptom,
	das.avg_consultation_time,
	das.sum_billing,
	das.insurance_application_rate
FROM
	doc_basic_infos dbi
	LEFT JOIN doc_top_symptoms dts ON dts.doctor_id = dbi.doctor_id
	LEFT JOIN doc_app_stats das ON das.doctor_id = dbi.doctor_id;

--実行結果
|doctor_name|department_name|specialties                 |patients|completion_rate|insurance_application_rate|top_symptom|avg_consultation_time|sum_billing|insurance_application_rate|
|-----------|---------------|----------------------------|--------|---------------|--------------------------|-----------|---------------------|-----------|--------------------------|
|山田太郎       |内科             |専門: 内科,循環器 | 言語: 中国語,英語     |4       |75.00%         |75.00%                    |頭痛,発熱,めまい  |23.3333              |15,000     |75.00%                    |
|鈴木花子       |内科             |専門: 内科,糖尿病 | 言語: 英語         |3       |66.67%         |66.67%                    |高血圧,糖尿病    |25                   |10,000     |66.67%                    |
|佐藤健一       |整形外科           |専門: リハビリテーション,整形外科 | 言語: 英語 |3       |66.67%         |66.67%                    |腰痛,膝の痛み    |42.5                 |15,000     |66.67%                    |
|田中美咲       |整形外科           |専門: スポーツ医学,整形外科 | 言語: 英語,韓国語|3       |66.67%         |66.67%                    |捻挫,肩こり     |30                   |13,000     |66.67%                    |
|高橋優子       |小児科            |専門: アレルギー,小児科 | 言語: 英語      |3       |66.67%         |66.67%                    |発熱,咳       |20                   |9,000      |66.67%                    |
|伊藤誠        |眼科             |専門: 眼科 | 言語: スペイン語,英語       |3       |66.67%         |66.67%                    |目の痛み,かすみ目  |22.5                 |11,000     |66.67%                    |
|渡辺和子       |皮膚科            |専門: アレルギー,皮膚科 | 言語: フランス語,英語|3       |100.00%        |100.00%                   |アレルギー,湿疹   |31.6667              |18,000     |100.00%                   |
|中村哲也       |耳鼻咽喉科          |専門: アレルギー,耳鼻咽喉科 | 言語: 英語    |3       |66.67%         |66.67%                    |耳鳴り,めまい    |22.5                 |12,500     |66.67%                    |
|小林正人       |循環器内科          |専門: 内科,循環器内科 | 言語: ドイツ語,英語  |3       |100.00%        |100.00%                   |動悸,胸痛      |33.3333              |20,000     |100.00%                   |
|加藤明美       |消化器内科          |専門: 内科,消化器内科 | 言語: 中国語,英語   |2       |50.00%         |50.00%                    |腹痛         |35                   |7,000      |50.00%                    |



--AIの採点

すばらしい実装ですね。クエリの重要なポイントを分析させていただきます：

### 優れている点

1. **CTEの効果的な分割**
   - doc_basic_infos: 基本情報と専門分野の整形
   - doc_symptom_stats: 症状別の集計
   - doc_symptom_ranks: 症状のランキング付け
   - doc_app_stats: 予約関連の統計

2. **JSON_TABLEの適切な活用**
```sql
INNER JOIN JSON_TABLE(
    doc.specialties->'$.certified','$[*]'
    COLUMNS(
        certified VARCHAR(255) PATH '$'
    )
)AS ct
```
- 配列データの適切な展開
- パスの正確な指定

3. **Window関数の効果的な使用**
```sql
RANK() OVER (PARTITION BY doctor_id ORDER BY symptom_count DESC) AS rank_in_doctor
```
- 医師ごとの症状ランキングを効率的に計算

4. **NULL/ゼロ値の堅牢な処理**
```sql
CASE
    WHEN COUNT(app.appointment_id) = 0 THEN '0.00%'
    ELSE CONCAT(ROUND(100.0*COUNT(...)/COUNT(...),2),'%')
END
```

### 改善提案

1. **平均診療時間の表示形式**
```sql
CONCAT(
    FLOOR(AVG(TIMESTAMPDIFF(MINUTE,app.start_time,app.end_time))), 
    '分'
) AS avg_consultation_time
```

2. **金額のフォーマット**
```sql
FORMAT(SUM(CASE WHEN app.status = 'completed' THEN app.billing_amount END), 0) AS sum_billing
```

3. **TOP3症状の区切り文字の改善**
```sql
GROUP_CONCAT(
    CONCAT(rank_in_doctor, '. ', symptom) 
    ORDER BY rank_in_doctor ASC 
    SEPARATOR ' → '
) AS top_symptom
```

4. **パフォーマンス最適化**
- completed状態の予約のみを対象とした診療時間計算
- インデックスを活用したJOIN順序の最適化

このクエリは非常によく設計されており、特に複雑なJSONデータの処理とランキング計算を効率的に実装している点が評価できます。


--  A. 時間帯別の基本統計
-- 1. 1時間ごとの時間帯区分（9:00-10:00, 14:00-15:00など）
-- 2. 各時間帯における：
--    - 予約総数
--    - 完了した予約数
--    - キャンセルされた予約数
--    - キャンセル率（パーセント表示、小数点2桁）
-- 	
--    

WITH hour_app_dists AS (
	SELECT
		HOUR(start_time) AS start_hour,
		status
	FROM
		appointments
),
hour_app_stats AS(
	SELECT
		start_hour,
		status,
		COUNT(*) AS num
	FROM
		hour_app_dists
	GROUP BY
		start_hour,
		status
)
SELECT
	CONCAT(start_hour,'時-',start_hour+1,'時') AS hour_interval,
	SUM(num) AS total_appointments,
	MAX(CASE WHEN status = 'completed' THEN num END) AS completed_appointments,
	MAX(CASE WHEN status='cancelled' THEN num END) AS cancelled_appointments,
	CASE
		WHEN SUM(num) = 0 THEN '0.00%'
		ELSE CONCAT(ROUND(100.0*MAX(CASE WHEN status='cancelled' THEN num END)/SUM(num),2),'%')
	END AS cancellation_rate
FROM
	hour_app_stats
GROUP BY
	start_hour;

--実行結果
|hour_interval|total_appointments|completed_appointments|cancelled_appointments|cancellation_rate|
|-------------|------------------|----------------------|----------------------|-----------------|
|9時-10時       |17                |13                    |2                     |11.76%           |
|10時-11時      |3                 |1                     |2                     |66.67%           |
|14時-15時      |10                |8                     |2                     |20.00%           |

--AIの改善提案

結果を確認しながら、いくつかの改善点を提案させていただきます：

1. 予約がない時間帯も表示するように改善
2. 時間表示をより見やすく（09:00-10:00の形式）
3. キャンセル数がNULLの場合の処理を追加

```sql
WITH RECURSIVE time_slots AS (
    SELECT 9 AS hour
    UNION ALL
    SELECT hour + 1
    FROM time_slots
    WHERE hour < 14
),
hour_app_stats AS (
    SELECT
        HOUR(start_time) AS start_hour,
        COUNT(*) AS total_apps,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed_apps,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_apps
    FROM
        appointments
    GROUP BY
        HOUR(start_time)
)
SELECT
    CONCAT(
        LPAD(t.hour, 2, '0'),
        ':00-',
        LPAD(t.hour + 1, 2, '0'),
        ':00'
    ) AS time_slot,
    COALESCE(has.total_apps, 0) AS total_appointments,
    COALESCE(has.completed_apps, 0) AS completed_appointments,
    COALESCE(has.cancelled_apps, 0) AS cancelled_appointments,
    CASE 
        WHEN COALESCE(has.total_apps, 0) = 0 THEN '0.00%'
        ELSE CONCAT(
            ROUND(
                100.0 * COALESCE(has.cancelled_apps, 0) / 
                COALESCE(has.total_apps, 0), 
                2
            ),
            '%'
        )
    END AS cancellation_rate
FROM
    time_slots t
    LEFT JOIN hour_app_stats has ON has.start_hour = t.hour
ORDER BY
    t.hour;
```

この改善により：

1. 9時から14時までのすべての時間帯が表示されます
2. 時刻表示が「09:00-10:00」のような標準的なフォーマットになります
3. データがない時間帯も0として適切に表示されます
4. 結果が時間順に並びます

これにより、より完全で読みやすいレポートが作成できます。


--  B. 診療科別の時間帯分析
-- 1. 各診療科の時間帯ごとの：
--    - 予約件数
--    - 平均診療時間（分単位）
--    - 最長診療時間（分単位）
--    - 最短診療時間（分単位）

WITH RECURSIVE time_slots AS (
	SELECT 9 AS start_hour
	UNION ALL
	SELECT start_hour+1
	FROM time_slots
	WHERE start_hour < 14
)
SELECT
	CONCAT(
		LPAD(ts.start_hour,2,'0'),
		':00-',
		LPAD(ts.start_hour+1,2,'0'),
		':00'
	) AS time_slot,
	dep.name AS department_name,
	COUNT(app.appointment_id) AS appointments,
	CONCAT(ROUND(AVG(TIMESTAMPDIFF(MINUTE,app.start_time,app.end_time)),2),'分') AS avg_counselling_time,
	CONCAT(MAX(TIMESTAMPDIFF(MINUTE,app.start_time,app.end_time)),'分') AS max_counselling_time,
	CONCAT(MIN(TIMESTAMPDIFF(MINUTE,app.start_time,app.end_time)),'分') AS min_counselling_time
FROM
	time_slots ts
	LEFT JOIN appointments app ON HOUR(app.start_time) = ts.start_hour
	LEFT JOIN doctors doc ON doc.doctor_id = app.doctor_id
	LEFT JOIN departments dep ON dep.department_id = doc.department_id
GROUP BY
	ts.start_hour,
	dep.name
ORDER BY 
	ts.start_hour ASC,
	dep.name;
--実行結果
|time_slot  |department_name|appointments|avg_counselling_time|max_counselling_time|min_counselling_time|
|-----------|---------------|------------|--------------------|--------------------|--------------------|
|09:00-10:00|内科             |4           |23.33分              |25分                 |20分                 |
|09:00-10:00|小児科            |2           |20.00分              |20分                 |20分                 |
|09:00-10:00|循環器内科          |1           |40.00分              |40分                 |40分                 |
|09:00-10:00|整形外科           |3           |35.00分              |45分                 |30分                 |
|09:00-10:00|消化器内科          |1           |35.00分              |35分                 |35分                 |
|09:00-10:00|皮膚科            |2           |30.00分              |30分                 |30分                 |
|09:00-10:00|眼科             |2           |25.00分              |25分                 |25分                 |
|09:00-10:00|耳鼻咽喉科          |2           |20.00分              |20分                 |20分                 |
|10:00-11:00|内科             |1           |                    |                    |                    |
|10:00-11:00|循環器内科          |1           |30.00分              |30分                 |30分                 |
|10:00-11:00|整形外科           |1           |                    |                    |                    |
|11:00-12:00|               |0           |                    |                    |                    |
|12:00-13:00|               |0           |                    |                    |                    |
|13:00-14:00|               |0           |                    |                    |                    |
|14:00-15:00|内科             |2           |25.00分              |25分                 |25分                 |
|14:00-15:00|小児科            |1           |20.00分              |20分                 |20分                 |
|14:00-15:00|循環器内科          |1           |30.00分              |30分                 |30分                 |
|14:00-15:00|整形外科           |2           |40.00分              |40分                 |40分                 |
|14:00-15:00|消化器内科          |1           |                    |                    |                    |
|14:00-15:00|皮膚科            |1           |35.00分              |35分                 |35分                 |
|14:00-15:00|眼科             |1           |20.00分              |20分                 |20分                 |
|14:00-15:00|耳鼻咽喉科          |1           |25.00分              |25分                 |25分                 |



--AIの採点

クエリの結果を確認しました。以下のように改善を提案させていただきます：

```sql
WITH RECURSIVE time_slots AS (
    SELECT 9 AS start_hour
    UNION ALL
    SELECT start_hour + 1
    FROM time_slots
    WHERE start_hour < 14
),
department_hours AS (
    -- 診療科と時間帯の全組み合わせを生成
    SELECT 
        ts.start_hour,
        d.department_id,
        d.name AS department_name
    FROM time_slots ts
    CROSS JOIN departments d
    WHERE d.is_active = true
),
appointment_stats AS (
    -- 予約データの集計
    SELECT
        HOUR(app.start_time) AS hour,
        dep.department_id,
        COUNT(app.appointment_id) AS total_appointments,
        AVG(CASE 
            WHEN app.status = 'completed' 
            THEN TIMESTAMPDIFF(MINUTE, app.start_time, app.end_time) 
        END) AS avg_duration,
        MAX(CASE 
            WHEN app.status = 'completed' 
            THEN TIMESTAMPDIFF(MINUTE, app.start_time, app.end_time)
        END) AS max_duration,
        MIN(CASE 
            WHEN app.status = 'completed' 
            THEN TIMESTAMPDIFF(MINUTE, app.start_time, app.end_time)
        END) AS min_duration
    FROM appointments app
    INNER JOIN doctors doc ON doc.doctor_id = app.doctor_id
    INNER JOIN departments dep ON dep.department_id = doc.department_id
    WHERE app.status = 'completed'
    GROUP BY 
        HOUR(app.start_time),
        dep.department_id
)
SELECT
    CONCAT(
        LPAD(dh.start_hour, 2, '0'),
        ':00-',
        LPAD(dh.start_hour + 1, 2, '0'),
        ':00'
    ) AS time_slot,
    dh.department_name,
    COALESCE(aps.total_appointments, 0) AS appointments,
    CASE 
        WHEN aps.avg_duration IS NULL THEN '-'
        ELSE CONCAT(ROUND(aps.avg_duration, 0), '分')
    END AS avg_counselling_time,
    CASE 
        WHEN aps.max_duration IS NULL THEN '-'
        ELSE CONCAT(aps.max_duration, '分')
    END AS max_counselling_time,
    CASE 
        WHEN aps.min_duration IS NULL THEN '-'
        ELSE CONCAT(aps.min_duration, '分')
    END AS min_counselling_time
FROM
    department_hours dh
    LEFT JOIN appointment_stats aps ON 
        aps.hour = dh.start_hour AND 
        aps.department_id = dh.department_id
ORDER BY 
    dh.start_hour,
    dh.department_name;
```

主な改善点：

1. 値がNULLの場合は'-'で表示
2. status = 'completed' の予約のみを集計対象に
3. 診療科と時間帯の全組み合わせを生成（データがない時間帯も表示）
4. 時間の計算を完了した予約のみに限定
5. より正確な平均時間の計算（NULL値を除外）

このクエリにより：
- すべての時間帯と診療科の組み合わせが表示されます
- データがない場合は明確に'-'として表示されます
- キャンセルされた予約は診療時間の計算から除外されます
- より正確な統計情報が得られます


--実行結果

|time_slot  |department_name|appointments|avg_counselling_time|max_counselling_time|min_counselling_time|
|-----------|---------------|------------|--------------------|--------------------|--------------------|
|09:00-10:00|内科             |3           |23分                 |25分                 |20分                 |
|09:00-10:00|小児科            |1           |20分                 |20分                 |20分                 |
|09:00-10:00|循環器内科          |1           |40分                 |40分                 |40分                 |
|09:00-10:00|整形外科           |3           |35分                 |45分                 |30分                 |
|09:00-10:00|消化器内科          |1           |35分                 |35分                 |35分                 |
|09:00-10:00|皮膚科            |2           |30分                 |30分                 |30分                 |
|09:00-10:00|眼科             |1           |25分                 |25分                 |25分                 |
|09:00-10:00|耳鼻咽喉科          |1           |20分                 |20分                 |20分                 |
|10:00-11:00|内科             |0           |-                   |-                   |-                   |
|10:00-11:00|小児科            |0           |-                   |-                   |-                   |
|10:00-11:00|循環器内科          |1           |30分                 |30分                 |30分                 |
|10:00-11:00|整形外科           |0           |-                   |-                   |-                   |
|10:00-11:00|消化器内科          |0           |-                   |-                   |-                   |
|10:00-11:00|皮膚科            |0           |-                   |-                   |-                   |
|10:00-11:00|眼科             |0           |-                   |-                   |-                   |
|10:00-11:00|耳鼻咽喉科          |0           |-                   |-                   |-                   |
|11:00-12:00|内科             |0           |-                   |-                   |-                   |
|11:00-12:00|小児科            |0           |-                   |-                   |-                   |
|11:00-12:00|循環器内科          |0           |-                   |-                   |-                   |
|11:00-12:00|整形外科           |0           |-                   |-                   |-                   |
|11:00-12:00|消化器内科          |0           |-                   |-                   |-                   |
|11:00-12:00|皮膚科            |0           |-                   |-                   |-                   |
|11:00-12:00|眼科             |0           |-                   |-                   |-                   |
|11:00-12:00|耳鼻咽喉科          |0           |-                   |-                   |-                   |
|12:00-13:00|内科             |0           |-                   |-                   |-                   |
|12:00-13:00|小児科            |0           |-                   |-                   |-                   |
|12:00-13:00|循環器内科          |0           |-                   |-                   |-                   |
|12:00-13:00|整形外科           |0           |-                   |-                   |-                   |
|12:00-13:00|消化器内科          |0           |-                   |-                   |-                   |
|12:00-13:00|皮膚科            |0           |-                   |-                   |-                   |
|12:00-13:00|眼科             |0           |-                   |-                   |-                   |
|12:00-13:00|耳鼻咽喉科          |0           |-                   |-                   |-                   |
|13:00-14:00|内科             |0           |-                   |-                   |-                   |
|13:00-14:00|小児科            |0           |-                   |-                   |-                   |
|13:00-14:00|循環器内科          |0           |-                   |-                   |-                   |
|13:00-14:00|整形外科           |0           |-                   |-                   |-                   |
|13:00-14:00|消化器内科          |0           |-                   |-                   |-                   |
|13:00-14:00|皮膚科            |0           |-                   |-                   |-                   |
|13:00-14:00|眼科             |0           |-                   |-                   |-                   |
|13:00-14:00|耳鼻咽喉科          |0           |-                   |-                   |-                   |
|14:00-15:00|内科             |2           |25分                 |25分                 |25分                 |
|14:00-15:00|小児科            |1           |20分                 |20分                 |20分                 |
|14:00-15:00|循環器内科          |1           |30分                 |30分                 |30分                 |
|14:00-15:00|整形外科           |1           |40分                 |40分                 |40分                 |
|14:00-15:00|消化器内科          |0           |-                   |-                   |-                   |
|14:00-15:00|皮膚科            |1           |35分                 |35分                 |35分                 |
|14:00-15:00|眼科             |1           |20分                 |20分                 |20分                 |
|14:00-15:00|耳鼻咽喉科          |1           |25分                 |25分                 |25分                 |

