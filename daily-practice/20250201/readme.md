医療システムの診療予約と実績分析の問題を出題させていただきます。

## テーブル定義
```sql
-- 医師マスタ
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    speciality VARCHAR(50),
    is_active BOOLEAN DEFAULT true
);

-- 患者マスタ
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    gender CHAR(1),
    phone VARCHAR(20),
    first_visit_date DATE
);

-- 予約
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    status VARCHAR(20),  -- confirmed, cancelled, completed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- 診療実績
CREATE TABLE medical_records (
    record_id INT PRIMARY KEY,
    appointment_id INT,
    patient_id INT,
    doctor_id INT,
    visit_date DATE NOT NULL,
    diagnosis_code VARCHAR(10),
    treatment_details TEXT,
    fee DECIMAL(10,2),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
```

## 問題
次のような分析を行うSQLクエリを作成してください：

1. 2024年1月の医師別の診療実績を分析してください。
   - 医師名
   - 診療件数
   - 総診療報酬
   - 平均診療報酬
   - キャンセル率（予約数に対するキャンセル数の割合）
   を表示し、診療件数の多い順に並べ替えてください。

2. 診療科別の新規患者（初診）数を月次で集計してください。
   - 診療科
   - 2023年10月～2024年1月の各月の新規患者数
   - 4ヶ月間の合計新規患者数
   を表示してください。

実装のポイント：
- 日付関数を適切に使用すること
- キャンセル率は小数点2位までのパーセント表示にすること
- NULLの処理を適切に行うこと
- CTEを使用して処理を整理すること

では、解答をお願いします。
