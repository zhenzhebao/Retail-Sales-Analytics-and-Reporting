-- customer_tenure_view
create view customer_tenure_view as (with t as (select c.customer_id,concat(c.first_name,' ',c.last_name)as customer_name,
date(min(i.invoicedate)) as first_invoice_date, date(max(i.invoicedate))as latest_invoice_date
from customer c
join invoice i
on i.customer_id=c.customer_id
group by c.customer_id,concat(c.first_name,' ',c.last_name)),
t2 as (select customer_id,customer_name,first_invoice_date,latest_invoice_date,
latest_invoice_date-first_invoice_date as tenure_days
from t)
select customer_id,customer_name,first_invoice_date,latest_invoice_date,tenure_days,
case
	when tenure_days >365 then 'Long tenure'
	when tenure_days >90 then 'Medium tenure'
	when tenure_days >0 then 'Short tenure'
	else 'One-time customer'
end as customer_tenure_group
from t2);