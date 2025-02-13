これまでの学習状況から、JSONデータ処理とJOINの最適化に焦点を当てた実践的な問題を作成します。

## 問題：医療機関の診療データ分析

以下のテーブル構造で、患者の診療記録と医師の専門分野、診療結果の分析を行ってください。

```sql
-- 医師マスタ
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    specialties JSON,  -- 専門分野を配列で格納 ["内科", "消化器科"]
    status VARCHAR(20)
);

-- 患者マスタ
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    birth_date DATE,
    medical_history JSON  -- 既往歴を{"condition": "疾患名", "year": "発症年"}の形式で配列格納
);

-- 診療記録
CREATE TABLE medical_records (
    record_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    visit_date DATE,
    diagnosis JSON,  -- 診断内容を{"primary": "主病名", "secondary": ["副病名1", "副病名2"]}で格納
    treatment_status VARCHAR(20),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- 処方箋
CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY,
    record_id INT,
    medicines JSON,  -- 薬剤情報を[{"name": "薬剤名", "amount": "用量"}]で格納
    prescribed_date DATE,
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id)
);
```

以下の分析を行うSQLを作成してください：

1. 各医師の専門分野に「消化器科」を含む医師の、2024年1月の診療件数と、処方した薬剤の種類数を求めてください。

2. 内科系の診療（primaryが"内科"で始まる）について、患者の年代別（10代、20代...）の診療件数と、最も多く処方された薬剤TOP3を抽出してください。その際、処方箋が存在しない診療も件数には含めてください。

3. 過去に「高血圧」の既往歴がある患者の、直近3回の診療記録について、診断名と処方薬をリスト形式で取得してください。

期待される実装のポイント：
- JSON操作の適切な使用
- 結合の最適化（INNER/LEFT JOINの使い分け）
- CTEを使用した段階的な処理
- 集計と順位付けの組み合わせ
- NULL値の適切な処理

なお、上記のテーブルはすでにデータが入っており、各カラムのNULL制約や一意性制約は適切に設定されているものとします。

このクエリを実装することで、JSON処理、複数テーブルの結合、Window関数の使用など、これまでの学習内容を総合的に活用することができます。
