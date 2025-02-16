医療システムの予約・診療データ分析の問題を作成させていただきます。

以下のスキーマで、医師の専門性や設備の情報をJSONで管理し、予約状況や診療実績を分析するシステムを想定します：

```sql
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    settings JSON,  -- 保有設備情報 {has_xray: true, has_mri: false など}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    department_id INT,
    name VARCHAR(100) NOT NULL,
    specialties JSON,  -- 専門分野等 {certified: ["内科", "循環器"], languages: ["英語", "中国語"]}
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
    medical_notes JSON,  -- 診療メモ {primary_symptom: "頭痛", severity: "中度"}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
```

問題：以下のレポートを作成するSQLクエリを書いてください。

1. 診療科別の統計情報を出力するクエリを作成してください。
- 診療科名
- 保有設備の一覧（カンマ区切りの文字列として。例："X線,MRI"）
- 所属医師数
- 予約総数
- 完了済み予約数
- 予約のキャンセル率（パーセンテージ）

2. 医師別の診療実績を分析するクエリを作成してください。
- 医師名
- 診療科名
- 資格・言語能力の一覧（JSON配列から文字列化）
- 主な症状のTOP3（medical_notesから抽出）
- 月間の予約完了率
- 診療完了数

重要な点：
- JSON操作の適切な使用
- 結合の最適化
- NULLの適切な処理
- パフォーマンスを意識した実装

回答は一つずつ確認したいので、まず1番のクエリから書いていただけますでしょうか？
