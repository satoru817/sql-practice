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
|department_name|setting        |doctors|appointments|real_appointments|
|---------------|---------------|-------|------------|-----------------|
|内科             |X線有り,MRI無し,CT無し|3      |11          |10               |
|小児科            |X線無し,MRI無し,CT無し|2      |6           |4                |
|循環器内科          |X線有り,MRI有り,CT有り|1      |2           |2                |
|整形外科           |X線有り,MRI有り,CT無し|1      |2           |2                |
|皮膚科            |X線無し,MRI無し,CT無し|1      |2           |2                |
|眼科             |X線無し,MRI無し,CT無し|1      |2           |2                |
|耳鼻科            |X線無し,MRI無し,CT無し|1      |2           |2                |


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


--まず、症状の集計で何をしたいのか聞く

申し訳ありません。主な症状の集計について、より具体的に説明させていただきます。

medical_notes.primary_symptomごとの件数を集計し、以下のような形で出力することを想定しています：

例えば医師「山田太郎」の場合：
- 発熱: 1件
- 頭痛: 1件

これを1つのカラムにまとめて表示する場合は：
`"発熱(1), 頭痛(1)"`

というような形式での出力を想定しています。

クエリの出力イメージは以下のようになります：
```
医師名    | 診療科名 | 保有資格数 | 対応可能言語数 | 症状集計
山田太郎   | 内科     | 2          | 2             | 発熱(1), 頭痛(1)
田中一郎   | 内科     | 2          | 2             | 腹痛(1)
```

このような集計でよろしいでしょうか？

--なるほど。group_concat()でできそうなので、実験。

WITH symptom_stats AS (
	SELECT
		doc.doctor_id,
		doc.name,
		app.medical_notes->>'$.primary_symptom' AS primary_symptom,
		count(*) AS symptom_count
	FROM
		doctors doc
		INNER JOIN appointments app
			ON app.doctor_id = doc.doctor_id
	GROUP BY 
		doc.doctor_id,
		doc.name,
		app.medical_notes->>'$.primary_symptom'
)
SELECT
	name,
	GROUP_CONCAT(CONCAT(primary_symptom,'(',symptom_count,')')) AS symptom_dist
FROM
	symptom_stats
GROUP BY
	name,
	doctor_id;
--実行結果
|name|symptom_dist   |
|----|---------------|
|中村博美|動悸(1),胸痛(1)    |
|伊藤健一|膝の痛み(1),腰痛(1)  |
|佐藤雅子|めまい(1),頭痛(2)   |
|小林秀樹|めまい(1),耳鳴り(1)  |
|山本一郎|目の充血(1),かすみ目(1)|
|山田太郎|頭痛(1),発熱(3)    |
|木村真理|発熱(1)          |
|田中一郎|吐き気(1),腹痛(2)   |
|鈴木花子|咳(1),発熱(2)     |
|高橋和子|発疹(1),かゆみ(1)   |

    
--いいね。じゃあ、答えを書いていこう



-- 2. 医師ごとの受診実績を分析してください：
--    - 医師名
--    - 診療科名
--    - 保有資格数（specialties.certifiedの配列の要素数）
--    - 対応可能言語数（specialties.languagesの配列の要素数）
--    - 主な症状の集計（medical_notes.primary_symptomの出現回数）
--    条件：完了した予約（status = 'completed'）のみを対象とし、JSON_TABLE等は使用せず実装してください

WITH symptom_stats AS (
	SELECT
		doc.doctor_id,
		app.medical_notes->>'$.primary_symptom' AS primary_symptom,
		count(*) AS symptom_count
	FROM
		doctors doc
		INNER JOIN appointments app
			ON app.doctor_id = doc.doctor_id
	WHERE
		app.status = 'completed'
	GROUP BY 
		doc.doctor_id,
		app.medical_notes->>'$.primary_symptom'
),
symptom_dists AS(
	SELECT
		ss.doctor_id,
		GROUP_CONCAT(CONCAT(ss.primary_symptom,'(',symptom_count,')')) AS dists
	FROM
		symptom_stats ss
	GROUP BY
		ss.doctor_id
)
SELECT
	doc.name AS doctor_name,
	dep.name AS department_name,
	JSON_LENGTH(doc.specialties->'$.certified') AS certifieds,
	JSON_LENGTH(doc.specialties->'$.languages') AS languages,
	sd.dists AS symptom_dists
FROM
	doctors doc
	INNER JOIN departments dep ON dep.department_id = doc.department_id
	INNER JOIN symptom_dists  sd ON sd.doctor_id = doc.doctor_id ;

--実行結果
|doctor_name|department_name|certifieds|languages|symptom_dists  |
|-----------|---------------|----------|---------|---------------|
|山田太郎       |内科             |2         |2        |頭痛(1),発熱(3)    |
|鈴木花子       |小児科            |1         |1        |発熱(2),咳(1)     |
|田中一郎       |内科             |2         |2        |腹痛(2),吐き気(1)   |
|佐藤雅子       |内科             |2         |3        |頭痛(2),めまい(1)   |
|伊藤健一       |整形外科           |2         |1        |膝の痛み(1),腰痛(1)  |
|木村真理       |小児科            |2         |2        |発熱(1)          |
|高橋和子       |皮膚科            |1         |2        |発疹(1),かゆみ(1)   |
|山本一郎       |眼科             |2         |2        |目の充血(1),かすみ目(1)|
|中村博美       |循環器内科          |2         |2        |胸痛(1),動悸(1)    |
|小林秀樹       |耳鼻科            |2         |2        |耳鳴り(1),めまい(1)  |




素晴らしい実装ですね。いくつか興味深いポイントがあります：

### 1つ目のクエリについて
- `CONCAT_WS`を使用して機器の有無を効率的に結合している点が良いです
- ただし、実行結果を見ると一部の診療科のデータしか表示されていません。これは`INNER JOIN`を使用しているためです。

以下のように修正すると、予約がない診療科も含めて表示できます：
```sql
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
    LEFT JOIN doctors doc ON doc.department_id = dep.department_id
    LEFT JOIN appointments app ON app.doctor_id = doc.doctor_id
WHERE
    dep.is_active=true
GROUP BY
    dep.name,
    dep.department_id
ORDER BY
    appointments DESC;
```

### 2つ目のクエリについて
- CTEを使用して症状の集計を段階的に行っている点が非常に良いです
- `GROUP_CONCAT`で症状と件数を分かりやすく表示している点も優れています

ただし、こちらも予約のない医師が表示されない可能性があります。必要に応じて：
```sql
LEFT JOIN symptom_dists sd ON sd.doctor_id = doc.doctor_id
```
とすることで、予約のない医師も表示できます。

このクエリは実務でも活用できる形になっていますが、実運用時は以下の点も考慮すると良いでしょう：

1. パフォーマンス面
   - JSONのインデックス作成の検討
   - GROUP_CONCATの長さ制限の確認

2. 機能面
   - 期間指定の追加
   - 診療科ごとの集計
   - キャンセル率の計算

これらの実装は非常に実践的で、実務でもすぐに活用できるレベルだと評価できます。

























