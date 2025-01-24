--追加の分析問題
--
--4. 日付別の売上トレンド分析
--   - 日付ごとの売上金額
--   - 前日比の増減率
--   - 7日間の移動平均売上
--   - 売上が前日より20%以上増加した日の抽出
--
--5. 顧客の購買パターン分析
--   - 顧客ごとの総購入金額と購入回数
--   - 最も最近の購入からの経過日数
--   - 顧客の平均購入間隔（日数）
--   - 最も頻繁に購入する出版社
--
--6. 在庫分析
--   - 書籍ごとの在庫金額（価格 × 在庫数）
--   - 出版社ごとの総在庫金額
--   - 売上対在庫比率の計算
--   - 在庫金額が上位10%の書籍の抽出
--
--7. クロス集計による分析
--   - 出版社×会員ランクごとの売上集計
--   - 会員ランクごとの出版社別購入比率
--   - 出版社ごとの会員ランク別売上構成比
--*/

--問題４
with daily_stats as (
    select
        date_format(o.order_date,'%Y-%m-%d') as day,
        sum(o.total_amount) as day_total
    from 
        orders o
    group by
        day
),
daily_analysis as (
    select
        ds.day,
        ds.day_total,
        ds.day_total/(lag(ds.day_total,1) over (order by ds.day asc)) as day_change_ratio,
        avg(ds.day_total) over (order by ds.day asc rows between 6 preceding and current row) as week_running_avg
    from
        daily_stats ds
)
select
    da.day,
    da.day_total,
    concat(round(100.0*(day_change_ratio-1),1),'%') as day_change_ratio,
    round(da.week_running_avg,1) as week_running_avg,
    case
        when da.day_change_ratio >= 1.2 then true
        else false
    end as if_grew_20_percent
from
    daily_analysis da;

--5. 顧客の購買パターン分析
--   - 顧客ごとの総購入金額と購入回数
--   - 最も最近の購入からの経過日数
--   - 顧客の平均購入間隔（日数）
--   - 最も頻繁に購入する出版社
with cust_simple_stats as (
    select
        c.customer_id,
        c.customer_name,
        sum(o.total_amount) as cust_total_amount,
        count(o.order_id) as cust_total_order_count,
        timestampdiff(day,max(o.order_date),curdate()) as day_from_latest_purchase,
        timestampdiff(day,min(o.order_date),max(o.order_date)) as day_range
    from
        customers c
        inner join orders o
            on o.customer_id = c.customer_id
    group by
        c.customer_id,
        c.customer_name
),
cust_publisher_stats as (
    select
        c.customer_id,
        p.publisher_id,
        p.publisher_name,
        count(od.order_id) as cust_pub_count
    from
        customers c
        inner join orders o
            on o.customer_id = c.customer_id
        inner join order_details od
            on od.order_id = o.order_id
        inner join books b 
            on b.book_id = od.book_id
        inner join publishers p
            on p.publisher_id = b.publisher_id
    group by
        c.customer_id,
        p.publisher_id,
        p.publisher_name
),
cust_publisher_ranks as (
    select
        cps.*,
        rank() over (partition by cps.customer_id order by cps.cust_pub_count desc,cps.publisher_id desc) as ranking
    from
        cust_publisher_stats cps
)
select
    css.customer_name,
    css.cust_total_amount,
    css.cust_total_order_count,
    css.day_from_latest_purchase,
    round(css.day_range/(css.cust_total_order_count-1),1) as avg_interval,
    cpr.publisher_name as most_frequent
from
    cust_simple_stats css
    inner join cust_publisher_ranks cpr 
        on cpr.customer_id = css.customer_id and cpr.ranking = 1;
    
