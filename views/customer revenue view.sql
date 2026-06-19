-- customer_revenue_view 
-- Detailed Sales record for each customer 
create view customer_revenue_view as 
with tmp as 
(select c.customer_id,concat (c.first_name, ' ',c.last_name) as customer_name,
c.membership_flag,i.invoiceno,sum(ip.quantity*p.unit_price) as order_value
from customer c
join invoice i
on c.customer_id=i.customer_id
join invoice_product ip
on ip.invoiceno=i.invoiceno
join product p
on p.stockcode=ip.stockcode
where ip.quantity>0
group by i.invoiceno,c.customer_id,concat (c.first_name, ' ',c.last_name),c.membership_flag)
select customer_id,customer_name,
case
	when membership_flag='1' then 'Yes'
	else 'No'
end as membership,
count(distinct invoiceno) as number_of_invoices,
round(cast(sum(order_value) as numeric),2) as total_revenue,
round(cast(sum(order_value)*1.0/nullif(count(distinct invoiceno),0) as numeric),2) as average_invoice_value
from tmp
group by customer_id,customer_name,membership_flag;