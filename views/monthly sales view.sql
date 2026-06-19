-- monthly_sales_view
create view monthly_sales_view as
with tmp as (select i.invoicedate, i.invoiceno,sum(ip.quantity) as order_quantity,
sum(ip.quantity * p.unit_price) as order_value
from invoice i
join invoice_product ip
on ip.invoiceno = i.invoiceno
join product p
on p.stockcode = ip.stockcode
where ip.quantity>0
group by i.invoiceno,i.invoicedate)
select to_char(invoicedate, 'YYYY-MM') as year_month,
count(distinct invoiceno) as number_of_invoices,
sum(order_quantity) as total_units_sold,
round(cast(sum(order_value) as numeric), 2) as total_revenue,
round(cast(sum(order_value) /nullif(count(distinct invoiceno),0) as numeric),2) as average_invoice_value
from tmp
group by to_char(invoicedate, 'YYYY-MM');