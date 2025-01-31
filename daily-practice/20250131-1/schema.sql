医療システムに関する問題を出題させていただきます。

以下のテーブル構造で、診療所の予約・来院状況を分析する問題です：


-- 医師マスタ
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- 患者マスタ
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    gender CHAR(1) NOT NULL,
    registered_date DATE NOT NULL
);

-- 予約
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    time_slot TIME NOT NULL,
    status VARCHAR(20) NOT NULL, -- 'scheduled', 'completed', 'cancelled', 'no_show'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- 診察記録
CREATE TABLE visits (
    visit_id INT PRIMARY KEY,
    appointment_id INT,  -- NULLの場合は予約なしの飛び込み
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);


## 問題
2023年12月の診療状況について、以下の分析を行ってください：

1. 各医師について以下の指標を算出：
   - 予約数（キャンセル・無断キャンセル含む）
   - 実際の診察数（予約外来院を含む）
   - 予約キャンセル率（キャンセル＋無断キャンセルの合計÷全予約数）
   - 平均診察時間（分単位で小数点以下四捨五入）
   - 予約外来院の割合（全診察に対する予約なし患者の割合）

2. レポートの要件：
   - 診療科目ごとにグループ化
   - 現在アクティブな医師のみ表示
   - パーセンテージは小数点以下1桁で表示（例：34.5%）
   - 診察件数が0の医師も表示すること
   - 医師ごとの各指標と、診療科目ごとの平均値を表示

クエリを作成してください。
