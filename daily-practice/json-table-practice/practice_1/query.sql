SELECT
	p.name,
	al.allergy
FROM
	patients p
	INNER JOIN JSON_TABLE(
		p.medical_history->'$.allergies','$[*]'
		COLUMNS(
			allergy VARCHAR(255) PATH '$'
		)
	) AS al;

|name|allergy|
|----|-------|
|山田太郎|花粉     |
|山田太郎|ハウスダスト |
|佐藤花子|牛乳     |

