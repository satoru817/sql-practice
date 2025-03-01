-- 患者テーブル
CREATE TABLE patients (
  patient_id INT PRIMARY KEY,
  name VARCHAR(100),
  birth_date DATE,
  gender CHAR(1),
  postal_code VARCHAR(10),
  insurance_provider VARCHAR(100),
  registration_date DATE
);

-- 医師テーブル
CREATE TABLE doctors (
  doctor_id INT PRIMARY KEY,
  name VARCHAR(100),
  specialty VARCHAR(100),
  department_id INT,
  years_experience INT
);

-- 診療科テーブル
CREATE TABLE departments (
  department_id INT PRIMARY KEY,
  name VARCHAR(100),
  building VARCHAR(50),
  floor INT,
  budget DECIMAL(12,2)
);

-- 診察テーブル
CREATE TABLE visits (
  visit_id INT PRIMARY KEY,
  patient_id INT,
  doctor_id INT,
  department_id INT,
  visit_date DATE,
  diagnosis VARCHAR(255),
  visit_cost DECIMAL(10,2),
  insurance_covered DECIMAL(10,2),
  patient_paid DECIMAL(10,2),
  followup_required BOOLEAN
);

-- 処方薬テーブル
CREATE TABLE prescriptions (
  prescription_id INT PRIMARY KEY,
  visit_id INT,
  medication_name VARCHAR(100),
  dosage VARCHAR(50),
  quantity INT,
  cost DECIMAL(8,2),
  insurance_covered DECIMAL(8,2),
  patient_paid DECIMAL(8,2)
);

-- 医療処置テーブル
CREATE TABLE procedures (
  procedure_id INT PRIMARY KEY,
  visit_id INT,
  procedure_name VARCHAR(100),
  procedure_date DATE,
  procedure_cost DECIMAL(10,2),
  insurance_covered DECIMAL(10,2),
  patient_paid DECIMAL(10,2)
);


-- 診療科テーブルのデータ
INSERT INTO departments (department_id, name, building, floor, budget) VALUES
(1, '内科', 'A棟', 2, 1200000.00),
(2, '外科', 'A棟', 3, 1500000.00),
(3, '小児科', 'B棟', 1, 900000.00),
(4, '整形外科', 'B棟', 2, 1100000.00),
(5, '皮膚科', 'A棟', 1, 800000.00);

-- 医師テーブルのデータ
INSERT INTO doctors (doctor_id, name, specialty, department_id, years_experience) VALUES
(101, '山田太郎', '循環器内科', 1, 15),
(102, '佐藤花子', '消化器内科', 1, 12),
(103, '鈴木一郎', '一般内科', 1, 8),
(104, '田中次郎', '一般外科', 2, 20),
(105, '高橋三郎', '脳外科', 2, 18),
(106, '伊藤四郎', '小児内科', 3, 10),
(107, '渡辺五郎', '小児外科', 3, 7),
(108, '小林六郎', '整形外科', 4, 14),
(109, '加藤七郎', '関節外科', 4, 9),
(110, '吉田八郎', '皮膚科', 5, 11);

-- 患者テーブルのデータ
INSERT INTO patients (patient_id, name, birth_date, gender, postal_code, insurance_provider, registration_date) VALUES
(1001, '斎藤一', '1970-05-12', 'M', '100-0001', '国民健康保険', '2022-01-10'),
(1002, '中村二', '1982-09-25', 'F', '100-0001', '社会保険', '2022-01-15'),
(1003, '小川三', '1990-03-18', 'M', '100-0002', '国民健康保険', '2022-01-20'),
(1004, '松本四', '1965-11-30', 'F', '100-0002', '後期高齢者医療', '2022-02-01'),
(1005, '井上五', '1978-07-14', 'M', '100-0003', '社会保険', '2022-02-05'),
(1006, '木村六', '1995-02-22', 'F', '100-0003', '国民健康保険', '2022-02-15'),
(1007, '清水七', '1985-04-09', 'M', '100-0004', '社会保険', '2022-03-01'),
(1008, '山口八', '1972-12-11', 'F', '100-0004', '国民健康保険', '2022-03-10'),
(1009, '中島九', '1988-08-27', 'M', '100-0005', '社会保険', '2022-03-20'),
(1010, '森十', '1991-06-05', 'F', '100-0005', '国民健康保険', '2022-04-01');

