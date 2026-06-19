-- product_invoice_summary
-- detailed invoice record
create view product_invoice_summary as 
select i.invoiceno,i.invoicedate,p.stockcode,p.description,
p.unit_price,ip.quantity,c.category_name,d.product_department
from product p
join invoice_product ip
on p.stockcode=ip.stockcode
join invoice i
on i.invoiceno=ip.invoiceno
join category c
on c.category_id=p.category_id
join department d
on d.department_id=c.department_id;