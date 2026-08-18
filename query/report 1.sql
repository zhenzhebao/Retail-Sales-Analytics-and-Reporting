/*Analyzes monthly business performance in 2011 from multiple perspectives, including total revenue, orders, 
and units sold, then compares monthly sales results to identify changes over time and each month’s contribution 
to annual revenue.*/

use role data_analyst;
use warehouse ANALYST_WH;

use schema Sales_DW.DW;

with t as (select date_trunc('month',calendar_date) as month, sum(item_transaction_price*item_quantity)as total_sales_revenue,
count(distinct invoice_no) as number_of_orders, sum(item_quantity) as total_units_sold, count(distinct customer_id) as number_of_unique_customers,
round(sum(item_transaction_price*item_quantity)*1.0/count(distinct invoice_no),2) as average_order_value
from fact_order_item foi
join Dates d
on foi.date_id=d.date_id
join customer c
on foi.dim_customer_id=c.dim_customer_id
where is_return=False and calendar_date>='2011-01-01' and calendar_date<'2012-01-01'
group by date_trunc('month',calendar_date)),
t2 as (select date_trunc('month',calendar_date) as month, abs(sum(item_transaction_price*item_quantity)) as total_value_of_returns
from fact_order_item foi 
join Dates d
on foi.date_id=d.date_id
where is_return=True and calendar_date>='2011-01-01' and calendar_date<'2012-01-01'
group by date_trunc('month',calendar_date))
select t.month, total_sales_revenue,number_of_orders,total_units_sold,
number_of_unique_customers,average_order_value,total_value_of_returns,
total_sales_revenue-lag(total_sales_revenue) over(order by t.month) as revenue_change_from_previous_month,
round((total_sales_revenue-lag(total_sales_revenue) over(order by t.month))*1.0/lag(total_sales_revenue) over(order by t.month)*100,2) as revenue_growth_from_previous_month_pct,
sum(total_sales_revenue) over(order by t.month) as total_sales_revenue_running_total,
round(total_sales_revenue*1.0/sum(total_sales_revenue) over()*100,2) share_of_annual_total
from t
join t2
on t.month=t2.month
order by t.month;