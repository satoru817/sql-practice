では、同じテーブル定義を使って、以下の分析問題を出題させていただきます：

## 問題
2024年1月における顧客の購買行動を分析してください。以下の情報を集計してください：

1. 購入回数による顧客分類（以下の区分で）
   - ヘビーユーザー：4回以上
   - ミドルユーザー：2-3回
   - ライトユーザー：1回

それぞれの区分について：
- 顧客数
- 区分ごとの総売上金額
- 1顧客あたりの平均売上金額
- 1注文あたりの平均売上金額

条件：
- 2024年1月のデータのみを対象とする
- 金額は小数点2位で四捨五入
- キャンセルされた注文（status = 'cancelled'）は除外
- 結果は顧客区分ごとに表示
- 未購入顧客（0回）は含めない

期待される出力イメージ：
```
user_segment     | customer_count | total_sales  | avg_sales_per_customer | avg_sales_per_order
Heavy Users      | 50            | 1500000.00   | 30000.00              | 7500.00
Middle Users     | 150           | 2250000.00   | 15000.00              | 6000.00
Light Users      | 300           | 1500000.00   | 5000.00               | 5000.00
```

このクエリを書いてみましょう。

--私の解答

with cust_stats as (
    select
        c.customer_id,
        sum(oi.quantity*oi.unit_price) as total_sales,
        count(distinct o.order_id) as order_count
    from
        customers c
        inner join orders o on o.customer_id = c.customer_id
        inner join order_items oi on oi.order_id = o.order_id
    where
        date_format(o.order_date,'%Y-%m')= '2024-01'
        and o.status != 'cancelled'
),
with cust_segments as (
    select
        customer_id,
        total_sales,
        order_count,
        case
            when order_count >= 4 then 'Heavy Users' 
            when order_count >= 2 then 'Middle Users'
            else 'Light Users' 
        END as user_segment
    from
        cust_stats
)
select
    user_segment,
    count(customer_id) as customer_count,
    round(sum(total_sales),2) as total_sales,
    round(sum(total_sales)/count(customer_id),2) as avg_sales_per_customer,
    round(sum(total_sales)/sum(order_count),2) as avg_sales_per_order
from 
    cust_segments
group by
    user_segment;


--AIの採点

クエリの考え方は良いですが、いくつか修正が必要な点があります：

1. 構文エラー:
- 2つ目のCTEで `with` キーワードが余分です
- `END` が大文字になっています（動作には影響ありませんが、一貫性のため小文字推奨）

2. JOINの考慮:
- order_itemsのorder_idとproduct_idにNOT NULL制約がないため、INNER JOINではなくLEFT JOINを使用すべき

修正したクエリは以下のようになります：

```sql
with cust_stats as (
    select
        c.customer_id,
        sum(oi.quantity * oi.unit_price) as total_sales,
        count(distinct o.order_id) as order_count
    from
        customers c
        inner join orders o on o.customer_id = c.customer_id
        left join order_items oi on oi.order_id = o.order_id
    where
        date_format(o.order_date, '%Y-%m') = '2024-01'
        and o.status != 'cancelled'
    group by
        c.customer_id
),
cust_segments as (
    select
        customer_id,
        total_sales,
        order_count,
        case
            when order_count >= 4 then 'Heavy Users' 
            when order_count >= 2 then 'Middle Users'
            else 'Light Users' 
        end as user_segment
    from
        cust_stats
)
select
    user_segment,
    count(customer_id) as customer_count,
    round(sum(total_sales), 2) as total_sales,
    round(sum(total_sales)/count(customer_id), 2) as avg_sales_per_customer,
    round(sum(total_sales)/sum(order_count), 2) as avg_sales_per_order
from 
    cust_segments
group by
    user_segment
order by
    case user_segment
        when 'Heavy Users' then 1
        when 'Middle Users' then 2
        when 'Light Users' then 3
    end;
```

主な改善点：
1. 構文エラーの修正ー＞withを入れたのは完全にミス
2. GROUP BY句を最初のCTEに追加ー＞これはわすれていた
3. order_itemsとのJOINをLEFT JOINに変更
4. セグメント順での並び替えを追加

これでより堅牢で見やすい結果が得られます。














