-- present the monthly sales data such as total revenue, total number of orders and unit sold,
-- average transaction value 
create view monthly_sales_view as 
with tmp as (select i.invoicedate, i.invoiceno,sum(ip.quantity) as order_quantity,
sum(ip.quantity*p.unit_price) as order_value
from invoice i
join invoice_product ip
on ip.invoiceno=i.invoiceno
join product p
on p.stockcode=ip.stockcode
group by i.invoiceno,i.invoicedate)
select strftime('%Y-%m',invoicedate) as Year_month,count(distinct invoiceno) as number_of_invoices,
round(sum(order_quantity),2) as total_units_sold,
round(sum(order_value),2) as total_revenue, 
round((sum(order_value)*1.0/count(distinct invoiceno)),2)as average_invoice_value
from tmp
group by strftime('%Y-%m',invoicedate);