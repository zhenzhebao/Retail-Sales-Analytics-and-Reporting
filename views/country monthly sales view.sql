-- country_monthly_sales_view
create view country_monthly_sales_view as (with invoice_level as (select i.invoiceno,c.customer_id,
co.country_name,date(date_trunc('month',invoicedate)) as sales_month,
round(cast(sum(p.unit_price*ip.quantity) as numeric),2) as invoice_total
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
group by i.invoiceno,c.customer_id,
co.country_name,date(date_trunc('month',invoicedate))),
t as (select country_name,sales_month,count(distinct invoiceno) as total_invoices,count(distinct customer_id) as total_customers,
round(cast(sum(invoice_total) as numeric),2) as total_revenue
from invoice_level
group by country_name,sales_month)
select country_name,sales_month,total_invoices,total_customers,total_revenue,
round(cast(total_revenue*1.0/nullif(total_invoices,0) as numeric),2) as average_order_value
from t);