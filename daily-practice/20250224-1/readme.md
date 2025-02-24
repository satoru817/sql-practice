医療システムのデータ分析に関する以下の課題を出題させていただきます。

## 課題：複合診療科分析システムの実装

以下のテーブル構造を持つ医療システムで、診療科別・医師別の詳細な分析を行うクエリを実装してください。

```sql
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
```

## 要件

以下の条件を満たす分析レポートを作成してください：

1. 診療科別の統計情報
   - 診療科名
   - 保有設備のリスト（カンマ区切り）
   - 所属医師数
   - 完了した予約数
   - キャンセル率
   - 保険適用率
   - 総診療収入

2. 医師別の詳細統計
   - 医師名と所属診療科
   - 資格・言語情報（整形して表示）
   - 診療実績（患者数、完了率）
   - 主な症状TOP3（出現回数順）
   - 平均診療時間
   - 総診療収入と保険適用率

3. 時間帯別の予約分析
   - 時間帯ごとの予約数
   - 診療科別の繁忙時間帯
   - キャンセル率の高い時間帯
   - 平均診療時間

以下の条件を考慮してください：
- JSON_TABLEを適切に使用
- パフォーマンスを意識した実装
- NULL値の適切な処理
- 集計値の小数点以下の桁数管理
- 可読性の高いクエリ構造

この課題は実務でよく発生する複雑なデータ分析の実装力を試すものです。ご回答をお待ちしています。


はい、時間帯別の予約分析の要件をより具体的に説明させていただきます。

## 3. 時間帯別の予約分析レポート作成

以下の情報を含むレポートを作成してください：

### A. 時間帯別の基本統計
1. 1時間ごとの時間帯区分（9:00-10:00, 14:00-15:00など）
2. 各時間帯における：
   - 予約総数
   - 完了した予約数
   - キャンセルされた予約数
   - キャンセル率（パーセント表示、小数点2桁）

### B. 診療科別の時間帯分析
1. 各診療科の時間帯ごとの：
   - 予約件数
   - 平均診療時間（分単位）
   - 最長診療時間（分単位）
   - 最短診療時間（分単位）

### C. 効率性分析
1. 各時間帯の：
   - 予約時間と実際の診療時間の平均差（分単位）
   - 診療完了率
   - 予約枠の使用率

### D. パフォーマンス指標
1. 時間帯別の：
   - 平均診療収入
   - 保険適用率
   - 重症度別の患者数（軽度/中度/重度）

出力形式の例：
```
Time Slot  | Total | Completed | Cancelled | Cancel Rate | Avg Duration | Avg Income
09:00-10:00|    10 |         8 |         2 |      20.00% |      25 mins |    5500.00
14:00-15:00|     8 |         6 |         2 |      25.00% |      28 mins |    6000.00
```

この分析により、予約スケジュールの最適化や診療効率の改善に役立つ情報が得られることを期待しています。X
