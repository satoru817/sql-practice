医療システムのデータ分析に関する複雑な問題を出題させていただきます。

以下のテーブル構造で、より実践的で複雑な分析が必要な問題です：

```sql
-- 診療科
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    settings JSON,  -- {has_xray: true, has_mri: false, has_ct: true, ...}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 医師
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    department_id INT,
    name VARCHAR(100) NOT NULL,
    specialties JSON,  -- {certified: ["内科", "循環器"], languages: ["英語", "中国語"]}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 予約・診療記録
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    doctor_id INT,
    patient_id INT,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL,  -- 'scheduled', 'completed', 'cancelled'
    medical_notes JSON,  -- {primary_symptom: "頭痛", severity: "中度", treatment: ["投薬", "検査"]}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
```

問題：以下の条件を満たすレポートを作成してください。

1. 各診療科について以下の情報を表示：
   - 診療科名
   - 保有している医療機器の一覧（カンマ区切りの文字列）
   - その診療科に所属する医師数
   - 完了した予約数と予約のキャンセル率
   - 所属する医師の専門資格の種類数（重複を除く）

2. さらに、以下の条件を満たすこと：
   - キャンセル率は小数点2位までパーセント表示（例：23.45%）
   - 医療機器がない場合は「なし」と表示
   - すべての診療科を表示（予約や医師が0でも表示）
   - 医師の専門資格数が多い順にソート
   - 同じ専門資格数の場合は、完了した予約数が多い順にソート

3. 結果の各列に日本語でわかりやすい別名をつけること

このクエリでは以下のような技術が必要です：
- JSON操作
- 複数階層のJOIN
- 集計関数の組み合わせ
- 条件付き集計
- JSON配列の展開と集計
- 複数条件でのソート
- NULL値の適切な処理
