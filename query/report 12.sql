-- Product Revenue Share within Category
with t as (select ca.category_name,p.stockcode,p.description,sum(p.unit_price*ip.quantity)as product_revenue
from product p
join category ca
on p.category_id=ca.category_id
join invoice_product ip
on ip.stockcode=p.stockcode
join invoice i
on i.invoiceno=ip.invoiceno
group by ca.category_name,p.stockcode,p.description),
t2 as (select category_name,stockcode,description,product_revenue,
sum(product_revenue) over(partition by category_name)as category_revenue
from t)
select category_name,stockcode,description,product_revenue,category_revenue,
round((product_revenue*1.0/category_revenue*100),2) as revenue_share_pct
from t2;