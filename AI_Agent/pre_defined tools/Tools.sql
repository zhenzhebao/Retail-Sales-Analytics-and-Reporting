/* monthly return*/
with t as (select date(date_trunc('month',invoicedate))as month,abs(sum(quantity)) as total_return_quantity,
abs(sum(quantity*product_unit_price)) as total_return_value
from all_return_data
group by date(date_trunc('month',invoicedate)))
select month,total_return_quantity,total_return_value
from t
order by month;

/* return by product*/
create view product_return_summary as 
with t as (select stockcode,product_description,abs(sum(quantity)) as total_return_quantity,
abs(sum(quantity*product_unit_price)) as total_return_value
from all_return_data
group by stockcode,product_description)
select stockcode,product_description,total_return_quantity,total_return_value,
dense_rank() over(order by total_return_quantity desc) as return_quantity_rank,
dense_rank() over(order by total_return_value desc) as return_value_rank
from t;

/* return by product category*/
create view product_category_return_summary as
with t as (select product_category,abs(sum(quantity)) as total_return_quantity,
abs(sum(quantity*product_unit_price)) as total_return_value
from all_return_data
group by product_category)
select product_category,total_return_quantity,total_return_value,
dense_rank() over(order by total_return_quantity desc) as return_quantity_rank,
dense_rank() over(order by total_return_value desc) as return_value_rank
from t;

/* return by product department*/
create view product_department_return_summary as 
with t as (select product_department,abs(sum(quantity)) as total_return_quantity,
abs(sum(quantity*product_unit_price)) as total_return_value
from all_return_data
group by product_department)
select product_department,total_return_quantity,total_return_value,
dense_rank() over(order by total_return_quantity desc) as return_quantity_rank,
dense_rank() over(order by total_return_value desc) as return_value_rank
from t;

/*return by customer*/
create view customer_return_summary as
with t as (select customer_id,
abs(sum(quantity*product_unit_price)) as total_return_value
from all_return_data
group by customer_id)
select customer_id,total_return_value,
dense_rank() over(order by total_return_value desc) as return_value_rank
from t;

/* return by country*/
create view country_return_summary as
with t as (select customer_country,quantity,product_unit_price,
case 
	when quantity<0 then abs(quantity*product_unit_price)
	else 0
end as return_value
from all_retail_data),
t2 as (select customer_country,sum(return_value) as total_return_value
from t
group by customer_country)
select customer_country as country,total_return_value,
dense_rank() over(order by total_return_value desc) as return_value_rank
from t2;