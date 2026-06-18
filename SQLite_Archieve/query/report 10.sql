-- Report 10 Customer Revenue Ranking
-- Explore revenue at the customer level and reveal details such as rank and difference.
with t as (select c.customer_id, concat (c.first_name, ' ',c.last_name) as name,count(distinct i.invoiceno) as number_of_invoices,
round(sum(ip.quantity*p.unit_price),2) as total_revenue,
round(sum(ip.quantity*p.unit_price)*1.0/count(distinct i.invoiceno),2) as average_invoice_value
from customer c
join invoice i
on c.customer_id=i.customer_id
join invoice_product ip
on ip.invoiceno=i.invoiceno
join product p
on p.stockcode =ip.stockcode
group by c.customer_id, c.first_name,c.last_name)
select customer_id,name,number_of_invoices,total_revenue,average_invoice_value,
rank() over (order by total_revenue DESC) as revenue_rank,
dense_rank() over (order by total_revenue DESC) as revenue_dense_rank,
PERCENT_RANK() over (order by total_revenue) as revenue_percentile,
sum(total_revenue) over(order by total_revenue DESC) as running_total_revenue,
round(max(total_revenue) over()-total_revenue,2) as Difference,
round(total_revenue*1.0/sum(total_revenue) over(),2) as 'Percentage contribution to total company revenue'
from t
order by total_revenue DESC;