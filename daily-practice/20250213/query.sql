以下の分析を行うSQLを作成してください：

1. 専門分野に「消化器科」を含む医師の、2024年1月の診療件数と、処方した薬剤の種類数を求めてください。

2. 内科系の診療（primaryが"内科"で始まる）について、患者の年代別（10代、20代...）の診療件数と、最も多く処方された薬剤TOP3を抽出してください。その際、処方箋が存在しない診療も件数には含めてください。

3. 過去に「高血圧」の既往歴がある患者の、直近3回の診療記録について、診断名と処方薬をリスト形式で取得してください。

期待される実装のポイント：
- JSON操作の適切な使用
- 結合の最適化（INNER/LEFT JOINの使い分け）
- CTEを使用した段階的な処理
- 集計と順位付けの組み合わせ
- NULL値の適切な処理

なお、上記のテーブルはすでにデータが入っており、各カラムのNULL制約や一意性制約は適切に設定されているものとします。

このクエリを実装することで、JSON処理、複数テーブルの結合、Window関数の使用など、これまでの学習内容を総合的に活用することができます。

1. 各医師の専門分野に「消化器科」を含む医師の、2024年1月の診療件数と、処方した薬剤の種類数を求めてください。

--私の解答
with record_stats as (
    select 
        d.doctor_id,
        count(m.record_id) as records
    from
        doctors d
        inner join medical_records m on m.doctor_id = d.doctor_id
    where
        date_format(m.visit_date,'%Y-%m')='2024-01'
        and json_contains(d.specialties,'"消化器科"')
    group by
        d.doctor_id
),
medicine_stats as (
    select
        d.name,
        d.doctor_id,
        count(distinct jt.name) as medicines
    from
        doctors d
        inner join medical_records m on m.doctor_id = d.doctor_id
        inner join prescriptions p on p.record_id = m.record_id
        inner join json_table(
            p.medicines,'$[*]'
            columns(name VARCHAR(255) PATH '$.name')          
        ) jt
    WHERE
    	date_format(m.visit_date,'%Y-%m')='2024-01'
    	and json_contains(d.specialties,'"消化器科"')
    group by
        d.name,
        d.doctor_id
)
select
    ms.name,
    rs.records,
    ms.medicines
from
    medicine_stats ms
    inner join record_stats rs on rs.doctor_id = ms.doctor_id;

--実行結果

|name|records|medicines|
|----|-------|---------|
|山田太郎|4      |4        |
|鈴木花子|3      |3        |
|佐藤次郎|1      |2        |

--AIの評価

あなたの解答を採点させていただきます。

## 評価：90/100点

### 良い点 👍
1. CTEを使用して複雑なクエリを適切に分割（record_stats, medicine_stats）
2. JSON_CONTAINSを使用して専門分野の判定を適切に実装
3. JSON_TABLEを使用して薬剤データを適切に展開
4. INNER JOINの使用が適切（この要件では存在するデータのみ必要）
5. GROUP BYとDISTINCTを使用して正確な集計を実現

### 改善の余地 🔧
1. **日付のフィルタリング処理**
   ```sql
   -- 現在の実装
   date_format(m.visit_date,'%Y-%m')='2024-01'
   
   -- より効率的な実装案
   visit_date >= '2024-01-01' AND visit_date < '2024-02-01'
   ```
   - インデックスを活用できる形式に変更することでパフォーマンスが向上

2. **医師の状態確認**
   ```sql
   -- 追加すべき条件
   AND d.status = 'active'
   ```
   - 現役の医師のみを対象とする条件が未指定

3. **結果のソート**
   ```sql
   -- 追加すべき
   ORDER BY records DESC, name
   ```
   - 結果の順序が未指定

### 実行結果の正確性 ✅
- 取得された結果は正確
- 医師ごとの診療件数と処方薬剤数が適切に計算されている

### 総評
非常によく構造化されたクエリで、JSON操作とJOINの理解が十分に示されています。特にCTEを使用した段階的な処理と、JSON_TABLEを使用したJSON配列の展開が効果的です。小さな改善点はありますが、基本的な要件は十分に満たしています。

引き続き2問目、3問目にチャレンジしてみましょう！


    





    
