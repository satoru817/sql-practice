問題：以下の分析を行うSQLクエリを作成してください。

1. 各顧客のRFMスコアを計算し、以下の情報を含むJSONとして出力してください：
   - 最終購入日（Recency）
   - 購入頻度（Frequency）
   - 総購入金額（Monetary）
   - 購入した商品カテゴリの分布
   - 顧客の趣味（profile_dataから抽出）

2. 分析結果から以下の条件で顧客をセグメント化してください：
   - VIP：過去3ヶ月以内に購入があり、総購入回数が10回以上、総購入金額が100万円以上
   - 優良顧客：過去6ヶ月以内に購入があり、総購入回数が5回以上、総購入金額が50万円以上
   - 通常顧客：上記以外で過去1年以内に購入がある
   - 離反顧客：1年以上購入がない

注意点：
- 現在の日付は CURRENT_TIMESTAMP を使用
- JSONデータの抽出にはJSON_EXTRACT関数を使用
- 金額はすべて日本円とする
- NULL値の適切な処理を行う

このクエリでは、以下のような新しい要素が含まれています：
- JSON型データの処理
- RFM分析の実装
- 複数の条件による顧客セグメント化
- 日付計算と条件分岐の組み合わせ
- 集計結果のJSON形式での出力


--いきなり全部はきついので準備

with cat_cust_stats as (
    select distinct
        cust.customer_id,
        cust.name as customer_name,
        cat.name as category_name,
        sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id, cat.category_id)as amount,
        round(100.0*sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id, cat.category_id)/sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id),0) as percentage
    from
        customers cust
        inner join orders o on o.customer_id = cust.customer_id
        inner join order_items oi on oi.order_id = o.order_id
        inner join products pr on pr.product_id = oi.product_id
        inner join categories cat on cat.category_id = pr.category_id
)
select
    ccs.customer_name,
    ccs.category_name,
    concat('{ amount:',round(ccs.amount),',','percentage:',percentage,' }') as distribution
from
    cat_cust_stats ccs;

|customer_name|category_name|distribution                    |
|-------------|-------------|--------------------------------|
|山田太郎         |バッグ          |{ amount:180000,percentage:21 } |
|山田太郎         |ワイン          |{ amount:420000,percentage:49 } |
|山田太郎         |時計           |{ amount:250000,percentage:29 } |
|鈴木花子         |バッグ          |{ amount:150000,percentage:46 } |
|鈴木花子         |食品           |{ amount:95000,percentage:29 }  |
|鈴木花子         |ガジェット        |{ amount:78000,percentage:24 }  |
|佐藤健一         |食品           |{ amount:45000,percentage:58 }  |
|佐藤健一         |ガジェット        |{ amount:32000,percentage:42 }  |
|田中美咲         |食品           |{ amount:28000,percentage:44 }  |
|田中美咲         |ガジェット        |{ amount:35000,percentage:56 }  |
|渡辺修平         |時計           |{ amount:320000,percentage:100 }|
|中村優子         |食品           |{ amount:172000,percentage:47 } |
|中村優子         |ワイン          |{ amount:196000,percentage:53 } |
|木村達也         |時計           |{ amount:890000,percentage:79 } |
|木村達也         |ワイン          |{ amount:230000,percentage:21 } |
|斎藤美穂         |バッグ          |{ amount:195000,percentage:76 } |
|斎藤美穂         |ガジェット        |{ amount:60000,percentage:24 }  |
|高橋純平         |時計           |{ amount:600000,percentage:60 } |
|高橋純平         |ワイン          |{ amount:400000,percentage:40 } |
|伊藤さくら        |食品           |{ amount:53000,percentage:62 }  |
|伊藤さくら        |ガジェット        |{ amount:32000,percentage:38 }  |


これはうまくいった。

はい、商品カテゴリの分布については、以下のような情報を想定しています：

1. 各顧客が購入した商品の**カテゴリ別の購入金額と割合**です。例えば：
```json
"category_distribution": {
    "時計": {"amount": 250000, "percentage": 40},
    "バッグ": {"amount": 180000, "percentage": 30},
    "ワイン": {"amount": 180000, "percentage": 30}
}
```

これをとりあえず作る


