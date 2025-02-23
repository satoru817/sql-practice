以下のような医療システムのデータ分析の問題を出題させていただきます。医師の専門分野をJSONで管理し、複数の分析を組み合わせる複雑なケースです。

```sql
-- 以下のテーブル構造が与えられています
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    settings JSON,  -- {has_xray: true, has_mri: false など}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    department_id INT,
    name VARCHAR(100) NOT NULL,
    specialties JSON,  -- {certified: ["内科", "循環器"], languages: ["英語", "中国語"]}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    doctor_id INT,
    patient_id INT,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL,  -- 'scheduled', 'completed', 'cancelled'
    medical_notes JSON,  -- {primary_symptom: "頭痛", severity: "中度"}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
```

## 問題
以下の要件を満たすSQLクエリを作成してください：

1. 各診療科について以下の情報を集計してください：
   - 診療科名
   - 保有する医療機器（カンマ区切りで「X線,MRI,CT,超音波」のような形式）
   - 所属医師数
   - 予約総数
   - 完了した予約数
   - キャンセル率（パーセント表示で小数点2桁まで。予約が0件の場合は"0.00%"と表示）

2. 各医師について以下の情報を分析してください：
   - 医師名
   - 所属診療科
   - 資格と対応言語（"資格：内科, 循環器 | 言語：英語, 中国語" のような形式）
   - 上位3つの主要症状（診察完了した予約の medical_notes から primary_symptom を抽出し、頻度順で最大3つをカンマ区切り）
   - 予約完了率（パーセント表示で小数点2桁まで。予約が0件の場合は"0.00%"と表示）
   - 完了した予約数

なお、JSONデータへのアクセスには `->` または `->>`演算子を使用し、可能な限り効率的なクエリを作成してください。また、各集計では適切なJOINとGROUP BYを使用してください。
