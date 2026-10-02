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

create view all_return_data as 
with t as (select customer_id,customer_name,customer_country,membership_type,invoiceno,invoicedate,
quantity,stockcode,product_description,product_unit_price,product_category,product_department
from all_retail_data
where quantity<0),
t2 as (select customer_id,customer_name,customer_country,membership_type,invoiceno,invoicedate,
quantity,stockcode,product_description,product_unit_price,product_category,product_department,
row_number() over(partition by customer_id, customer_name, customer_country, membership_type,
invoiceno, invoicedate, quantity,stockcode, product_description, 
product_unit_price, product_category, product_department) as ranking
from t)
/* Confirmed that both flagged records are duplicates.
   Keep only the first occurrence of each identical record using ranking = 1.
select customer_id,customer_name,customer_country,membership_type,invoiceno,invoicedate,
quantity,stockcode,product_description,product_unit_price,product_category,product_department,ranking
from t2
where ranking=2;

select *
from t2
where customer_id=16029 and invoiceno='C570556' and stockcode='22273';*/
/*select *
from t2
where customer_id=17850 and invoiceno='C543611' and stockcode='21730';*/
select customer_id,customer_name,customer_country,membership_type,invoiceno,invoicedate,
quantity,stockcode,product_description,product_unit_price,product_category,product_department
from t2
where ranking=1;

/* No records with 0 or negative price*/
select count(*) 
from all_return_data
where product_unit_price<=0;