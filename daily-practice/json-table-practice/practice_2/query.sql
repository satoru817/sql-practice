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

SELECT
	doc.name,
	lang.primary_language,
	flang.foreign_language
FROM
	doctors doc
	INNER JOIN JSON_TABLE(
		doc.profile->'$.languages','$'
		COLUMNS(
			primary_language VARCHAR(255) PATH '$.primary'
		)
	) AS lang
	INNER JOIN JSON_TABLE(
		doc.profile->'$.languages.foreign','$[*]'
		COLUMNS(
			foreign_language VARCHAR(255) PATH '$'
		)
	) AS flang;

|name|primary_language|foreign_language|
|----|----------------|----------------|
|山田医師|日本語             |英語              |
|山田医師|日本語             |中国語             |
|鈴木医師|日本語             |英語              |

２つ目のINNERをLEFTに変えると

Error occurred during SQL query execution

Reason:
SQL Error [1064] [42000]: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '' at line 18

このエラーがでる。難しい。このMySQLのJSON_TABLEの特殊な制約はよくわかんない。





