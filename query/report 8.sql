-- Report 8 Customer Retention Analysis
-- This report contains two parts. The first part reveals the customer behavior on an individual level,
-- and the second part reveals the overall customer segmentation.
-- Part 1
with t as (select i.invoiceno,sum((ip.quantity*p.unit_price)) as sales
from invoice i
join invoice_product ip 
on i.invoiceno=ip.invoiceno
join product p
on ip.stockcode=p.stockcode
group by i.invoiceno),
sales as (select c.customer_id,concat(c.first_name, ' ',c.last_name) as customer_name,min(date(i.invoicedate)) as first_date,
max(date(i.invoicedate)) as last_date,
count(distinct i.invoiceno) as number_of_invoices,round(sum(sales),2) as total_sales,
round(avg(sales),2)as average_sales, round(julianday(max(date(i.invoicedate)))-julianday(min(date(i.invoicedate))),0) as days_between
from customer c
join invoice i
on c.customer_id=i.customer_id
join t 
on t.invoiceno=i.invoiceno
group by c.customer_id,c.first_name,c.last_name)
select customer_id, customer_name,first_date,last_date,
number_of_invoices,total_sales,average_sales,days_between,
case
	when days_between>300 then 'Loyal Customer'
	when days_between> 100 then 'Returning Customer'
	else 'New Customer'
end as Customer_Segmentation
from sales
order by total_sales DESC;

-- Part 2
with r as (select Customer_Segmentation,count(customer_id) as customer_counts,
round(sum(total_sales),2) as total,round(avg(total_sales),2) as average
from (with t as (select i.invoiceno,sum((ip.quantity*p.unit_price)) as sales
from invoice i
join invoice_product ip 
on i.invoiceno=ip.invoiceno
join product p
on ip.stockcode=p.stockcode
group by i.invoiceno),
sales as (select c.customer_id,concat(c.first_name, ' ',c.last_name) as customer_name,min(date(i.invoicedate)) as first_date,
max(date(i.invoicedate)) as last_date,
count(distinct i.invoiceno) as number_of_invoices,round(sum(sales),2) as total_sales,
round(avg(sales),2)as average_sales, round(julianday(max(date(i.invoicedate)))-julianday(min(date(i.invoicedate))),0) as days_between
from customer c
join invoice i
on c.customer_id=i.customer_id
join t 
on t.invoiceno=i.invoiceno
group by c.customer_id,c.first_name,c.last_name)
select customer_id, customer_name,first_date,last_date,
number_of_invoices,total_sales,average_sales,days_between,
case
	when days_between>300 then 'Loyal Customer'
	when days_between> 100 then 'Returning Customer'
	else 'New Customer'
end as Customer_Segmentation
from sales)
group by Customer_Segmentation)
select Customer_Segmentation as 'Customer Segmentation',customer_counts as 'Number of Customers',
total as 'Total Revenue',average as 'Average Revenue',
round(customer_counts *1.0/sum(customer_counts) over(),2) as Percentage
from r