with cat_cust_stats as (
    select distinct
        cust.customer_id,
        cust.name as customer_name,
        cat.name as category_name,
        sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id, cat.category_id)as amount,
        round(100.0*sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id, cat.category_id)/sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id),0) as percentage
    from
        customers cust
        inner join orders o on o.customer_id = cust.customer_id
        inner join order_items oi on oi.order_id = o.order_id
        inner join products pr on pr.product_id = oi.product_id
        inner join categories cat on cat.category_id = pr.category_id
),
cat_stats as (
	select
	    ccs.customer_name,
	    ccs.category_name,
	    concat(ccs.category_name,' :{ amount:',round(ccs.amount),',','percentage:',percentage,' }') as distribution
	from
	    cat_cust_stats ccs
)
select
	cs.customer_name,
	GROUP_CONCAT(
		cs.distribution
		order by cs.category_name
		separator ','
	) as category_distribution
FROM
	cat_stats cs
group by
	cs.customer_name;


|customer_name|category_distribution                                                                                     |
|-------------|----------------------------------------------------------------------------------------------------------|
|中村優子         |ワイン:{ amount:196000,percentage:53 },食品:{ amount:172000,percentage:47 }                                    |
|伊藤さくら        |ガジェット:{ amount:32000,percentage:38 },食品:{ amount:53000,percentage:62 }                                    |
|佐藤健一         |ガジェット:{ amount:32000,percentage:42 },食品:{ amount:45000,percentage:58 }                                    |
|山田太郎         |バッグ:{ amount:180000,percentage:21 },ワイン:{ amount:420000,percentage:49 },時計:{ amount:250000,percentage:29 }|
|斎藤美穂         |ガジェット:{ amount:60000,percentage:24 },バッグ:{ amount:195000,percentage:76 }                                  |
|木村達也         |ワイン:{ amount:230000,percentage:21 },時計:{ amount:890000,percentage:79 }                                    |
|渡辺修平         |時計:{ amount:320000,percentage:100 }                                                                       |
|田中美咲         |ガジェット:{ amount:35000,percentage:56 },食品:{ amount:28000,percentage:44 }                                    |
|鈴木花子         |ガジェット:{ amount:78000,percentage:24 },バッグ:{ amount:150000,percentage:46 },食品:{ amount:95000,percentage:29 }|
|高橋純平         |ワイン:{ amount:400000,percentage:40 },時計:{ amount:600000,percentage:60 }                                    |



とりあえずここまではOK
あとはほかをつなぐ


with cat_cust_stats as (
    select distinct
        cust.customer_id,
        cust.name as customer_name,
        cat.name as category_name,
        sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id, cat.category_id)as category_amount,
        max(o.order_date) over (partition by cust.customer_id) as recency,
        sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id) as total_amount,
        round(timestampdiff(day,min(o.order_date) over (partition by cust.customer_id),max(o.order_date) over (partition by cust.customer_id))/count(distinct o.order_id) over (partition by cust.customer_id),0) as frequency,
        json_extract(cust.profile_data,'$.hobbies') as hobbies
    from
        customers cust
        inner join orders o on o.customer_id = cust.customer_id
        inner join order_items oi on oi.order_id = o.order_id
        inner join products pr on pr.product_id = oi.product_id
        inner join categories cat on cat.category_id = pr.category_id
),
cat_stats as (
	select
        ccs.customer_id,
	    ccs.customer_name,
	    ccs.category_name,
        concat('"',ccs.category_name,'"{ "amount":',round(ccs.total_amount),',','"percentage":',round(100.0*ccs.category_amount/ccs.total_amount,0),' }') as distribution
	from
	    cat_cust_stats ccs
),
cat_distributions as (
    select
        cs.customer_id,
	    cs.customer_name,
	    json_arragg(
		    cs.distribution
	    ) as category_distribution
    FROM
	    cat_stats cs
    group by
	    cs.customer_name
)
select
    distinct
    ccs.customer_name,
    ccs.recency,
    ccs.total_amount as monetary,
    cd.category_distribution,
    ccs.hobbies
from
    cat_cust_stats ccs
    inner join cat_distributions cd on cd.customer_id = ccs.customer_id;

