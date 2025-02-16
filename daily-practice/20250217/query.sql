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








