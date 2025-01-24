-- 医師マスタ
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    years_of_experience INT
);

-- 患者マスタ
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    birth_date DATE,
    blood_type VARCHAR(5)
);

-- 診療科マスタ
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(50),
    floor_number INT
);

-- 予約テーブル
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    start_time TIME,
    status VARCHAR(20),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- 診察記録
CREATE TABLE medical_records (
    record_id INT PRIMARY KEY,
    appointment_id INT,
    diagnosis TEXT,
    prescription TEXT,
    created_at TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);
