はい。医療機関の予約・受診データの分析に関する問題を出題させていただきます。

```sql
-- 診療科マスタ
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    capacity_per_hour INT NOT NULL,  -- 1時間あたりの受入可能人数
    settings JSON,  -- 診療科固有の設定（予約可否、特殊機器の有無など）
    is_active BOOLEAN DEFAULT true
);

-- 医師マスタ
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    specialties JSON,  -- 専門分野、資格など
    schedule JSON,  -- 勤務スケジュール
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 予約・受診記録
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    patient_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL,  -- 予約済み、受診済み、キャンセルなど
    medical_notes JSON,  -- 症状、処置内容など
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
```

サンプルデータ：
```sql
-- 診療科データ
INSERT INTO departments (department_id, name, capacity_per_hour, settings) VALUES
(1, '内科', 6, '{"requires_reservation": true, "has_xray": true}'),
(2, '小児科', 4, '{"requires_reservation": true, "has_playground": true}'),
(3, '整形外科', 3, '{"requires_reservation": true, "has_xray": true, "has_mri": true}'),
(4, '歯科', 2, '{"requires_reservation": false, "has_ct": false}');

-- 医師データ
INSERT INTO doctors (doctor_id, name, department_id, specialties, schedule) VALUES
(1, '山田太郎', 1, '{"certified": ["総合内科", "循環器"], "languages": ["日本語", "英語"]}', '{"monday": true, "tuesday": true, "wednesday": false}'),
(2, '鈴木花子', 2, '{"certified": ["小児科"], "languages": ["日本語"]}', '{"monday": true, "wednesday": true, "friday": true}'),
(3, '田中一郎', 1, '{"certified": ["総合内科", "消化器"], "languages": ["日本語", "中国語"]}', '{"tuesday": true, "thursday": true, "friday": true}');

-- 予約・受診データ
INSERT INTO appointments (doctor_id, patient_id, appointment_datetime, status, medical_notes) VALUES
(1, 101, '2025-02-14 09:00:00', 'completed', '{"primary_symptom": "発熱", "temperature": 38.5, "prescribed": true}'),
(1, 102, '2025-02-14 09:30:00', 'completed', '{"primary_symptom": "頭痛", "prescribed": true}'),
(2, 201, '2025-02-14 10:00:00', 'cancelled', '{"cancellation_reason": "体調改善"}'),
(3, 301, '2025-02-14 11:00:00', 'completed', '{"primary_symptom": "腹痛", "prescribed": true}');
```

問題：

1. 診療科ごとの統計情報を出力してください：
   - 診療科名
   - 所属医師数
   - 予約件数
   - 実際の受診件数（status = 'completed'のみ）
   - 診療科の特殊機器の有無（X線, MRI, CTの各機器の有無をカンマ区切りで表示）
   条件：アクティブな診療科（is_active = true）のみを対象とし、予約件数順にソート

2. 医師ごとの受診実績を分析してください：
   - 医師名
   - 診療科名
   - 保有資格数（specialties.certifiedの配列の要素数）
   - 対応可能言語数（specialties.languagesの配列の要素数）
   - 主な症状の集計（medical_notes.primary_symptomの出現回数）
   条件：完了した予約（status = 'completed'）のみを対象とし、JSON_TABLE等は使用せず実装してください

ヒント：
- JSON配列の要素数は `JSON_LENGTH` 関数で取得できます
- 複数の機器の有無は `CONCAT_WS` 関数を使うと効率的です
- サンプルデータは少ないですが、実際の運用を想定したクエリを作成してください