-- 診察テーブルのデータ
INSERT INTO visits (visit_id, patient_id, doctor_id, department_id, visit_date, diagnosis, visit_cost, insurance_covered, patient_paid, followup_required) VALUES
-- 2022-11
(10001, 1001, 101, 1, '2022-11-05', '高血圧', 5000.00, 4000.00, 1000.00, true),
(10002, 1002, 102, 1, '2022-11-08', '胃炎', 4500.00, 3600.00, 900.00, false),
(10003, 1003, 103, 1, '2022-11-12', '風邪', 3000.00, 2400.00, 600.00, false),
(10004, 1004, 104, 2, '2022-11-15', '胆石症', 8000.00, 6400.00, 1600.00, true),
(10005, 1005, 105, 2, '2022-11-18', '頭痛', 6000.00, 4800.00, 1200.00, true),
(10006, 1006, 106, 3, '2022-11-20', '気管支炎', 4000.00, 3200.00, 800.00, true),
(10007, 1007, 108, 4, '2022-11-22', '腰痛', 5500.00, 4400.00, 1100.00, true),
(10008, 1008, 110, 5, '2022-11-25', '湿疹', 3500.00, 2800.00, 700.00, false),

-- 2022-12
(10009, 1001, 101, 1, '2022-12-05', '高血圧フォローアップ', 4500.00, 3600.00, 900.00, true),
(10010, 1004, 104, 2, '2022-12-10', '胆石症フォローアップ', 7000.00, 5600.00, 1400.00, false),
(10011, 1005, 105, 2, '2022-12-15', '頭痛フォローアップ', 5500.00, 4400.00, 1100.00, false),
(10012, 1006, 106, 3, '2022-12-18', '気管支炎フォローアップ', 3500.00, 2800.00, 700.00, false),
(10013, 1007, 108, 4, '2022-12-20', '腰痛フォローアップ', 5000.00, 4000.00, 1000.00, true),
(10014, 1009, 103, 1, '2022-12-22', 'インフルエンザ', 6000.00, 4800.00, 1200.00, true),
(10015, 1010, 110, 5, '2022-12-28', 'アトピー性皮膚炎', 4000.00, 3200.00, 800.00, true),

-- 2023-01
(10016, 1001, 101, 1, '2023-01-05', '高血圧フォローアップ', 4500.00, 3600.00, 900.00, true),
(10017, 1007, 108, 4, '2023-01-10', '腰痛フォローアップ', 5000.00, 4000.00, 1000.00, false),
(10018, 1009, 103, 1, '2023-01-15', 'インフルエンザフォローアップ', 4000.00, 3200.00, 800.00, false),
(10019, 1010, 110, 5, '2023-01-20', 'アトピー性皮膚炎フォローアップ', 3500.00, 2800.00, 700.00, true),
(10020, 1002, 102, 1, '2023-01-22', '食中毒', 5500.00, 4400.00, 1100.00, false),
(10021, 1003, 107, 3, '2023-01-25', '扁桃腺炎', 4500.00, 3600.00, 900.00, true),
(10022, 1008, 109, 4, '2023-01-28', '肩こり', 4000.00, 3200.00, 800.00, false),

