-- product_category_performance_view
create view product_category_performance_view as (with product_level as (select ip.stockcode,d.product_department as department,ca.category_name,
count(i.invoiceno) as number_of_invoices,sum(ip.quantity) as total_units_sold,
round(cast(sum(ip.quantity*p.unit_price) as numeric),2) as total_revenue
from product p
join invoice_product ip
on p.stockcode=ip.stockcode
join invoice i
on ip.invoiceno=i.invoiceno
join category ca
on p.category_id=ca.category_id
join department d
on ca.department_id=d.department_id
where ip.quantity>0
group by ip.stockcode,d.product_department,ca.category_name),
category_level as (select department,category_name,count(stockcode) as number_of_products,
sum(number_of_invoices) as product_invoice_occurrences,
sum(total_units_sold) as total_units_sold,
round(cast(sum(total_revenue)as numeric),2) as total_revenue
from product_level
group by department,category_name)
select department,category_name,number_of_products,product_invoice_occurrences,total_units_sold,total_revenue,
round(cast(total_revenue*1.0/nullif(number_of_products,0) as numeric),2) as average_revenue_per_product
from category_level);