select co.country_name,round(cast(sum(p.unit_price*ip.quantity) as numeric),2) as total_revenue
from country co
join customer c
on co.country_id=c.country_id
join invoice i
on i.customer_id=c.customer_id
join invoice_product ip
on ip.invoiceno=i.invoiceno
join product p
on p.stockcode=ip.stockcode
where ip.quantity>0
group by co.country_name