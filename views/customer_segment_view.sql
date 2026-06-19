-- customer_segment_view
create view customer_segment_view as (with t as (select c.customer_id,concat(c.first_name,' ',c.last_name) as customer_name,co.country_name as country,
replace(replace(cast(c.membership_flag as text),'1','Yes'),'0','No') as membership,
count(distinct i.invoiceno)as invoice_count,
round(cast(sum(p.unit_price*ip.quantity) as numeric),2) as total_revenue,
date(min(i.invoicedate)) as first_purchase_date,date(max(i.invoicedate)) as last_purchase_date
from customer c
join country co
on c.country_id=co.country_id
join invoice i
on i.customer_id=c.customer_id
join invoice_product ip
on ip.invoiceno=i.invoiceno 
join product p
on p.stockcode=ip.stockcode
where ip.quantity>0
group by c.customer_id,concat(c.first_name,' ',c.last_name),co.country_name,
replace(replace(cast(c.membership_flag as text),'1','Yes'),'0','No'))
select customer_id,customer_name,country,membership,invoice_count,total_revenue,
first_purchase_date,last_purchase_date,
round(cast(total_revenue*1.0/nullif(invoice_count,0) as numeric),2) as average_order_value,
case
	when total_revenue >= 1000 then 'High Value'
	when total_revenue >= 300 then 'Medium Value'
	else 'Low Value'
end as customer_segment
from t);