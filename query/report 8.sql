-- Report 8 Customer Retention Analysis
-- This report reveals the overall customer segmentation.
with invoice_level as (select i.invoiceno,c.customer_id,concat(c.first_name,' ',c.last_name) as customer_name,
date(i.invoicedate) as invoicedate,
sum(ip.quantity*p.unit_price) as invoice_total
from customer c
join invoice i
on i.customer_id=c.customer_id
join invoice_product ip
on ip.invoiceno=i.invoiceno
join product p
on ip.stockcode=p.stockcode
where ip.quantity>0
group by i.invoiceno,c.customer_id,concat(c.first_name,' ',c.last_name),date(i.invoicedate)),
customer_level as (select customer_id,customer_name,count(distinct invoiceno) as invoice_count,
min(invoicedate) as first_purchase_date,max(invoicedate) as last_purchase_date,
round(cast(sum(invoice_total) as numeric),2) as total_revenue
from invoice_level
group by customer_id,customer_name),
t as (select customer_id,customer_name,invoice_count,first_purchase_date,
last_purchase_date,(last_purchase_date-first_purchase_date) as days_between,
total_revenue,round(cast(total_revenue*1.0/nullif(invoice_count,0) as numeric),2) as average_invoice_value
from customer_level),
customer_segmentation as (select customer_id,customer_name,invoice_count,first_purchase_date,
last_purchase_date,days_between,total_revenue,average_invoice_value,
case
	when days_between>300 then 'Loyal Customer'
	when days_between>100 then 'Returning Customer'
	else 'New Customer'
end as customer_segmentation
from t),
t2 as (select customer_segmentation,round(cast(sum(total_revenue) as numeric),2) as total_revenue,
count(customer_id) as number_of_customers
from customer_segmentation
group by customer_segmentation)
select customer_segmentation,total_revenue,number_of_customers,
round(cast(total_revenue/nullif(number_of_customers,0)as numeric),2) as average_revenue_per_customers,
round(cast(number_of_customers*1.0/nullif(sum(number_of_customers) over(),0)*100 as numeric),2) as percentage_of_customer
from t2;