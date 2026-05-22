--Report 3 Customer Purchase History
--This report analyzes purchase behavior for every customer.
select c.customer_id as 'Customer ID',
concat(c.first_name,' ',c.last_name) as Name,
date(min(invoicedate)) as 'First purchase date',
date(max(invoicedate))as 'Most recent purchase date',count(distinct i.invoiceno) as 'Number of invoices',
round(sum(ip.quantity *p.unit_price),2) as 'Total Sales',
round(sum(ip.quantity *p.unit_price)*1.0/count(distinct i.invoiceno),2) as 'Average Sales'
from customer c
join invoice i 
on i.customer_id=c.customer_id
join invoice_product ip 
on ip.invoiceno=i.invoiceno 
join product p
on p.stockcode =ip.stockcode
group by c.customer_id,c.first_name,c.last_name
order by sum(ip.quantity * p.unit_price) DESC;