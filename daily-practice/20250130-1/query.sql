問題：
2024年の顧客分析として、以下の指標を計算してください：

1. 各顧客の最新購入日からの経過日数
2. 顧客ごとの購入回数と合計購入金額
3. 最も頻繁に購入しているカテゴリ（親カテゴリレベル）
4. 平均購入間隔（日数）

要件：
- cancelled状態の注文は除外
- inactive状態の顧客は除外
- 金額は小数点2位で四捨五入
- 期間は2024年1月1日から2024年12月31日まで
- 結果は最新購入日からの経過日数が短い順に表示

--解答

with cust_parent_stats as (
    select
        c.customer_id,
        pc.category_id,
        pc.name as category_name,
        sum(oi.quantity*oi.unit_price) as total_price
    from
        customers c
        inner join orders o
            on c.status != 'inactive'
            and year(o.order_date)=2024
            and o.status != 'cancelled'
            and o.customer_id = c.customer_id
        inner join order_items oi on oi.order_id = o.order_id
        inner join products p on p.product_id = oi.product_id
        inner join categories c on c.category_id = p.category_id
        inner join categories pc on pc.category_id = c.parent_category_id
    group by
        c.customer_id,
        pc.category_id,
),
cust_parent_ranks as (
    select
        customer_id,
        category_id,
        category_name,
        rank() over (partition by customer_id order by total_price desc, category_id asc) as category_rank
    from
        cust_parent_stats
)
select
    c.name,
    count(o.order_id) as total_order_count,
    sum(o.total_amount) as total_amount,
    cpr.category_name as favorite_category,
    timestampdiff(day,max(o.order_date),curdate()) as days_since_last_order,
    round(coalese(timestampdiff(day,min(o.order_date),max(o.order_date))/count(o.order_id),-1),1) as avg_order_interval
from
    customers c
    left join orders o 
        on o.customer_id = c.customer_id
        and year(o.order_date) = 2024
        and o.status != 'cancelled'
        and c.status != 'inactive'
    left join cust_parent_ranks cpr on cpr.customer_id = c.customer_id and cpr.category_rank = 1
group by
    c.name,
    c.customer_id,
    cpr.category_name
order by
    days_since_last_order asc;
    

--AIの返答

クエリの基本的な考え方は良いですが、いくつか修正が必要な箇所があります：

1. スペルミス
```sql
coalese
```
should be
```sql
coalesce
```

2. テーブルエイリアスの重複
```sql
inner join categories c on c.category_id = p.category_id
```
既に`customers`テーブルで`c`というエイリアスを使用しているため、衝突します。

3. カンマの余分/不足
```sql
    group by
        c.customer_id,
        pc.category_id,  -- 最後のカンマは不要
```

修正したバージョン：
```sql
with cust_parent_stats as (
    select
        c.customer_id,
        pc.category_id,
        pc.name as category_name,
        sum(oi.quantity*oi.unit_price) as total_price
    from
        customers c
        inner join orders o
            on c.status != 'inactive'
            and year(o.order_date)=2024
            and o.status != 'cancelled'
            and o.customer_id = c.customer_id
        inner join order_items oi on oi.order_id = o.order_id
        inner join products p on p.product_id = oi.product_id
        inner join categories cat on cat.category_id = p.category_id
        inner join categories pc on pc.category_id = cat.parent_category_id
    group by
        c.customer_id,
        pc.category_id
),
```

その他の部分は論理的に正しく、要件を満たしています。テストデータを作成して実行してみましょうか？