これで行けると思ったが、

--Error occurred during SQL query execution

--Reason:
--SQL Error [1235] [42000]: This version of MySQL doesn't yet support '<window function>(DISTINCT ..)'

　このエラーがでた


count(distinct o.order_id) over (partition by cust.customer_id)

これがエラーの原因

count内部でdistinctは利用できない。ということで、RFMは別のクエリで計算せざるを得ない。


with cat_cust_stats as (
    select distinct
        cust.customer_id,
        cust.name as customer_name,
        cat.name as category_name,
        sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id, cat.category_id)as amount,
        round(100.0*sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id, cat.category_id)/sum(oi.quantity*oi.unit_price) over (partition by cust.customer_id),0) as percentage
    from
        customers cust
        inner join orders o on o.customer_id = cust.customer_id
        inner join order_items oi on oi.order_id = o.order_id
        inner join products pr on pr.product_id = oi.product_id
        inner join categories cat on cat.category_id = pr.category_id
),
cat_stats as (
	select
        ccs.customer_id,
	    ccs.customer_name,
	    ccs.category_name,
	    concat('"',ccs.category_name,'": { "amount":',round(ccs.amount),',','"percentage":',ccs.percentage,' }') as distribution
	from
	    cat_cust_stats ccs
),
cust_cat_distributions as (
    select
        cs.customer_id,
	    cs.customer_name,
	    json_arrayagg(
		    cs.distribution
	    ) as category_distribution
    FROM
	    cat_stats cs
    group by
	    cs.customer_name,
        cs.customer_id
),
cust_stats as (
    select
        cust.customer_id,
        max(o.order_date) as recency,
        round(timestampdiff(day,min(o.order_date),max(o.order_date))/nullif(count(o.order_id),0),0) as frequency,
        sum(o.total_amount) as monetary,
        json_extract(cust.profile_data,'$.hobbies') as hobbies
    from
        customers cust
        inner join orders o on o.customer_id = cust.customer_id
    group by
        cust.customer_id
)
select
    ccd.customer_name,
    cs.recency,
    cs.frequency,
    cs.monetary,
    cs.hobbies,
    ccd.category_distribution
from
    cust_cat_distributions ccd
    inner join cust_stats cs on cs.customer_id = ccd.customer_id;

--実行結果

|customer_name|recency            |frequency|monetary |hobbies                        |category_distribution                                                                                                                                                                |
|-------------|-------------------|---------|---------|-------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|山田太郎         |2025-01-21 08:49:08|20       |850,000  |"[\"読書\", \"ゴルフ\"]"            |"[\"\\"ワイン\\": { \\"amount\\":420000,\\"percentage\\":49 }\", \"\\"時計\\": { \\"amount\\":250000,\\"percentage\\":29 }\", \"\\"バッグ\\": { \\"amount\\":180000,\\"percentage\\":21 }\"]"|
|鈴木花子         |2025-01-06 08:49:08|50       |323,000  |"[\"料理\", \"ヨガ\"]"             |"[\"\\"ガジェット\\": { \\"amount\\":78000,\\"percentage\\":24 }\", \"\\"食品\\": { \\"amount\\":95000,\\"percentage\\":29 }\", \"\\"バッグ\\": { \\"amount\\":150000,\\"percentage\\":46 }\"]"|
|佐藤健一         |2024-09-08 08:49:08|75       |77,000   |"[\"釣り\", \"カメラ\"]"            |"[\"\\"ガジェット\\": { \\"amount\\":32000,\\"percentage\\":42 }\", \"\\"食品\\": { \\"amount\\":45000,\\"percentage\\":58 }\"]"                                                            |
|田中美咲         |2024-01-02 08:49:08|50       |63,000   |"[\"旅行\", \"カフェ巡り\"]"          |"[\"\\"食品\\": { \\"amount\\":28000,\\"percentage\\":44 }\", \"\\"ガジェット\\": { \\"amount\\":35000,\\"percentage\\":56 }\"]"                                                            |
|渡辺修平         |2025-01-31 08:49:08|0        |320,000  |"[\"ワイン\", \"美術\"]"            |"[\"\\"時計\\": { \\"amount\\":320000,\\"percentage\\":100 }\"]"                                                                                                                       |
|中村優子         |2025-01-28 09:20:30|20       |368,000  |"[\"ワイン\", \"料理\", \"ガーデニング\"]"|"[\"\\"ワイン\\": { \\"amount\\":196000,\\"percentage\\":53 }\", \"\\"食品\\": { \\"amount\\":172000,\\"percentage\\":47 }\"]"                                                            |
|木村達也         |2025-01-26 09:20:30|20       |1,120,000|"[\"テニス\", \"時計収集\"]"          |"[\"\\"時計\\": { \\"amount\\":890000,\\"percentage\\":79 }\", \"\\"ワイン\\": { \\"amount\\":230000,\\"percentage\\":21 }\"]"                                                            |
|斎藤美穂         |2025-01-21 09:20:30|20       |255,000  |"[\"ファッション\", \"スイーツ巡り\"]"     |"[\"\\"バッグ\\": { \\"amount\\":195000,\\"percentage\\":76 }\", \"\\"ガジェット\\": { \\"amount\\":60000,\\"percentage\\":24 }\"]"                                                          |
|高橋純平         |2025-01-16 09:20:30|80       |1,000,000|"[\"ゴルフ\", \"ワイン\"]"           |"[\"\\"時計\\": { \\"amount\\":600000,\\"percentage\\":60 }\", \"\\"ワイン\\": { \\"amount\\":400000,\\"percentage\\":40 }\"]"                                                            |
|伊藤さくら        |2025-01-31 09:20:30|13       |85,000   |"[\"アウトドア\", \"カメラ\"]"         |"[\"\\"ガジェット\\": { \\"amount\\":32000,\\"percentage\\":38 }\", \"\\"食品\\": { \\"amount\\":53000,\\"percentage\\":62 }\"]"                                                            |




