はい、段階的に理解を深めていきましょう。

次は少し異なる構造のJSONデータを扱ってみます：

```sql
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    profile JSON
);

INSERT INTO doctors VALUES
(1, '山田医師', '{"specialties": ["内科", "循環器科"], "languages": {"primary": "日本語", "foreign": ["英語", "中国語"]}}'),
(2, '鈴木医師', '{"specialties": ["小児科"], "languages": {"primary": "日本語", "foreign": ["英語"]}}'),
(3, '佐藤医師', '{"specialties": ["外科", "整形外科"], "languages": {"primary": "日本語", "foreign": []}}');
```

問題2: JSON_TABLEを使用して、医師の専門分野(specialties)を1行1専門分野で表示してください。
出力には医師名と専門分野を含めてください。

期待される出力イメージ：
```
name        specialty
山田医師    内科
山田医師    循環器科
鈴木医師    小児科
佐藤医師    外科
佐藤医師    整形外科
```

このクエリを書いてみましょう。



正解です！完璧なクエリが書けていますね。

では次の問題で、少し複雑な階層構造を持つJSONデータを扱ってみましょう。同じdoctorsテーブルを使って、今度は言語情報を取り出してみます：

```sql
-- 既存のデータを使用：
{
  "specialties": ["内科", "循環器科"],
  "languages": {
    "primary": "日本語",
    "foreign": ["英語", "中国語"]
  }
}
```

問題3: 医師ごとに、主言語(primary)と外国語(foreign)を別々の列で表示してください。外国語は1行1言語で展開してください。

期待される出力イメージ：
```
name        primary_language    foreign_language
山田医師    日本語             英語
山田医師    日本語             中国語
鈴木医師    日本語             英語
佐藤医師    日本語             NULL
```

ヒント：
- 入れ子になったJSONパスを使用します
- 外国語がない場合はNULLで表示されるようにLEFT JOINを使用します
