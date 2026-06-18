-- Report 2 Sales by Country
-- This report reveals sales performance and customer distribution by country.
with t as (select sum(ip.quantity *p.unit_price) as sales, i.invoiceno,i.customer_id 
from invoice i 
join invoice_product ip 
on ip.invoiceno=i.invoiceno 
join product p
on p.stockcode =ip.stockcode
where ip.quantity>0
group by i.invoiceno,i.customer_id)
select co.country_name as Country,
count(distinct c.customer_id) as "Number of Customers",
count(distinct t.invoiceno) as "Number of Invoices",round(cast(sum(t.sales) as numeric),2) as "Total Sales",
round(cast(avg(t.sales) as numeric),2) as "Average Transaction Value"
from customer c
join country co
on co.country_id=c.country_id
join t
on t.customer_id=c.customer_id
group by co.country_name
order by sum(t.sales) DESC;