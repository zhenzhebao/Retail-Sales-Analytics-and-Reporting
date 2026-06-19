-- sales_kpi_summary_view
-- Aggregated sales result
create view sales_kpi_summary_view as 
with t as (select i.invoiceno,c.customer_id,
round(cast(sum(ip.quantity*p.unit_price)as numeric),2) as invoice_total 
from customer c
join invoice i
on i.customer_id=c.customer_id
join invoice_product ip
on ip.invoiceno =i.invoiceno 
join product p
on p.stockcode=ip.stockcode
where ip.quantity > 0
group by i.invoiceno,c.customer_id),
t2 as (select count(distinct invoiceno) as total_invoices,count(distinct customer_id)as total_customers,
round(cast(sum(invoice_total)as numeric),2) as total_revenue
from t)
select total_invoices,total_customers,total_revenue,
round(cast(total_revenue/nullif(total_invoices,0) as numeric),2) as average_order_value
from t2;