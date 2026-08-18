/*Analyze how each product performs within its category by calculating sales quantity, sales revenue, 
and number of customers, then classifying product performance by comparing its total revenue with 
the average product revenue in its category.*/
with t as (select p.stockcode,p.description,ca.category_id,ca.category_name,d.product_department,
sum(ip.quantity) as total_units_sold, round(sum(ip.quantity*p.unit_price)::numeric,2) as total_revenue,
count(i.invoiceno) as number_of_orders, count(distinct c.customer_id) as number_of_customers
from product p
join category ca
on p.category_id=ca.category_id
join department d
on ca.department_id=d.department_id 
join invoice_product ip
on ip.stockcode=p.stockcode
join invoice i
on i.invoiceno=ip.invoiceno
join customer c
on c.customer_id=i.customer_id
where ip.quantity>0
group by p.stockcode,p.description,ca.category_id,ca.category_name,d.product_department)
select stockcode,description,category_name,product_department,
total_units_sold,total_revenue,number_of_orders,number_of_customers,
round(sum(total_revenue) over(partition by category_id)::numeric,2) as category_total_revenue,
round(avg(total_revenue) over(partition by category_id)::numeric,2) as category_avg_revenue,
round(total_revenue-avg(total_revenue) over(partition by category_id)::numeric,2) as difference_with_category_avg_revenue,
round(total_revenue*1.0/sum(total_revenue) over(partition by category_id)*100,2) as pct_of_category_revenue,
case 
	when total_revenue>(select avg(total_revenue) 
						from t as tem 
						where t.category_id=tem.category_id) then 'Above Category Average'
    when total_revenue=(select avg(total_revenue) 
						from t as tem 
						where t.category_id=tem.category_id) then 'At Category Average'
	when total_revenue<(select avg(total_revenue) 
						from t as tem 
						where t.category_id=tem.category_id) then 'Below Category Average'
end as performance_classification
from t;