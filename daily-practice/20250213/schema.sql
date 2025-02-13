-- 医師マスタ
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    specialties JSON,  -- 専門分野を配列で格納 ["内科", "消化器科"]
    status VARCHAR(20)
);

-- 患者マスタ
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    birth_date DATE,
    medical_history JSON  -- 既往歴を{"condition": "疾患名", "year": "発症年"}の形式で配列格納
);

-- 診療記録
CREATE TABLE medical_records (
    record_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    visit_date DATE,
    diagnosis JSON,  -- 診断内容を{"primary": "主病名", "secondary": ["副病名1", "副病名2"]}で格納
    treatment_status VARCHAR(20),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- 処方箋
CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY,
    record_id INT,
    medicines JSON,  -- 薬剤情報を[{"name": "薬剤名", "amount": "用量"}]で格納
    prescribed_date DATE,
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id)
);

-- 医師データ
INSERT INTO doctors (doctor_id, name, department, specialties, status) VALUES
(1, '山田太郎', '内科', '["内科", "消化器科", "循環器科"]', 'active'),
(2, '鈴木花子', '内科', '["内科", "消化器科"]', 'active'),
(3, '佐藤次郎', '外科', '["外科", "消化器科"]', 'active'),
(4, '田中美咲', '内科', '["内科", "糖尿病科"]', 'active'),
(5, '伊藤健一', '外科', '["外科", "整形外科"]', 'inactive');

-- 患者データ
INSERT INTO patients (patient_id, name, birth_date, medical_history) VALUES
(1, '高橋優子', '1990-05-15', '[{"condition": "高血圧", "year": "2020"}, {"condition": "胃炎", "year": "2021"}]'),
(2, '中村太一', '1985-08-22', '[{"condition": "糖尿病", "year": "2019"}]'),
(3, '小林さくら', '1995-03-10', '[{"condition": "高血圧", "year": "2022"}, {"condition": "不眠症", "year": "2023"}]'),
(4, '加藤健二', '1978-12-03', '[{"condition": "高血圧", "year": "2018"}, {"condition": "高脂血症", "year": "2021"}]'),
(5, '吉田麻衣', '2000-01-25', '[]'),
(6, '山本裕子', '1992-07-18', '[{"condition": "胃潰瘍", "year": "2023"}]');

-- 診療記録
INSERT INTO medical_records (record_id, patient_id, doctor_id, visit_date, diagnosis, treatment_status) VALUES
(1, 1, 1, '2024-01-05', '{"primary": "内科検診", "secondary": ["軽度高血圧"]}', 'completed'),
(2, 1, 1, '2024-01-15', '{"primary": "内科検診", "secondary": ["高血圧"]}', 'completed'),
(3, 1, 2, '2024-01-25', '{"primary": "消化器科検診", "secondary": ["胃炎"]}', 'completed'),
(4, 2, 4, '2024-01-10', '{"primary": "内科検診", "secondary": ["糖尿病"]}', 'completed'),
(5, 3, 1, '2024-01-08', '{"primary": "内科検診", "secondary": ["高血圧"]}', 'completed'),
(6, 3, 1, '2024-01-20', '{"primary": "内科検診", "secondary": ["高血圧", "不眠症"]}', 'completed'),
(7, 4, 2, '2024-01-12', '{"primary": "消化器科検診", "secondary": []}', 'completed'),
(8, 5, 3, '2024-01-18', '{"primary": "外科検診", "secondary": ["急性胃炎"]}', 'completed'),
(9, 6, 2, '2024-01-22', '{"primary": "消化器科検診", "secondary": ["胃潰瘍"]}', 'completed'),
(10, 1, 1, '2023-12-05', '{"primary": "内科検診", "secondary": ["高血圧"]}', 'completed'),
(11, 3, 1, '2023-12-15', '{"primary": "内科検診", "secondary": ["高血圧"]}', 'completed'),
(12, 4, 1, '2023-12-20', '{"primary": "内科検診", "secondary": ["高血圧", "高脂血症"]}', 'completed');

-- 処方箋
INSERT INTO prescriptions (prescription_id, record_id, medicines, prescribed_date) VALUES
(1, 1, '[{"name": "アムロジピン", "amount": "5mg"}, {"name": "ファモチジン", "amount": "20mg"}]', '2024-01-05'),
(2, 2, '[{"name": "アムロジピン", "amount": "5mg"}]', '2024-01-15'),
(3, 3, '[{"name": "ファモチジン", "amount": "20mg"}, {"name": "レバミピド", "amount": "100mg"}]', '2024-01-25'),
(4, 4, '[{"name": "メトホルミン", "amount": "500mg"}]', '2024-01-10'),
(5, 5, '[{"name": "アムロジピン", "amount": "5mg"}, {"name": "オルメサルタン", "amount": "20mg"}]', '2024-01-08'),
(6, 6, '[{"name": "アムロジピン", "amount": "5mg"}, {"name": "ゾルピデム", "amount": "5mg"}]', '2024-01-20'),
(7, 7, '[{"name": "ファモチジン", "amount": "20mg"}]', '2024-01-12'),
(8, 8, '[{"name": "ファモチジン", "amount": "20mg"}, {"name": "レバミピド", "amount": "100mg"}]', '2024-01-18'),
(9, 9, '[{"name": "ランソプラゾール", "amount": "15mg"}, {"name": "レバミピド", "amount": "100mg"}]', '2024-01-22'),
(10, 10, '[{"name": "アムロジピン", "amount": "5mg"}]', '2023-12-05'),
(11, 11, '[{"name": "アムロジピン", "amount": "5mg"}, {"name": "オルメサルタン", "amount": "20mg"}]', '2023-12-15'),
(12, 12, '[{"name": "アムロジピン", "amount": "5mg"}, {"name": "アトルバスタチン", "amount": "10mg"}]', '2023-12-20');
