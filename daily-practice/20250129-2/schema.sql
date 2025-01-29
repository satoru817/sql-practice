-- 診療科マスタ
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    floor_number INT NOT NULL
);

-- 医師マスタ
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    employment_date DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 患者マスタ
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(1) NOT NULL,
    registered_date DATE NOT NULL
);

-- 診療記録
CREATE TABLE medical_records (
    record_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    visit_date DATE NOT NULL,
    consultation_time TIME NOT NULL,
    wait_time INT NOT NULL, -- 待ち時間（分）
    treatment_time INT NOT NULL, -- 診察時間（分）
    is_first_visit BOOLEAN NOT NULL,
    canceled BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
