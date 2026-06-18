--Report 3 Customer Purchase History
--This report analyzes purchase behavior for every customer.
select c.customer_id as "Customer ID",
concat(c.first_name,' ',c.last_name) as Name,
date(min(invoicedate)) as "First purchase date",
date(max(invoicedate))as "Most recent purchase date",count(distinct i.invoiceno) as "Number of invoices",
round(cast(sum(ip.quantity *p.unit_price) as numeric),2) as "Total Sales",
round(cast(sum(ip.quantity *p.unit_price)*1.0/nullif(count(distinct i.invoiceno),0) as numeric),2) as "Average Sales"
from customer c
join invoice i 
on i.customer_id=c.customer_id
join invoice_product ip 
on ip.invoiceno=i.invoiceno 
join product p
on p.stockcode =ip.stockcode
where ip.quantity>0
group by c.customer_id,c.first_name,c.last_name
order by sum(ip.quantity * p.unit_price) DESC;