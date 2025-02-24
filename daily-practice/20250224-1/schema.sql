-- 診療科マスタ
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    settings JSON,  -- {has_xray: true, has_mri: false, has_ultrasound: true など}
    floor_number INT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 医師マスタ
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    department_id INT,
    name VARCHAR(100) NOT NULL,
    specialties JSON,  -- {certified: ["内科", "循環器"], languages: ["英語", "中国語"]}
    consultation_fee DECIMAL(10,2),
    is_active BOOLEAN DEFAULT true,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 予約・診察履歴
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    doctor_id INT,
    patient_id INT,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    status VARCHAR(20),  -- 'scheduled', 'in_progress', 'completed', 'cancelled'
    medical_notes JSON,  -- {primary_symptom: "頭痛", severity: "中度", treatment: "投薬"}
    billing_amount DECIMAL(10,2),
    insurance_applied BOOLEAN,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- 診療科のテストデータ
INSERT INTO departments (department_id, name, settings, floor_number, is_active) VALUES
(1, '内科', '{"has_xray": true, "has_mri": false, "has_ct": true, "has_ultrasound": true}', 2, true),
(2, '整形外科', '{"has_xray": true, "has_mri": true, "has_ct": true, "has_ultrasound": true}', 2, true),
(3, '小児科', '{"has_xray": true, "has_mri": false, "has_ct": false, "has_ultrasound": true}', 3, true),
(4, '眼科', '{"has_xray": false, "has_mri": false, "has_ct": false, "has_ultrasound": false}', 4, true),
(5, '皮膚科', '{"has_xray": false, "has_mri": false, "has_ct": false, "has_ultrasound": true}', 4, true),
(6, '耳鼻咽喉科', '{"has_xray": true, "has_mri": false, "has_ct": true, "has_ultrasound": true}', 3, true),
(7, '循環器内科', '{"has_xray": true, "has_mri": true, "has_ct": true, "has_ultrasound": true}', 2, true),
(8, '消化器内科', '{"has_xray": true, "has_mri": true, "has_ct": true, "has_ultrasound": true}', 2, true);

-- 医師のテストデータ
INSERT INTO doctors (doctor_id, department_id, name, specialties, consultation_fee, is_active) VALUES
(1, 1, '山田太郎', '{"certified": ["内科", "循環器"], "languages": ["英語", "中国語"]}', 5000.00, true),
(2, 1, '鈴木花子', '{"certified": ["内科", "糖尿病"], "languages": ["英語"]}', 5000.00, true),
(3, 2, '佐藤健一', '{"certified": ["整形外科", "リハビリテーション"], "languages": ["英語"]}', 6000.00, true),
(4, 2, '田中美咲', '{"certified": ["整形外科", "スポーツ医学"], "languages": ["英語", "韓国語"]}', 6000.00, true),
(5, 3, '高橋優子', '{"certified": ["小児科", "アレルギー"], "languages": ["英語"]}', 4500.00, true),
(6, 4, '伊藤誠', '{"certified": ["眼科"], "languages": ["英語", "スペイン語"]}', 5500.00, true),
(7, 5, '渡辺和子', '{"certified": ["皮膚科", "アレルギー"], "languages": ["英語", "フランス語"]}', 5500.00, true),
(8, 6, '中村哲也', '{"certified": ["耳鼻咽喉科", "アレルギー"], "languages": ["英語"]}', 5500.00, true),
(9, 7, '小林正人', '{"certified": ["循環器内科", "内科"], "languages": ["英語", "ドイツ語"]}', 6000.00, true),
(10, 8, '加藤明美', '{"certified": ["消化器内科", "内科"], "languages": ["英語", "中国語"]}', 6000.00, true);

-- 予約・診察履歴のテストデータ（2025年2月のデータ）
INSERT INTO appointments (appointment_id, doctor_id, patient_id, appointment_date, start_time, end_time, status, medical_notes, billing_amount, insurance_applied) VALUES
-- 2月17日のデータ
(1, 1, 101, '2025-02-17', '09:00:00', '09:20:00', 'completed', '{"primary_symptom": "頭痛", "severity": "中度", "treatment": "投薬"}', 5000.00, true),
(2, 1, 102, '2025-02-17', '09:30:00', '09:55:00', 'completed', '{"primary_symptom": "めまい", "severity": "軽度", "treatment": "投薬"}', 5000.00, true),
(3, 1, 103, '2025-02-17', '10:00:00', NULL, 'cancelled', '{"primary_symptom": "発熱", "severity": "中度"}', NULL, NULL),
(4, 2, 104, '2025-02-17', '09:00:00', '09:25:00', 'completed', '{"primary_symptom": "糖尿病", "severity": "中度", "treatment": "投薬"}', 5000.00, true),
(5, 2, 105, '2025-02-17', '09:30:00', NULL, 'scheduled', '{"primary_symptom": "高血圧", "severity": "中度"}', NULL, NULL),