--実行結果
--"customer_name","cust_total_amount","cust_total_order_count","day_from_latest_purchase","avg_interval","most_frequent"
--山田太郎,15800.00,3,349,4.0,TechBooks Inc.
--鈴木花子,7000.00,2,348,7.0,Literature Press
--田中一郎,3200.00,1,355,,Science Publishing
--佐藤次郎,9900.00,2,350,2.0,TechBooks Inc.
--高橋愛子,2800.00,1,352,,Science Publishing
--渡辺健一,4400.00,1,351,,Literature Press
--

--6. 在庫分析
--   - 書籍ごとの在庫金額（価格 × 在庫数）
--   - 出版社ごとの総在庫金額
--   - 売上対在庫比率の計算
--   - 在庫金額が上位10%の書籍の抽出


with book_stats as (
    select
        p.publisher_id,
        p.publisher_name,
        b.book_id,
        b.title,
        sum(b.stock_quantity*b.price) as total_stock_price
    from
        publishers p
        inner join books b
            on b.publisher_id = p.publisher_id
    group by
        p.publisher_id,
        p.publisher_name,
        b.book_id,
        b.title
)
select
    publisher_name,
    sum(total_stock_price) over (partition by publisher_id) as publisher_total_stock_price,
    title,
    total_stock_price as book_total_stock_price
from
    book_stats;
-- 実行結果
--
--|publisher_name|publisher_total_stock_price|title|book_total_stock_price|
--|--------------|---------------------------|-----|----------------------|
--|TechBooks Inc.|1305000.00|SQL基礎|280000.00|
--|TechBooks Inc.|1305000.00|プログラミング入門|300000.00|
--|TechBooks Inc.|1305000.00|データベース設計|245000.00|
--|TechBooks Inc.|1305000.00|Webプログラミング|480000.00|
--|Literature Press|803000.00|小説: 春の風|225000.00|
--|Literature Press|803000.00|歴史物語|162000.00|
--|Literature Press|803000.00|夏の詩集|240000.00|
--|Literature Press|803000.00|古典文学選|176000.00|
--|Science Publishing|536000.00|物理の謎|256000.00|
--|Science Publishing|536000.00|化学実験の基礎|280000.00|


--
--クエリ2（要件3と4）
--
--売上対在庫比率と在庫金額上位10%の抽出を組み合わせて表示
--出力イメージ:
--
--書籍名 | 在庫金額 | 直近1ヶ月売上額 | 売上対在庫比率 | 在庫金額順位（パーセンタイル）
--データベース設計 | 245,000 | 35,000 | 14.3% | 上位10%
--

with book_stats as (
    select
        b.book_id,
        b.title,
        sum(oi.quantity*oi.unit_price) as total_sales,
        b.price*b.stock_quantity as stock_price
    from
        books b
        inner join order_details oi
            on oi.book_id = b.book_id
    group by
        b.book_id,
        b.title,
        b.price,
        b.stock_quantity
)
select
    title,
    stock_price,
    total_sales,
    concat(round(100.0*total_sales/stock_price,1),'%') as turnover_ratio,
    concat('上位',round(100.0*(percent_rank() over (order by stock_price desc)),1),'%') as percentile_rank
from
    book_stats;
--実行結果
--|title|stock_price|total_sales|turnover_ratio|percentile_rank|
--|-----|-----------|-----------|--------------|---------------|
--|Webプログラミング|480000.00|6400.00|1.3%|上位0%|
--|プログラミング入門|300000.00|2500.00|0.8%|上位11.1%|
--|SQL基礎|280000.00|5600.00|2.0%|上位22.2%|
--|化学実験の基礎|280000.00|5000.00|1.8%|上位22.2%|
--|物理の謎|256000.00|3200.00|1.3%|上位44.4%|
--|データベース設計|245000.00|7000.00|2.9%|上位55.6%|
--|夏の詩集|240000.00|7200.00|3.0%|上位66.7%|
--|小説: 春の風|225000.00|3000.00|1.3%|上位77.8%|
--|古典文学選|176000.00|1200.00|0.7%|上位88.9%|
--|歴史物語|162000.00|2000.00|1.2%|上位100%|















1



