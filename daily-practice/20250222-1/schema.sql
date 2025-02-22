CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    hourly_rate DECIMAL(10,2) NOT NULL
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    doctor_id INT NOT NULL,
    patient_name VARCHAR(100) NOT NULL,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    duration_minutes INT NOT NULL,
    status VARCHAR(20) NOT NULL,  -- 'scheduled', 'completed', 'cancelled'
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- サンプルデータ
INSERT INTO doctors VALUES
(1, '山田太郎', '内科', 12000),
(2, '鈴木花子', '小児科', 13000),
(3, '佐藤健一', '外科', 15000),
(4, '田中美咲', '内科', 12000);

INSERT INTO appointments VALUES
(1, 1, '患者A', '2025-02-01', '09:00', 30, 'completed'),
(2, 1, '患者B', '2025-02-01', '09:30', 30, 'cancelled'),
(3, 2, '患者C', '2025-02-01', '09:00', 45, 'completed'),
(4, 2, '患者D', '2025-02-01', '10:00', 30, 'completed'),
(5, 3, '患者E', '2025-02-01', '09:00', 60, 'completed'),
(6, 1, '患者F', '2025-02-02', '09:00', 30, 'scheduled'),
(7, 2, '患者G', '2025-02-02', '09:00', 30, 'scheduled'),
(8, 3, '患者H', '2025-02-02', '09:00', 45, 'cancelled');
