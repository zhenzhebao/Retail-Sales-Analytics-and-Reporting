-- Report 7 Monthly Sales Trend
-- This report aggregates sales data at the monthly level and then reveals the month-to-month trends.
with sales as (select i.invoicedate,i.invoiceno,sum(ip.quantity) as quantity,sum((ip.quantity *p.unit_price)) as invoice_value
from invoice i
join invoice_product ip
on i.invoiceno=ip.invoiceno
join product p
on ip.stockcode=p.stockcode
group by i.invoiceno,i.invoicedate),
monthly_sales as (select Strftime('%Y-%m', invoicedate) as Month,count(invoiceno) as Number_of_invoices,
sum(quantity) as Total_units_sold ,round(sum(invoice_value),2) as Total_revenue,
round(avg(invoice_value),2) as Average_invoice_value
from sales
group by Strftime('%Y-%m', invoicedate))
select Month,Number_of_invoices,Total_units_sold,Total_revenue,Average_invoice_value,
round(Total_revenue-lag(Total_revenue,1) over(order by Month),2) as changes,
round(round(Total_revenue-lag(Total_revenue,1) over(order by Month),2)*1.0/lag(Total_revenue,1) over(order by Month),2) as percentage_changes
from monthly_sales
order by Month;