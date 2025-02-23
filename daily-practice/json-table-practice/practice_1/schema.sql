CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    medical_history JSON
);

INSERT INTO patients VALUES
(1, '山田太郎', '{"allergies": ["花粉", "ハウスダスト"], "blood_type": "A", "height": 170}'),
(2, '佐藤花子', '{"allergies": ["牛乳"], "blood_type": "O", "height": 155}'),
(3, '鈴木一郎', '{"allergies": [], "blood_type": "B", "height": 180}');
