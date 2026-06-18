-- Customer Quality and Value Report
-- Check the Quality of all customer information in the database, 
-- then rank the total sales for all customers in descending order.
with clean_info as (select c.customer_id,concat(c.first_name,' ',c.last_name) as customer_name,co.country_name,
coalesce(nullif(trim(c.email_address),''),'Missing') as email,
coalesce(nullif(trim(c.phone_number),''),'Missing') as phone,
c.membership_flag
from customer c 
join country co
on c.country_id=co.country_id),
customer_info as (select customer_id,customer_name,country_name,
case 
	when email ='Missing' then 'Missing Email'
	else 'Valid Email'
end as email_status,
case 
	when phone ='Missing' then 'Missing Phone'
	else 'Valid Phone'
end as phone_status,
case 
	when membership_flag='1' then 'Member'
	else 'Non-Member'
end as membership_status
from clean_info),
invoice_data as(
select p.unit_price,ip.quantity,i.invoiceno,i.invoicedate,to_char(i.invoicedate,'YYYY-MM') as year_month,
i.customer_id
from product p
join invoice_product ip
on p.stockcode=ip.stockcode
join invoice i 
on ip.invoiceno=i.invoiceno
where ip.quantity>0),
customer_invoice as (select invoiceno,year_month,invoicedate,sum(unit_price*quantity) as invoice_total,customer_id
from invoice_data
group by invoiceno,invoicedate,year_month,customer_id),
aggregated_info as (select cf.customer_id,cf.customer_name,cf.country_name,cf.email_status,
cf.phone_status,cf.membership_status,count(ci.invoiceno) as invoice_count,
count(distinct ci.year_month) as active_month_count,sum(coalesce(ci.invoice_total,0)) as total_revenue,
max(date(ci.invoicedate)) as latest_invoice_date
from customer_info cf
left join customer_invoice ci
on cf.customer_id=ci.customer_id
group by cf.customer_id,cf.customer_name,cf.country_name,cf.email_status,
cf.phone_status,cf.membership_status),
t as (select customer_id,customer_name,country_name,email_status,phone_status,membership_status,
invoice_count,active_month_count,total_revenue,latest_invoice_date,
round(cast(total_revenue*1.0/nullif(invoice_count,0) as numeric),2) as avg_invoice_value
from aggregated_info)
select customer_id,customer_name,country_name,email_status,phone_status,membership_status,
invoice_count,active_month_count,total_revenue,latest_invoice_date,avg_invoice_value,
rank () over (order by total_revenue DESC) as customer_value_rank
from t;