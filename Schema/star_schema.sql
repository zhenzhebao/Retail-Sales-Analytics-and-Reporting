/* Star Schema */
/* create and insert data for customer table */
create table customer(
dim_customer_id int generated always as identity constraint dim_customer_id_pk primary key,
customer_id int not null,
name varchar(60) not null,
city varchar(30) not null,
state varchar(30) not null,
country varchar(30) not null,
membership_type varchar(30) not null,
effective_date date not null,
expiration_date date not null,
is_current boolean not null,
constraint membership_type_check 
check (membership_type in ('Gold','Silver','Bronze','Non-Member')));

insert into star.customer(customer_id,name,city,state,country,membership_type,
effective_date,expiration_date,is_current)
select c.customer_id,concat(c.first_name,' ',c.last_name)as name,c.city,c.state,
co.country_name as country,coalesce(mt.membership_type,'Non-Member')as membership_type,
(select date(min(invoicedate)) from invoice) as effective_date, date '2099-12-31' as expiration_date,
True as is_current
from public.customer c
left join membership m
on m.customer_id=c.customer_id
left join membership_type mt
on mt.membership_type_id=m.membership_type_id
join country co
on c.country_id=co.country_id;

/* create and insert data for employees table */
create table employees(
dim_employee_id int generated always as identity constraint dim_employee_id_pk primary key,
employee_id int not null,
name varchar(60) not null,
position varchar(30) not null,
employee_department varchar(30) not null,
manager varchar(60),
country varchar(30) not null,
effective_date date not null,
expiration_date date not null,
is_current boolean not null);

insert into star.employees(employee_id,name,position,employee_department,
manager,country,effective_date,expiration_date,is_current)
select e.employee_id,concat(e.first_name,' ',e.last_name) as name,p.position,
ed.employee_department,concat(m.first_name,' ',m.last_name) as manager,
co.country_name as country,(select date(min(invoicedate)) from invoice) as effective_date, 
date '2099-12-31' as expiration_date,True as is_current
from public.employees e
join position p
on p.position_id=e.position_id
join employee_department ed
on e.department_id = ed.department_id
join country co
on e.country_id=co.country_id
left join public.employees m
on m.employee_id=e.manager_id;

/* create and insert data for date table */
create table date(
date_id int generated always as identity constraint date_id_pk primary key,
calendar_date date not null,
day_of_week int not null,
day_name varchar(9) not null,
is_weekend boolean not null,
week int not null,
month int not null,
month_name varchar(9) not null,
quarter int not null,
year int not null);

insert into star.date (calendar_date,day_of_week,day_name,is_weekend,week,month,month_name,quarter,year)
with t as (select date(generate_series(date '2010-12-01',date '2010-12-01' + interval '395 day',
interval '1 day'))as calendar_date),
t2 as (select calendar_date,extract(DoW from calendar_date) as day_of_week,
extract(week from calendar_date) as week, extract(month from calendar_date)as month,
extract(quarter from calendar_date) as quarter, extract(year from calendar_date) as year
from t)
select calendar_date,day_of_week,trim(to_char(calendar_date,'Day')) as day_name,
case
	when trim(to_char(calendar_date,'Day')) in ('Saturday','Sunday') then true
	else False
end as is_weekend,week,month,
trim(to_char(calendar_date,'Month')) as month_name,quarter,year
from t2;

/* create and insert data for product table */
create table product(
dim_product_id int generated always as identity constraint dim_product_id_pk primary key,
stockcode varchar(12) not null,
product_description varchar(200) not null,
current_listing_price numeric(10,2) not null,
product_category varchar(30) not null ,
product_department varchar(30) not null,
effective_date date not null,
expiration_date date not null,
is_current boolean not null);

insert into star.product (stockcode,product_description,current_listing_price,
product_category,product_department,effective_date,expiration_date,is_current)
select p.stockcode,p.description as product_description,p.unit_price as current_listing_price,
ca.category_name as product_category,d.product_department,
(select date(min(invoicedate)) from invoice) as effective_date, 
date '2099-12-31' as expiration_date,True as is_current
from public.product p
join category ca
on p.category_id=ca.category_id
join department d
on ca.department_id=d.department_id;

/* create and insert data for fact_order_item table */
create table fact_order_item(
fact_order_item_id bigint generated always as identity constraint fact_order_item_id primary key,
invoice_no varchar(7) not null,
date_id int not null,
dim_product_id int not null,
dim_customer_id int not null,
dim_employee_id int not null,
item_transaction_price numeric(10,2) not null,
item_quantity int not null,
item_order_value numeric(10,2) not null,
is_return boolean not null,
constraint fk_date_id foreign key (date_id) references star.date(date_id),
constraint fk_dim_product_id foreign key (dim_product_id) references star.product (dim_product_id),
constraint fk_dim_customer_id foreign key (dim_customer_id) references star.customer (dim_customer_id),
constraint fk_dim_employee_id foreign key (dim_employee_id) references star.employees (dim_employee_id)
);

insert into star.fact_order_item (invoice_no,date_id,dim_product_id,dim_customer_id,dim_employee_id,
item_transaction_price,item_quantity,item_order_value,is_return)
with t as (select pi.invoiceno,date(pi.invoicedate) as invoicedate,pp.stockcode,pc.customer_id,
pe.employee_id,pp.unit_price as item_transaction_price,pip.quantity as item_quantity,
round((pp.unit_price*pip.quantity)::numeric,2) as item_order_value,
case
	when pip.quantity<0 then true 
	else False
end as is_return
from public.customer pc
join public.invoice pi
on pi.customer_id=pc.customer_id
join public.invoice_product pip
on pip.invoiceno=pi.invoiceno
join public.product pp
on pp.stockcode=pip.stockcode
join public.employees pe
on pe.employee_id=pi.employee_id)
select t.invoiceno,sd.date_id,sp.dim_product_id,sc.dim_customer_id,se.dim_employee_id,
t.item_transaction_price,t.item_quantity,t.item_order_value,t.is_return
from t t
join star.customer sc
on sc.customer_id=t.customer_id
join star.employees se
on se.employee_id=t.employee_id
join star.date sd
on sd.calendar_date=t.invoicedate
join star.product sp
on sp.stockcode=t.stockcode;