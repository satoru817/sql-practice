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

-- 診療科データ
INSERT INTO departments (department_id, name, settings) VALUES
(1, '内科', '{"has_xray": true, "has_mri": false, "has_ct": true, "has_ultrasound": true}'),
(2, '整形外科', '{"has_xray": true, "has_mri": true, "has_ct": true, "has_ultrasound": true}'),
(3, '小児科', '{"has_xray": true, "has_mri": false, "has_ct": false, "has_ultrasound": true}'),
(4, '眼科', '{"has_xray": false, "has_mri": false, "has_ct": false, "has_ultrasound": false}');

-- 医師データ
INSERT INTO doctors (doctor_id, department_id, name, specialties) VALUES
(1, 1, '山田太郎', '{"certified": ["内科", "循環器"], "languages": ["英語", "中国語"]}'),
(2, 1, '鈴木花子', '{"certified": ["内科", "糖尿病"], "languages": ["英語"]}'),
(3, 2, '佐藤健一', '{"certified": ["整形外科", "リハビリテーション"], "languages": ["英語"]}'),
(4, 2, '田中美咲', '{"certified": ["整形外科", "スポーツ医学"], "languages": ["英語", "韓国語"]}'),
(5, 3, '高橋優子', '{"certified": ["小児科", "アレルギー"], "languages": ["英語"]}'),
(6, 4, '伊藤誠', '{"certified": ["眼科"], "languages": []}');

-- 予約データ
INSERT INTO appointments (appointment_id, doctor_id, patient_id, appointment_date, start_time, status, medical_notes) VALUES
-- 内科の山田医師の予約
(1, 1, 101, '2025-02-14', '09:00:00', 'completed', '{"primary_symptom": "頭痛", "severity": "中度"}'),
(2, 1, 102, '2025-02-14', '09:30:00', 'completed', '{"primary_symptom": "めまい", "severity": "軽度"}'),
(3, 1, 103, '2025-02-14', '10:00:00', 'cancelled', '{"primary_symptom": "発熱", "severity": "中度"}'),

-- 内科の鈴木医師の予約
(4, 2, 104, '2025-02-14', '09:00:00', 'completed', '{"primary_symptom": "糖尿病", "severity": "中度"}'),
(5, 2, 105, '2025-02-14', '09:30:00', 'scheduled', '{"primary_symptom": "高血圧", "severity": "中度"}'),

-- 整形外科の佐藤医師の予約
(6, 3, 106, '2025-02-14', '09:00:00', 'completed', '{"primary_symptom": "腰痛", "severity": "重度"}'),
(7, 3, 107, '2025-02-14', '09:30:00', 'cancelled', '{"primary_symptom": "膝の痛み", "severity": "中度"}'),

-- 整形外科の田中医師の予約
(8, 4, 108, '2025-02-14', '09:00:00', 'completed', '{"primary_symptom": "肩こり", "severity": "軽度"}'),
(9, 4, 109, '2025-02-14', '09:30:00', 'completed', '{"primary_symptom": "捻挫", "severity": "中度"}'),

-- 小児科の高橋医師の予約
(10, 5, 110, '2025-02-14', '09:00:00', 'completed', '{"primary_symptom": "発熱", "severity": "中度"}'),
(11, 5, 111, '2025-02-14', '09:30:00', 'cancelled', '{"primary_symptom": "咳", "severity": "軽度"}'),

-- 眼科の伊藤医師の予約
(12, 6, 112, '2025-02-14', '09:00:00', 'completed', '{"primary_symptom": "目の痛み", "severity": "中度"}'),
(13, 6, 113, '2025-02-14', '09:30:00', 'scheduled', '{"primary_symptom": "かすみ目", "severity": "軽度"}');