-- 2月18日のデータ
(6, 3, 106, '2025-02-18', '09:00:00', '09:45:00', 'completed', '{"primary_symptom": "腰痛", "severity": "重度", "treatment": "投薬・リハビリ指導"}', 8000.00, true),
(7, 3, 107, '2025-02-18', '10:00:00', NULL, 'cancelled', '{"primary_symptom": "膝の痛み", "severity": "中度"}', NULL, NULL),
(8, 4, 108, '2025-02-18', '09:00:00', '09:30:00', 'completed', '{"primary_symptom": "肩こり", "severity": "軽度", "treatment": "リハビリ指導"}', 6000.00, true),
(9, 4, 109, '2025-02-18', '09:45:00', '10:15:00', 'completed', '{"primary_symptom": "捻挫", "severity": "中度", "treatment": "固定・投薬"}', 7000.00, true),

-- 2月19日のデータ
(10, 5, 110, '2025-02-19', '09:00:00', '09:20:00', 'completed', '{"primary_symptom": "発熱", "severity": "中度", "treatment": "投薬"}', 4500.00, true),
(11, 5, 111, '2025-02-19', '09:30:00', NULL, 'cancelled', '{"primary_symptom": "咳", "severity": "軽度"}', NULL, NULL),
(12, 6, 112, '2025-02-19', '09:00:00', '09:25:00', 'completed', '{"primary_symptom": "目の痛み", "severity": "中度", "treatment": "投薬"}', 5500.00, true),
(13, 6, 113, '2025-02-19', '09:30:00', NULL, 'scheduled', '{"primary_symptom": "かすみ目", "severity": "軽度"}', NULL, NULL),

-- 2月20日のデータ
(14, 7, 114, '2025-02-20', '09:00:00', '09:30:00', 'completed', '{"primary_symptom": "湿疹", "severity": "中度", "treatment": "投薬・軟膏処方"}', 5500.00, true),
(15, 7, 115, '2025-02-20', '09:45:00', '10:15:00', 'completed', '{"primary_symptom": "アレルギー", "severity": "重度", "treatment": "投薬・生活指導"}', 7000.00, true),
(16, 8, 116, '2025-02-20', '09:00:00', '09:20:00', 'completed', '{"primary_symptom": "耳鳴り", "severity": "中度", "treatment": "投薬"}', 5500.00, true),
(17, 8, 117, '2025-02-20', '09:30:00', NULL, 'cancelled', '{"primary_symptom": "めまい", "severity": "軽度"}', NULL, NULL),

-- 2月21日のデータ
(18, 9, 118, '2025-02-21', '09:00:00', '09:40:00', 'completed', '{"primary_symptom": "胸痛", "severity": "重度", "treatment": "投薬・検査"}', 8000.00, true),
(19, 9, 119, '2025-02-21', '10:00:00', '10:30:00', 'completed', '{"primary_symptom": "動悸", "severity": "中度", "treatment": "投薬"}', 6000.00, true),
(20, 10, 120, '2025-02-21', '09:00:00', '09:35:00', 'completed', '{"primary_symptom": "腹痛", "severity": "中度", "treatment": "投薬・検査"}', 7000.00, true),

-- 午後のデータも追加
(21, 1, 121, '2025-02-17', '14:00:00', '14:25:00', 'completed', '{"primary_symptom": "頭痛", "severity": "中度", "treatment": "投薬"}', 5000.00, true),
(22, 2, 122, '2025-02-17', '14:30:00', '14:55:00', 'completed', '{"primary_symptom": "高血圧", "severity": "中度", "treatment": "投薬"}', 5000.00, true),
(23, 3, 123, '2025-02-18', '14:00:00', '14:40:00', 'completed', '{"primary_symptom": "腰痛", "severity": "中度", "treatment": "投薬・リハビリ指導"}', 7000.00, true),
(24, 4, 124, '2025-02-18', '14:30:00', NULL, 'cancelled', '{"primary_symptom": "捻挫", "severity": "軽度"}', NULL, NULL),
(25, 5, 125, '2025-02-19', '14:00:00', '14:20:00', 'completed', '{"primary_symptom": "発熱", "severity": "軽度", "treatment": "投薬"}', 4500.00, true),
(26, 6, 126, '2025-02-19', '14:30:00', '14:50:00', 'completed', '{"primary_symptom": "目の痛み", "severity": "中度", "treatment": "投薬"}', 5500.00, true),
(27, 7, 127, '2025-02-20', '14:00:00', '14:35:00', 'completed', '{"primary_symptom": "アレルギー", "severity": "中度", "treatment": "投薬"}', 5500.00, true),
(28, 8, 128, '2025-02-20', '14:30:00', '14:55:00', 'completed', '{"primary_symptom": "耳鳴り", "severity": "重度", "treatment": "投薬・検査"}', 7000.00, true),
(29, 9, 129, '2025-02-21', '14:00:00', '14:30:00', 'completed', '{"primary_symptom": "動悸", "severity": "中度", "treatment": "投薬"}', 6000.00, true),
(30, 10, 130, '2025-02-21', '14:30:00', NULL, 'cancelled', '{"primary_symptom": "腹痛", "severity": "軽度"}', NULL, NULL);
