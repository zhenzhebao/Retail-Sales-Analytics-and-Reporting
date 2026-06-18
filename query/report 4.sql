-- Report 4 Product Performance Report
--This report evaluates sales performance for each product.
select p.stockcode as "Product Code",p.description as "Product description",
c.category_name as "Category",d.product_department as "Department",sum(ip.quantity) as "Units sold",
round(cast(sum(ip.quantity *p.unit_price) as numeric),2) as "Total Sales", 
count(distinct i.invoiceno) as "Number of invoices containing the product"
from product p
join category c
on c.category_id=p.category_id
join department d
on d.department_id=c.department_id
join invoice_product ip 
on ip.stockcode=p.stockcode
join invoice i
on i.invoiceno=ip.invoiceno
where ip.quantity>0
group by p.stockcode,p.description,c.category_name,d.product_department
order by sum(ip.quantity) DESC;