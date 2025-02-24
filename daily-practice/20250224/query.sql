-- 問題：以下の条件を満たすレポートを作成してください。
-- 
-- 1. 各診療科について以下の情報を表示：
--    - 診療科名
--    - 保有している医療機器の一覧（カンマ区切りの文字列）
--    - その診療科に所属する医師数
--    - 完了した予約数と予約のキャンセル率
--    - 所属する医師の専門資格の種類数（重複を除く）
-- 
-- 2. さらに、以下の条件を満たすこと：
--    - キャンセル率は小数点2位までパーセント表示（例：23.45%）
--    - 医療機器がない場合は「なし」と表示
--    - すべての診療科を表示（予約や医師が0でも表示）
--    - 医師の専門資格数が多い順にソート
--    - 同じ専門資格数の場合は、完了した予約数が多い順にソート
-- 
-- 3. 結果の各列に日本語でわかりやすい別名をつけること

--まず、JSON_TABLEの実験。

SELECT
	dep.name,
	ct.certified
FROM
	departments dep
	INNER JOIN doctors doc ON doc.department_id = dep.department_id
	INNER JOIN JSON_TABLE(
		doc.specialties->'$.certified','$[*]'
		COLUMNS(
			certified VARCHAR(255) PATH '$'
		)
	) AS ct;

|name|certified|
|----|---------|
|内科  |内科       |
|内科  |循環器      |
|内科  |糖尿病      |
|内科  |内科       |
|内科  |糖尿病      |
|整形外科|整形外科     |
|整形外科|リハビリテーション|
|整形外科|スポーツ医学   |
|整形外科|整形外科     |
|整形外科|スポーツ医学   |
|小児科 |小児科      |
|小児科 |アレルギー    |
|眼科  |眼科       |

--上手くいった。

SELECT
	dep.name,
	COUNT(DISTINCT ct.certified) AS certifications
FROM
	departments dep
	INNER JOIN doctors doc ON doc.department_id = dep.department_id
	INNER JOIN JSON_TABLE(
		doc.specialties->'$.certified','$[*]'
		COLUMNS(
			certified VARCHAR(255) PATH '$'
		)
	) AS ct
GROUP BY
	dep.department_id,
	dep.name;

|name|certifications|
|----|--------------|
|内科  |3             |
|整形外科|3             |
|小児科 |2             |
|眼科  |1             |


これも上手くいった。

--解答
WITH dep_certifications AS (
	SELECT
		dep.department_id,
		COUNT(DISTINCT ct.certified) AS certifications
	FROM
		departments dep
		INNER JOIN doctors doc ON doc.department_id = dep.department_id
		INNER JOIN JSON_TABLE(
			doc.specialties->'$.certified','$[*]'
			COLUMNS(
				certified VARCHAR(255) PATH '$'
			)
		) AS ct
	GROUP BY
		dep.department_id
),
dep_doc_stats AS (
	SELECT
		dep.department_id,
		dep.name,
		CONCAT_WS(',',
			CASE WHEN dep.settings->>'$.has_xray'='true' THEN 'X線' END,
			CASE WHEN dep.settings->>'$.has_mri'='true' THEN 'MRI' END,
			CASE WHEN dep.settings->>'$.has_ct'='true' THEN 'CT' END,
			CASE WHEN dep.settings->>'$.has_ultrasound'= 'true' THEN '超音波' END
		) AS settings,
		COUNT(DISTINCT doc.doctor_id) AS doctors,
		COUNT(CASE WHEN app.status='completed' THEN 1 END) AS completed_appointments,
		COUNT(CASE WHEN app.status='cancelled' THEN 1 END) AS cancelled_appointments,
		COUNT(*) AS appointments
	FROM
		departments dep
		LEFT JOIN doctors doc ON doc.department_id = dep.department_id
		LEFT JOIN appointments app ON app.doctor_id = doc.doctor_id
	GROUP BY
		dep.department_id,
		dep.name
)
SELECT
	dds.name AS 部署,
	dds.settings AS 医療機器,
	dds.doctors AS 医師数,
	dds.completed_appointments AS 完了した診療数,
	CASE
		WHEN dds.appointments = 0 THEN '0.00%'
		ELSE CONCAT(ROUND(100.0*dds.cancelled_appointments/dds.appointments,2),'%')
	END AS キャンセル率,
	dc.certifications AS 資格数
FROM
	dep_doc_stats dds
	LEFT JOIN dep_certifications dc ON dc.department_id = dds.department_id
ORDER BY
	資格数 DESC,
	完了した診療数 DESC;

--実行結果
|部署  |医療機器         |医師数|完了した診療数|キャンセル率|資格数|
|----|-------------|---|-------|------|---|
|内科  |X線,CT,超音波    |2  |3      |20.00%|3  |
|整形外科|X線,MRI,CT,超音波|2  |3      |25.00%|3  |
|小児科 |X線,超音波       |1  |1      |50.00%|2  |
|眼科  |             |1  |1      |0.00% |1  |
|皮膚科 |             |0  |0      |0.00% |   |

あなたの解答を分析させていただきます。

## 優れている点

1. クエリの構造化
   - CTEを使用して複雑なクエリを論理的に分割
   - dep_certificationsで資格情報を集計
   - dep_doc_statsで診療科の基本統計を集計

2. NULL値の適切な処理
   - LEFT JOINを使用して全診療科を表示
   - キャンセル率計算時のゼロ除算対策
   - 医療機器がない場合の処理

3. 効率的なJOIN
   - JSON_TABLEを使用して配列データを適切に展開
   - 必要なJOINのみを実行

## 改善可能な点

1. 医療機器の表示
```sql
-- 現在のコード
CONCAT_WS(',',
    CASE WHEN dep.settings->>'$.has_xray'='true' THEN 'X線' END,
    ...
)

-- 改善案：医療機器がない場合の「なし」表示
COALESCE(NULLIF(CONCAT_WS(',',
    CASE WHEN dep.settings->>'$.has_xray'='true' THEN 'X線' END,
    ...
), ''), 'なし') AS 医療機器
```

2. 資格数のNULL表示
```sql
-- 改善案：NULLを0として表示
COALESCE(dc.certifications, 0) AS 資格数
```

この解答は全体的によく練られていますが、問題の要件である「医療機器がない場合は「なし」と表示」という点が完全には満たされていない点が唯一の課題です。それ以外は非常によく実装されています。




















































