/* For each customer, analyzes purchasing behavior by identifying purchasing patterns such as purchase frequency, 
number of orders placed, and total spending, then categorizes customers into three groups based on total spending.*/

/*Left join with membership Table is used becuase some customers are not memebers*/
with t as (select c.customer_id, concat(c.first_name,' ',c.last_name) as customer_name,
co.country_name as country,mt.membership_type,min(date(i.invoicedate)) as first_purchase_date,
max(date(i.invoicedate)) as most_recent_purchase_date, count(distinct i.invoiceno) as number_of_orders,
sum(ip.quantity) as total_units_purchased,round(sum(ip.quantity*p.unit_price)::numeric,2) as total_spending,
round(cast(sum(ip.quantity*p.unit_price)*1.0/nullif(count(distinct i.invoiceno),0) as numeric),2) as average_order_value,
round(cast(max(date(i.invoicedate))-min(date(i.invoicedate)) as numeric)*1.0/
nullif(count(distinct i.invoiceno)-1,0),2) as average_days_between_purchases
from customer c
join country co
on c.country_id=co.country_id
left join membership m 
on c.customer_id=m.customer_id
left join membership_type mt
on mt.membership_type_id=m.membership_type_id
join invoice i
on i.customer_id=c.customer_id
join invoice_product ip
on ip.invoiceno=i.invoiceno 
join product p
on p.stockcode=ip.stockcode
where ip.quantity>0
group by c.customer_id, concat(c.first_name,' ',c.last_name),co.country_name,mt.membership_type),
t2 as (select customer_id,customer_name,country,membership_type,first_purchase_date,
most_recent_purchase_date,number_of_orders,total_units_purchased,total_spending,
round((total_spending*1.0/sum(total_spending) over())*100 ::numeric,2) as share_of_total_revenue,
average_order_value,average_days_between_purchases,
dense_rank() over(order by total_spending desc) as customer_spending_ranking,
dense_rank() over(partition by country order by total_spending desc) as customer_spending_ranking_by_country,
percent_rank() over(order by total_spending desc) as total_spending_pct_ranking
from t)
select customer_id,customer_name,country,membership_type,first_purchase_date,
most_recent_purchase_date,number_of_orders,total_units_purchased,total_spending,share_of_total_revenue,
average_order_value,average_days_between_purchases,customer_spending_ranking,
customer_spending_ranking_by_country,
case
	when total_spending_pct_ranking<=0.3 then 'High Spending'
	when total_spending_pct_ranking<=0.8 then 'Medium Spending'
	else 'Low Spending'
end as customer_spending_segment
from t2;