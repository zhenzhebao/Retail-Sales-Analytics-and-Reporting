/*Constructs two reports in PostgreSQL and Snowflake to analyze product category 
performance based on total revenue, sales quantity, and order volume.*/

/*PostgreSQL*/
with t as (select ca.category_name,sum(ip.quantity*p.unit_price) as total_revenue,
sum(ip.quantity) as total_units_sold,count(distinct i.invoiceno) as number_of_orders,
count(distinct c.customer_id) as number_of_customers,
round(sum(ip.quantity*p.unit_price)*1.0/count(distinct i.invoiceno)::numeric,2) as average_order_value
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
group by ca.category_name)
select category_name,total_revenue,total_units_sold,number_of_orders,number_of_customers,
average_order_value,
rank() over(order by total_revenue desc) as ranking,
round(cast(total_revenue/sum(total_revenue) over()*100 as numeric),2) as pct_of_total_company_revenue
from t;

/*Snowflake*/
with t as (select p.product_category,round(sum(foi.item_transaction_price*foi.item_quantity)::numeric,2) as total_revenue,
sum(foi.item_quantity) as total_units_sold,count(distinct foi.invoice_no)as number_of_orders,
count(distinct c.customer_id) as number_of_customers,
round(cast(sum(foi.item_transaction_price*foi.item_quantity)*1.0/
count(distinct foi.invoice_no) as numeric),2) as average_order_value
from fact_order_item foi
join product p 
on p.dim_product_id=foi.dim_product_id
join customer c
on c.dim_customer_id=foi.dim_customer_id
where foi.is_return=False
group by p.product_category)
select product_category,total_revenue,total_units_sold,number_of_orders,number_of_customers,average_order_value,
round(cast(total_revenue/sum(total_revenue) over()*100 as numeric),2) as pct_of_total_company_revenue,
rank() over(order by total_revenue desc) as ranking
from t