-- 2023-02
(10023, 1001, 101, 1, '2023-02-05', '高血圧フォローアップ', 4500.00, 3600.00, 900.00, true),
(10024, 1010, 110, 5, '2023-02-10', 'アトピー性皮膚炎フォローアップ', 3500.00, 2800.00, 700.00, false),
(10025, 1003, 107, 3, '2023-02-15', '扁桃腺炎フォローアップ', 4000.00, 3200.00, 800.00, false),
(10026, 1005, 102, 1, '2023-02-18', '逆流性食道炎', 5000.00, 4000.00, 1000.00, true),
(10027, 1006, 106, 3, '2023-02-20', '喘息', 6000.00, 4800.00, 1200.00, true),
(10028, 1009, 104, 2, '2023-02-25', '虫垂炎', 9000.00, 7200.00, 1800.00, true),
(10029, 1004, 105, 2, '2023-02-28', '脳震盪', 8000.00, 6400.00, 1600.00, true);

-- 処方薬テーブルのデータ
INSERT INTO prescriptions (prescription_id, visit_id, medication_name, dosage, quantity, cost, insurance_covered, patient_paid) VALUES
(20001, 10001, '降圧剤A', '1日1錠', 30, 3000.00, 2400.00, 600.00),
(20002, 10002, '胃腸薬B', '1日2錠', 60, 2500.00, 2000.00, 500.00),
(20003, 10003, '解熱鎮痛剤C', '1日3錠', 15, 1000.00, 800.00, 200.00),
(20004, 10004, '鎮痛剤D', '1日2錠', 30, 2000.00, 1600.00, 400.00),
(20005, 10005, '頭痛薬E', '1日1錠', 30, 1500.00, 1200.00, 300.00),
(20006, 10006, '抗生物質F', '1日3錠', 15, 3000.00, 2400.00, 600.00),
(20007, 10007, '湿布G', '1日2枚', 20, 1000.00, 800.00, 200.00),
(20008, 10008, '軟膏H', '1日2回', 1, 1500.00, 1200.00, 300.00),
(20009, 10009, '降圧剤A', '1日1錠', 30, 3000.00, 2400.00, 600.00),
(20010, 10014, '抗インフルエンザ薬I', '1日2錠', 5, 5000.00, 4000.00, 1000.00),
(20011, 10015, 'ステロイド軟膏J', '1日2回', 1, 2000.00, 1600.00, 400.00),
(20012, 10016, '降圧剤A', '1日1錠', 30, 3000.00, 2400.00, 600.00),
(20013, 10018, '解熱鎮痛剤C', '1日2錠', 10, 800.00, 640.00, 160.00),
(20014, 10019, 'ステロイド軟膏J', '1日1回', 1, 2000.00, 1600.00, 400.00),
(20015, 10020, '整腸剤K', '1日3錠', 15, 1200.00, 960.00, 240.00),
(20016, 10021, '抗生物質F', '1日3錠', 10, 2500.00, 2000.00, 500.00),
(20017, 10023, '降圧剤A', '1日1錠', 30, 3000.00, 2400.00, 600.00),
(20018, 10025, '抗生物質F', '1日3錠', 5, 1500.00, 1200.00, 300.00),
(20019, 10026, '制酸剤L', '1日2錠', 30, 2000.00, 1600.00, 400.00),
(20020, 10027, '気管支拡張剤M', '1日2吸入', 1, 4000.00, 3200.00, 800.00);

-- 医療処置テーブルのデータ
INSERT INTO procedures (procedure_id, visit_id, procedure_name, procedure_date, procedure_cost, insurance_covered, patient_paid) VALUES
(30001, 10004, '腹部エコー検査', '2022-11-15', 15000.00, 12000.00, 3000.00),
(30002, 10005, '頭部CT検査', '2022-11-18', 25000.00, 20000.00, 5000.00),
(30003, 10007, '腰部X線検査', '2022-11-22', 12000.00, 9600.00, 2400.00),
(30004, 10010, '腹部エコー検査', '2022-12-10', 15000.00, 12000.00, 3000.00),
(30005, 10013, '腰部MRI検査', '2022-12-20', 30000.00, 24000.00, 6000.00),
(30006, 10028, '腹部CT検査', '2023-02-25', 20000.00, 16000.00, 4000.00),
(30007, 10029, '頭部MRI検査', '2023-02-28', 35000.00, 28000.00, 7000.00);
