CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    profile JSON
);

INSERT INTO doctors VALUES
(1, '山田医師', '{"specialties": ["内科", "循環器科"], "languages": {"primary": "日本語", "foreign": ["英語", "中国語"]}}'),
(2, '鈴木医師', '{"specialties": ["小児科"], "languages": {"primary": "日本語", "foreign": ["英語"]}}'),
(3, '佐藤医師', '{"specialties": ["外科", "整形外科"], "languages": {"primary": "日本語", "foreign": []}}');
