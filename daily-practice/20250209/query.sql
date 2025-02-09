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





















