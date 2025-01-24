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
    





























1



