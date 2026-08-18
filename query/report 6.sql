/* Evaluates each customer’s purchasing behavior through purchase patterns, orders placed,total revenue,
and customer lifetime, then classifies customers based on purchase frequency and recency.*/
with t as (select c.customer_id,concat(c.first_name,' ',c.last_name)as customer_name,country_name,
count(distinct i.invoiceno) as number_of_orders, sum(ip.quantity*p.unit_price) as total_revenue,
date(min(i.invoicedate)) as first_purchase_date,date(max(i.invoicedate)) as most_recent_purchase_date,
(select date(max(invoicedate)) from invoice)-date(max(i.invoicedate)) as days_since_most_recent_purchase,
date(max(i.invoicedate))-date(min(i.invoicedate)) as customer_lifetime
from customer c
join country co
on c.country_id=co.country_id
join invoice i
on i.customer_id=c.customer_id
join invoice_product ip
on ip.invoiceno=i.invoiceno
join product p
on p.stockcode=ip.stockcode
where ip.quantity>0
group by c.customer_id,concat(c.first_name,' ',c.last_name),country_name),
t2 as (select customer_id,customer_name,country_name,number_of_orders,total_revenue,first_purchase_date,
most_recent_purchase_date,days_since_most_recent_purchase,customer_lifetime,
case
	when number_of_orders <2 then 'One-Time Customer'
	when number_of_orders <5 then 'Occasional Customer'
	when number_of_orders >=5 then 'Frequent Customer'
end as purchase_frequency,
case
	when days_since_most_recent_purchase<=30 then 'Recent'
	when days_since_most_recent_purchase<=90 then 'Moderately Recent'
	when days_since_most_recent_purchase>90 then 'Inactive'
end as recency_classification
from t),
t3 as (select purchase_frequency,count(customer_id) as number_of_customers, 
round(avg(total_revenue)::numeric,2) as average_revenue_per_customer,
round(avg(number_of_orders)::numeric,2) as average_number_of_orders,
round(avg(days_since_most_recent_purchase)::numeric,2) as average_days_since_last_purchase
from t2
group by purchase_frequency)
select purchase_frequency,number_of_customers,average_revenue_per_customer,
average_number_of_orders,average_days_since_last_purchase,
round(cast((select count(customer_id) 
from t2 as tem
where tem.purchase_frequency=t3.purchase_frequency 
and tem.recency_classification='Recent')*1.0/
number_of_customers*100 as numeric),2) as percentage_of_recent_customers
from t3;