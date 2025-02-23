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

