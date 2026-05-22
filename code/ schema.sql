-- relationship 1: category and department
create table department (
department_id int constraint department_id_pk primary key,
product_department varchar(30) not null
);

create table category (
category_id int constraint category_id_pk primary key,
category_name varchar(30) not null,
department_id int not null,
constraint fk_department_id foreign key (department_id)
references department (department_id)
);

-- relationship 2: product and category
create table product(
stockcode varchar(12) constraint stockcode_pk primary key,
description varchar(200) not null,
unit_price float(2) not null,
category_id int not null,
constraint fk_category_id foreign key (category_id)
references category (category_id)
);

--relationship 3: invoice and product
create table invoice(
invoiceno varchar(7) constraint invoiceno_pk primary key,
invoicedate datetime not null,
customer_id int not null,
employee_id int not null,
constraint fk_employee_id foreign key (employee_id)
references employees (employee_id),
constraint fk_customer_id foreign key (customer_id)
references customer (customer_id)
);

create table invoice_product(
invoice_product_id int constraint invoice_product_id_pk primary key,
quantity int not null,
stockcode varchar (12) not null,
invoiceno varchar(7) not null,
constraint fk_invoiceno foreign key (invoiceno) references invoice (invoiceno),
constraint fk_stockcode foreign key (stockcode) references product (stockcode));

-- relationship 4 employee, position, department and invoice and country;
create table employees(
employee_id int constraint employee_id_pk primary key,
first_name varchar(30) not null,
last_name varchar(30) not null,
hire_date DATE not null,
salary INT,
position_id int not null,
department_id int not null,
country_id int not null,
manager_id int,
temporary_employee int not null,
constraint fk_country_id foreign key (country_id) references country (country_id),
constraint fk_manager_id foreign key (manager_id) references employees (employee_id),
constraint fk_department_id foreign key (department_id) references employee_department (department_id),
constraint fk_position_id foreign key (position_id) references position (position_id),
constraint temporary_employee_value_check check (temporary_employee ==0 or temporary_employee==1)
);

create table employee_department (
department_id int constraint department_id_pk primary key,
employee_department varchar(30) not null
);

create table position (
position_id int constraint position_id_pk primary key,
position varchar(30) not null
);

create table country (
country_id int constraint country_id_pk primary key,
country_name varchar (30) not null
);
-- relationship 5 customer

create table customer (
customer_id int constraint customer_id_pk primary key,
first_name varchar(30) not null,
last_name varchar(30) not null,
address varchar(200) not null,
apt_number varchar(30),
state varchar(30) not null,
city varchar(30) not null,
zip_code int not null,
phone_number varchar (20),
email_address varchar(40),
membership char(1) not null,
country_id int not null,
constraint membership_check check (membership =='0' or membership =='1'),
constraint fk_country_id foreign key (country_id) references country (country_id)
);

create table membership (
membership_id int constraint memebership_pk primary key,
membership_type_id int not null,
customer_id int not null,
constraint fk_membership_type_id foreign key (membership_type_id)
references membership_type (membership_type_id),
constraint fk_customer_id foreign key (customer_id)
references customer(customer_id)
);

create table membership_type(
membership_type_id int constraint membership_type_id_pk primary key,
membership_type varchar(30) not null,
constraint membership_type_check check(membership_type =='Silver' or 
membership_type =='Gold' or membership_type =='Bronze'));


-- check the entire database
select count(c.country_id)
from invoice i
join employees e
on i.employee_id=e.employee_id
join position p 
on p.position_id=e.position_id
join employee_department ed 
on ed.department_id=e.department_id
join invoice_product ip 
on ip.invoiceno=i.invoiceno
join product p
on p.stockcode=ip.stockcode
join category c
on p.category_id=c.category_id
join department d
on d.department_id=c.department_id
join country c
on c.country_id=e.country_id
join customer cu
on cu.customer_id=i.customer_id
join membership m 
on m.customer_id =cu.customer_id
join membership_type mt 
on mt.membership_type_id=m.membership_type_id;