良い実装ですね。以下のポイントが特に評価できます：

1. Window関数を効果的に活用
   - `sum() over (partition by ...)` でカテゴリごとの集計を実現
   - パーセンテージの計算も同様の手法で効率的に実装

2. JSONデータの扱い
   - `json_extract`で趣味データを取得
   - `json_arrayagg`でカテゴリ分布をJSON形式に変換

3. CTEの段階的な活用
   - `cat_cust_stats`: 基本的な統計情報の計算
   - `cat_stats`: JSON文字列の組み立て
   - `cust_cat_distributions`: カテゴリ分布の集約
   - `cust_stats`: RFM関連の統計計算

結果からも、各顧客の特徴がよく分かります：
- 木村達也さん：時計が79%を占める典型的な時計収集家
- 中村優子さん：ワインと食品で購入が分かれており、趣味（ワイン、料理）と一致
- 高橋純平さん：高額購入（100万円）で時計とワインが中心

改善の余地があるとすれば：
1. Frequencyの計算で最初の購入から最後の購入までの日数を注文回数で割っていますが、平均購入間隔として適切か検討の余地がありますー＞１引くのを忘れていた。。。
2. JSON文字列にエスケープ文字（`\`）が多く含まれており、可読性が少し低下していますー＞これはよくわからない。どうすればいいの？

問題2にも取り組んでみますか？


はい、今日の学習量としては十分だと思います。以下の重要な技術要素を実践できました：

1. Window関数による複雑な集計
2. JSONデータの操作
3. CTEを使った段階的な処理
4. パーセンテージ計算

エスケープ文字が多く含まれる件については、これはJSON_ARRAYAGGを使用した際の仕様によるものです。具体的には：

```sql
json_arrayagg(
    concat('"',ccs.category_name,'": { "amount":',round(ccs.amount),',','"percentage":',ccs.percentage,' }')
)
```

この部分で、文字列を手動でJSON形式に組み立てているため、MySQLが自動的にエスケープ処理を行っています。

より綺麗な出力にするための改善案としては：
1. JSON_OBJECTを使用する
2. JSON_MERGEを活用する
3. JSON_OBJECTAGGを使用する（MySQL 8.0.25以降）

これらの方法は次回実装してみると良いかもしれません。今日は基本的なJSONデータの扱いとWindow関数の組み合わせを学べたので、良い練習になったと思います。











