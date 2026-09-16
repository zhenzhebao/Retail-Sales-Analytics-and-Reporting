/*Prepare the dataset*/
create materialized view all_retail_data as 
select c.customer_id,concat(c.first_name,' ',c.last_name) as customer_name,
co.country_name as customer_country,mt.membership_type,i.invoiceno,i.invoicedate,
ip.quantity,p.stockcode,p.description as product_description,
p.unit_price as product_unit_price,ca.category_name as product_category,d.product_department
from customer c
join country co
on c.country_id=co.country_id 
join invoice i
on i.customer_id=c.customer_id
join invoice_product ip
on ip.invoiceno=i.invoiceno
join product p
on p.stockcode=ip.stockcode
join category ca
on ca.category_id=p.category_id
join department d 
on d.department_id=ca.department_id
left join membership me
on me.customer_id=c.customer_id
left join membership_type mt
on mt.membership_type_id=me.membership_type_id;

create view all_sales_data as 
select customer_id,customer_name,customer_country,membership_type,invoiceno,invoicedate,
quantity,stockcode,product_description,product_unit_price,product_category,product_department
from all_retail_data
where quantity>0;

create view all_return_data as 
select customer_id,customer_name,customer_country,membership_type,invoiceno,invoicedate,
quantity,stockcode,product_description,product_unit_price,product_category,product_department
from all_retail_data
where quantity<0;

/* validate the number of records in all sales and all return to see if that matches all retail records*/
select count(*)-(select count(*) from all_sales_data)-(select count(*) from all_return_data)
from all_retail_data;

/* monthly return*/
with t as (select date(date_trunc('month',invoicedate))as month,abs(sum(quantity)) as total_return_quantity,
abs(sum(quantity*product_unit_price)) as total_return_value
from all_return_data
group by date(date_trunc('month',invoicedate)))
select month,total_return_quantity,total_return_value
from t
order by month;

/* return by prodcut*/
with t as (select stockcode,product_description,abs(sum(quantity)) as total_return_quantity,
abs(sum(quantity*product_unit_price)) as total_return_value
from all_return_data
group by stockcode,product_description)
select stockcode,product_description,total_return_quantity,total_return_value,
dense_rank() over(order by total_return_quantity desc) as return_quantity_rank,
dense_rank() over(order by total_return_value desc) as return_value_rank
from t;

/* return by product category*/
with t as (select product_category,abs(sum(quantity)) as total_return_quantity,
abs(sum(quantity*product_unit_price)) as total_return_value
from all_return_data
group by product_category)
select product_category,total_return_quantity,total_return_value,
dense_rank() over(order by total_return_quantity desc) as return_quantity_rank,
dense_rank() over(order by total_return_value desc) as return_value_rank
from t;

/* return by product department*/
with t as (select product_department,abs(sum(quantity)) as total_return_quantity,
abs(sum(quantity*product_unit_price)) as total_return_value
from all_return_data
group by product_department)
select product_department,total_return_quantity,total_return_value,
dense_rank() over(order by total_return_quantity desc) as return_quantity_rank,
dense_rank() over(order by total_return_value desc) as return_value_rank
from t;

/*return by customer*/
with t as (select customer_id,customer_name,quantity,product_unit_price,
case 
	when quantity<0 then abs(quantity*product_unit_price)
	else 0
end as return_value,
case 
	when quantity>0 then (quantity*product_unit_price)
	else 0
end as sales_value
from all_retail_data),
t2 as (select customer_id,customer_name,sum(return_value) as total_return_value,
sum(sales_value) as total_sales_value
from t
group by customer_id,customer_name),
t3 as (select customer_id,customer_name,total_return_value,total_sales_value,
(total_return_value*1.0/nullif(total_sales_value,0)) as return_rate
from t2)
select customer_id,customer_name,total_return_value,total_sales_value,return_rate,
dense_rank() over(order by total_return_value desc) as return_value_rank,
dense_rank() over(order by return_rate desc) as return_rate_rank
from t3;

/* return by country*/
with t as (select customer_country,quantity,product_unit_price,
case 
	when quantity<0 then abs(quantity*product_unit_price)
	else 0
end as return_value,
case 
	when quantity>0 then (quantity*product_unit_price)
	else 0
end as sales_value
from all_retail_data),
t2 as (select customer_country,sum(return_value) as total_return_value,
sum(sales_value) as total_sales_value
from t
group by customer_country),
t3 as (select customer_country,total_return_value,total_sales_value,
(total_return_value*1.0/nullif(total_sales_value,0)) as return_rate
from t2)
select customer_country,total_return_value,total_sales_value,return_rate,
dense_rank() over(order by total_return_value desc) as return_value_rank,
dense_rank() over(order by return_rate desc) as return_rate_rank
from t3;