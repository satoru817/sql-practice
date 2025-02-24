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

