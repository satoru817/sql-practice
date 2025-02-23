はい、JSON_TABLE関数の基礎から学習していきましょう。医療システムの例でシンプルな問題から始めてみます。

以下のテーブル構造で問題を出題します：

```sql
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    medical_history JSON
);

INSERT INTO patients VALUES
(1, '山田太郎', '{"allergies": ["花粉", "ハウスダスト"], "blood_type": "A", "height": 170}'),
(2, '佐藤花子', '{"allergies": ["牛乳"], "blood_type": "O", "height": 155}'),
(3, '鈴木一郎', '{"allergies": [], "blood_type": "B", "height": 180}');
```

問題1: JSON_TABLEを使用して、患者のアレルギー情報を1行1アレルギーで表示してください。
出力には患者名とアレルギー項目を含めてください。

期待される出力イメージ：
```
name        allergy
山田太郎    花粉
山田太郎    ハウスダスト
佐藤花子    牛乳
```

この基本的な問題から始めてみましょう。回答をお願いします。
