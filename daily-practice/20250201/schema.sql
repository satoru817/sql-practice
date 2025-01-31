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
