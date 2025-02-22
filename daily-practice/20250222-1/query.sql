-- 要件：
-- 1. 各診療科の予約状況サマリーを出力してください：
--    - 診療科名
--    - 所属医師数
--    - 完了した予約数
--    - キャンセルされた予約数
--    - キャンセル率（%）
--    - 予約あたりの平均診療時間（分）
-- 
-- 2. また、以下の売上情報も計算してください：
--    - 診療科ごとの売上見込み（予約済み分）
--    - 実際の売上（完了分のみ）
--    - 売上達成率（%）

WITH dept_stats AS (
	SELECT
		doc.department,
		COUNT(DISTINCT doc.doctor_id) AS doctors,
		COUNT(app.appointment_id) AS total_appointments,
		COUNT(CASE WHEN app.status = 'completed' THEN 1 END) AS completed_appointments,
		COUNT(CASE WHEN app.status = 'cancelled' THEN 1 END) AS cancelled_appointments,
		AVG(CASE WHEN app.status = 'completed' THEN app.duration_minutes END) AS avg_duration,
		SUM(CASE WHEN app.status != 'cancelled' THEN app.duration_minutes*doc.hourly_rate END) AS expected_total_sales,
		SUM(CASE WHEN app.status = 'completed' THEN app.duration_minutes*doc.hourly_rate END) AS real_total_sales
	FROM
		doctors doc
		INNER JOIN appointments app ON app.doctor_id = doc.doctor_id
	GROUP BY
		doc.department
)
SELECT
	department,
	doctors,
	completed_appointments,
	cancelled_appointments,
	CONCAT(ROUND(100.0*cancelled_appointments/total_appointments,2),'%') AS cancell_rate,
	avg_duration,
	expected_total_sales,
	real_total_sales,
	CONCAT(ROUND(100.0*real_total_sales/expected_total_sales,2),'%') AS achivement_rate
FROM
	dept_stats;


|department|doctors|completed_appointments|cancelled_appointments|cancell_rate|avg_duration|expected_total_sales|real_total_sales|achivement_rate|
|----------|-------|----------------------|----------------------|------------|------------|--------------------|----------------|---------------|
|内科        |1      |1                     |1                     |33.33%      |30          |720,000             |360,000         |50.00%         |
|外科        |1      |1                     |1                     |50.00%      |60          |900,000             |900,000         |100.00%        |
|小児科       |1      |2                     |0                     |0.00%       |37.5        |1,365,000           |975,000         |71.43%         |


--AIの採点

はい、良い実装ですね。以下の点が特に評価できます：

1. CTEを使って複雑な集計を整理できています
2. CASE式を効果的に使用して各種集計を実現
3. 売上計算で時間比例の計算が正しく実装されています

ただし、いくつかの改善ポイントがあります：

1. 売上計算
```sql
app.duration_minutes*doc.hourly_rate
```
これは時給に診療時間（分）を掛けているため、実際の売上より60倍大きい値になっています。正しくは：
```sql
(app.duration_minutes/60.0)*doc.hourly_rate
```

2. LEFT JOINの考慮
現在のINNER JOINだと、予約が1件もない診療科が表示されません。網羅的な情報を得るには：
```sql
doctors doc
LEFT JOIN appointments app ON app.doctor_id = doc.doctor_id
```

3. NULLを考慮した平均値計算
予約が0件の場合のAVG計算でエラーを防ぐため：
```sql
COALESCE(AVG(CASE WHEN app.status = 'completed' THEN app.duration_minutes END), 0) AS avg_duration
```

これらの点を修正したクエリを作成してみませんか？

また、追加の問題として、以下の要件のクエリも作成していただけますか？

- 各医師の1日ごとの予約スケジュール（空き時間）を分析
- 9:00-17:00の診療時間のうち、予約が入っている時間の割合を計算
- キャンセルされた予約の時間も「予約済み」としてカウント
- 1日の予約率（%）を計算

この分析により、医師ごとの予約状況と空き状況を把握できます。


