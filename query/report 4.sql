/*Presents a product category level summary and an overview of the entire dataset,
 highlighting sales quantity, revenue, number of orders, and number of customers across each category.*/
with t as (select ca.category_name,
sum(ip.quantity) as total_unit_sold,round(sum(ip.quantity *p.unit_price)::numeric,2) as total_revenue,
count(distinct i.invoiceno) as number_of_orders,count(distinct c.customer_id) number_of_customers
from category ca
join product p
on p.category_id=ca.category_id
join invoice_product ip
on ip.stockcode=p.stockcode
join invoice i 
on i.invoiceno=ip.invoiceno 
join customer c
on c.customer_id=i.customer_id
where ip.quantity>0
group by rollup(ca.category_name))
select coalesce(category_name,'Total') as groups,total_unit_sold,total_revenue,number_of_orders,
number_of_customers
from t;

with t as (select ca.category_name,round(sum(ip.quantity*p.unit_price)::numeric,2) as total_revenue,
sum(ip.quantity) as total_unit_sold,count(distinct i.invoiceno) as number_of_orders,
count(distinct c.customer_id) as number_of_customers
from category ca
join product p
on p.category_id=ca.category_id
join invoice_product ip
on p.stockcode=ip.stockcode
join invoice i
on i.invoiceno=ip.invoiceno 
join customer c
on c.customer_id=i.customer_id
where ip.quantity>0
group by grouping sets((ca.category_name),
						()))
select coalesce(category_name,'Total') as groups,total_revenue,total_unit_sold,number_of_orders,number_of_customers
from t;