1. 製品ごとに、以下の情報を集計してください：
   - 平均評価（rating）
   - 投稿されたレビューの総数
   - 写真付きレビューの数
   - verified_purchaseが true のレビュー数
   - モバイルからの投稿数
   結果は平均評価が高い順に表示してください。

select
    p.name as product_name,
    avg(r.rating) as avg_rating,
    count(case when json_length(r.meta_data->>'$.photos') != 0 then 1 end) as review_with_photos,
    count(case when r.meta_data->'$.verified_purchase'=true then 1 end) as verified_purchase,
    count(case when r.meta_data->'$.device.type'='mobile' then 1 end) as mobile_reviews
from
    products p 
    inner join reviews r 
        on r.product_id = p.product_id
group by
    p.product_id,
    p.name
order by
    avg_rating desc;

--実行結果
|product_name   |avg_rating|review_with_photos|verified_purchase|mobile_reviews|
|---------------|----------|------------------|-----------------|--------------|
|バックパック         |5         |1                 |1                |1             |
|ワイヤレスイヤホン      |4.5       |2                 |4                |3             |
|ノイズキャンセリングヘッドホン|4.5       |1                 |2                |1             |
|スマートウォッチ       |4         |3                 |2                |3             |
|防水スピーカー        |4         |0                 |1                |1             |
|ランニングシューズ      |4         |1                 |1                |1             |


json_length()という関数を初めて知った。




2. タグ（tags配列）の使用頻度を分析し、最も多く使用されているタグトップ5を抽出してください。
   - タグごとの使用回数
   - そのタグが使用されているレビューの平均評価
   を表示してください。

--とりあえず単純な集計

SELECT 
	tags_extracted.tag as tag,
	count(*) as total_usage
from
	reviews ,
	json_table(reviews.meta_data,'$.tags[*]' columns(
		tag varchar(255) path '$'
	)) as tags_extracted
group by tag;

|tag             |total_usage|
|----------------|-----------|
|sound_quality   |3          |
|comfortable     |6          |
|good_battery    |2          |
|good_value      |2          |
|good_quality    |5          |
|battery_issue   |1          |
|expensive       |1          |
|feature_rich    |1          |
|waterproof      |1          |
|good_sound      |1          |
|portable        |1          |
|spacious        |1          |
|size_fits       |1          |
|noise_cancelling|1          |
|bit_heavy       |1          |
|good_design     |1          |






SELECT 
	avg(reviews.rating) as avg_rating,
	tags_extracted.tag as tag,
	count(*) as total_usage
from
	reviews ,
	json_table(reviews.meta_data,'$.tags[*]' columns(
		tag varchar(255) path '$'
	)) as tags_extracted
group by tag;


|avg_rating|tag             |total_usage|
|----------|----------------|-----------|
|4.6667    |sound_quality   |3          |
|4.6667    |comfortable     |6          |
|4.5       |good_battery    |2          |
|4         |good_value      |2          |
|4.6       |good_quality    |5          |
|3         |battery_issue   |1          |
|3         |expensive       |1          |
|5         |feature_rich    |1          |
|4         |waterproof      |1          |
|4         |good_sound      |1          |
|4         |portable        |1          |
|5         |spacious        |1          |
|4         |size_fits       |1          |
|5         |noise_cancelling|1          |
|4         |bit_heavy       |1          |
|4         |good_design     |1          |



--AI採点

いい感じですね。問題2の要件を完全に満たすために、以下の修正を加えましょう：

```sql
SELECT 
    tag,
    count(*) as usage_count,
    round(avg(rating), 2) as avg_rating
from
    reviews,
    json_table(
        meta_data,
        '$.tags[*]' 
        columns(tag varchar(255) path '$')
    ) as tags_extracted
group by 
    tag
order by 
    usage_count desc,
    avg_rating desc
limit 5;
```

主な変更点：
1. order by で使用回数の降順、同数の場合は平均評価の降順にソート
2. limit 5 でトップ5のみを表示
3. round() で平均評価を小数点2桁に丸め
4. カラムの順序を問題の要件に合わせて変更

これにより、問題の要件である「タグの使用頻度トップ5」が、使用回数と平均評価の両方を考慮して表示されます。

期待される結果：
```
| tag         | usage_count | avg_rating |
|-------------|-------------|------------|
| comfortable | 6          | 4.67      |
| good_quality| 5          | 4.60      |
| sound_quality| 3          | 4.67      |
| good_battery | 2          | 4.50      |
| good_value  | 2          | 4.00      |
```

元のクエリでJSON_TABLEを使用して配列を展開する方法は素晴らしいアプローチでした。これはMySQLで配列を扱う際の効率的な方法です。


ちなみに
SELECT 
	*
from
	reviews,
	json_table(reviews.meta_data,'$.tags[*]' columns(
		tag varchar(255) path '$'
	)) as tags_extracted;

これをやると、


