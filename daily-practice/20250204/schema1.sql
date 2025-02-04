-- 診療科テーブル
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(50),
    floor_num INT,
    is_active BOOLEAN DEFAULT true
);

-- 医師テーブル
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    specialization JSON,  -- 専門分野や資格情報をJSON形式で保存
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 患者テーブル
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    birth_date DATE,
    medical_history JSON  -- 既往歴や健康状態をJSON形式で保存
);

-- 予約テーブル
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    appointment_time TIME,
    status VARCHAR(20),  -- 'completed', 'cancelled', 'no_show'
    medical_notes JSON,  -- 診察メモをJSON形式で保存
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