|review_id|product_id|user_id|rating|review_date        |content         |meta_data                                                                                                                                                                                                                                        |tag             |
|---------|----------|-------|------|-------------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|
|1        |1         |101    |5     |2024-01-01 10:00:00|音質が素晴らしい        |"{\"tags\": [\"sound_quality\", \"comfortable\", \"good_battery\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"15.0\"}, \"photos\": [\"photo1.jpg\", \"photo2.jpg\"], \"helpful_votes\": 5, \"verified_purchase\": true}"|sound_quality   |
|1        |1         |101    |5     |2024-01-01 10:00:00|音質が素晴らしい        |"{\"tags\": [\"sound_quality\", \"comfortable\", \"good_battery\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"15.0\"}, \"photos\": [\"photo1.jpg\", \"photo2.jpg\"], \"helpful_votes\": 5, \"verified_purchase\": true}"|comfortable     |
|1        |1         |101    |5     |2024-01-01 10:00:00|音質が素晴らしい        |"{\"tags\": [\"sound_quality\", \"comfortable\", \"good_battery\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"15.0\"}, \"photos\": [\"photo1.jpg\", \"photo2.jpg\"], \"helpful_votes\": 5, \"verified_purchase\": true}"|good_battery    |
|2        |1         |102    |4     |2024-01-02 11:00:00|バッテリーの持ちが良い     |"{\"tags\": [\"good_battery\", \"good_value\"], \"device\": {\"os\": \"Windows\", \"type\": \"desktop\", \"version\": \"11\"}, \"photos\": [], \"helpful_votes\": 3, \"verified_purchase\": true}"                                               |good_battery    |
|2        |1         |102    |4     |2024-01-02 11:00:00|バッテリーの持ちが良い     |"{\"tags\": [\"good_battery\", \"good_value\"], \"device\": {\"os\": \"Windows\", \"type\": \"desktop\", \"version\": \"11\"}, \"photos\": [], \"helpful_votes\": 3, \"verified_purchase\": true}"                                               |good_value      |
|3        |1         |103    |5     |2024-01-03 12:00:00|装着感が快適          |"{\"tags\": [\"comfortable\", \"good_quality\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"13\"}, \"photos\": [\"photo3.jpg\"], \"helpful_votes\": 7, \"verified_purchase\": true}"                                 |comfortable     |
|3        |1         |103    |5     |2024-01-03 12:00:00|装着感が快適          |"{\"tags\": [\"comfortable\", \"good_quality\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"13\"}, \"photos\": [\"photo3.jpg\"], \"helpful_votes\": 7, \"verified_purchase\": true}"                                 |good_quality    |
|4        |2         |104    |3     |2024-01-04 13:00:00|バッテリーがイマイチ      |"{\"tags\": [\"battery_issue\", \"expensive\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"16.0\"}, \"photos\": [\"photo4.jpg\"], \"helpful_votes\": 10, \"verified_purchase\": true}"                                   |battery_issue   |
|4        |2         |104    |3     |2024-01-04 13:00:00|バッテリーがイマイチ      |"{\"tags\": [\"battery_issue\", \"expensive\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"16.0\"}, \"photos\": [\"photo4.jpg\"], \"helpful_votes\": 10, \"verified_purchase\": true}"                                   |expensive       |
|5        |2         |105    |5     |2024-01-05 14:00:00|機能が充実している       |"{\"tags\": [\"feature_rich\", \"good_quality\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"12\"}, \"photos\": [\"photo5.jpg\", \"photo6.jpg\"], \"helpful_votes\": 15, \"verified_purchase\": false}"              |feature_rich    |
|5        |2         |105    |5     |2024-01-05 14:00:00|機能が充実している       |"{\"tags\": [\"feature_rich\", \"good_quality\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"12\"}, \"photos\": [\"photo5.jpg\", \"photo6.jpg\"], \"helpful_votes\": 15, \"verified_purchase\": false}"              |good_quality    |
|6        |3         |106    |4     |2024-01-06 15:00:00|防水性能が高い         |"{\"tags\": [\"waterproof\", \"good_sound\", \"portable\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"15.0\"}, \"photos\": [], \"helpful_votes\": 8, \"verified_purchase\": true}"                                      |waterproof      |
|6        |3         |106    |4     |2024-01-06 15:00:00|防水性能が高い         |"{\"tags\": [\"waterproof\", \"good_sound\", \"portable\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"15.0\"}, \"photos\": [], \"helpful_votes\": 8, \"verified_purchase\": true}"                                      |good_sound      |
|6        |3         |106    |4     |2024-01-06 15:00:00|防水性能が高い         |"{\"tags\": [\"waterproof\", \"good_sound\", \"portable\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"15.0\"}, \"photos\": [], \"helpful_votes\": 8, \"verified_purchase\": true}"                                      |portable        |
|7        |4         |107    |5     |2024-01-07 16:00:00|収納力抜群           |"{\"tags\": [\"spacious\", \"good_quality\", \"comfortable\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"13\"}, \"photos\": [\"photo7.jpg\"], \"helpful_votes\": 20, \"verified_purchase\": true}"                  |spacious        |
|7        |4         |107    |5     |2024-01-07 16:00:00|収納力抜群           |"{\"tags\": [\"spacious\", \"good_quality\", \"comfortable\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"13\"}, \"photos\": [\"photo7.jpg\"], \"helpful_votes\": 20, \"verified_purchase\": true}"                  |good_quality    |
|7        |4         |107    |5     |2024-01-07 16:00:00|収納力抜群           |"{\"tags\": [\"spacious\", \"good_quality\", \"comfortable\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"13\"}, \"photos\": [\"photo7.jpg\"], \"helpful_votes\": 20, \"verified_purchase\": true}"                  |comfortable     |
|8        |5         |108    |4     |2024-01-08 17:00:00|クッション性が良い       |"{\"tags\": [\"comfortable\", \"good_quality\", \"size_fits\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"16.0\"}, \"photos\": [\"photo8.jpg\", \"photo9.jpg\"], \"helpful_votes\": 12, \"verified_purchase\": true}"   |comfortable     |
|8        |5         |108    |4     |2024-01-08 17:00:00|クッション性が良い       |"{\"tags\": [\"comfortable\", \"good_quality\", \"size_fits\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"16.0\"}, \"photos\": [\"photo8.jpg\", \"photo9.jpg\"], \"helpful_votes\": 12, \"verified_purchase\": true}"   |good_quality    |
|8        |5         |108    |4     |2024-01-08 17:00:00|クッション性が良い       |"{\"tags\": [\"comfortable\", \"good_quality\", \"size_fits\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"16.0\"}, \"photos\": [\"photo8.jpg\", \"photo9.jpg\"], \"helpful_votes\": 12, \"verified_purchase\": true}"   |size_fits       |
|9        |8         |109    |5     |2024-01-09 18:00:00|ノイズキャンセリングが素晴らしい|"{\"tags\": [\"noise_cancelling\", \"sound_quality\", \"comfortable\"], \"device\": {\"os\": \"Windows\", \"type\": \"desktop\", \"version\": \"10\"}, \"photos\": [\"photo10.jpg\"], \"helpful_votes\": 25, \"verified_purchase\": true}"       |noise_cancelling|
|9        |8         |109    |5     |2024-01-09 18:00:00|ノイズキャンセリングが素晴らしい|"{\"tags\": [\"noise_cancelling\", \"sound_quality\", \"comfortable\"], \"device\": {\"os\": \"Windows\", \"type\": \"desktop\", \"version\": \"10\"}, \"photos\": [\"photo10.jpg\"], \"helpful_votes\": 25, \"verified_purchase\": true}"       |sound_quality   |
|9        |8         |109    |5     |2024-01-09 18:00:00|ノイズキャンセリングが素晴らしい|"{\"tags\": [\"noise_cancelling\", \"sound_quality\", \"comfortable\"], \"device\": {\"os\": \"Windows\", \"type\": \"desktop\", \"version\": \"10\"}, \"photos\": [\"photo10.jpg\"], \"helpful_votes\": 25, \"verified_purchase\": true}"       |comfortable     |
|10       |8         |110    |4     |2024-01-10 19:00:00|音質は良いが少し重い      |"{\"tags\": [\"sound_quality\", \"bit_heavy\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"12\"}, \"photos\": [], \"helpful_votes\": 18, \"verified_purchase\": true}"                                               |sound_quality   |
|10       |8         |110    |4     |2024-01-10 19:00:00|音質は良いが少し重い      |"{\"tags\": [\"sound_quality\", \"bit_heavy\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"12\"}, \"photos\": [], \"helpful_votes\": 18, \"verified_purchase\": true}"                                               |bit_heavy       |
|11       |1         |111    |4     |2024-01-11 20:00:00|良い買い物でした        |"{\"tags\": [\"good_value\", \"good_quality\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"15.0\"}, \"photos\": [], \"helpful_votes\": 3, \"verified_purchase\": true}"                                                  |good_value      |
|11       |1         |111    |4     |2024-01-11 20:00:00|良い買い物でした        |"{\"tags\": [\"good_value\", \"good_quality\"], \"device\": {\"os\": \"iOS\", \"type\": \"mobile\", \"version\": \"15.0\"}, \"photos\": [], \"helpful_votes\": 3, \"verified_purchase\": true}"                                                  |good_quality    |
|12       |2         |112    |4     |2024-01-12 21:00:00|デザインが気に入りました    |"{\"tags\": [\"good_design\", \"comfortable\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"13\"}, \"photos\": [\"photo11.jpg\"], \"helpful_votes\": 7, \"verified_purchase\": true}"                                 |good_design     |
|12       |2         |112    |4     |2024-01-12 21:00:00|デザインが気に入りました    |"{\"tags\": [\"good_design\", \"comfortable\"], \"device\": {\"os\": \"Android\", \"type\": \"mobile\", \"version\": \"13\"}, \"photos\": [\"photo11.jpg\"], \"helpful_votes\": 7, \"verified_purchase\": true}"                                 |comfortable     |

このようなデータが得られる。















