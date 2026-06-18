-- Postgres Schema

-- country definition

CREATE TABLE country (
country_id int constraint country_id_pk primary key,
country_name varchar (30) not null
);

-- customer definition

CREATE TABLE customer (
customer_id int constraint customer_id_pk primary key,
first_name varchar(30) not null,
last_name varchar(30) not null,
address varchar(200) not null,
apt_number varchar(30),
state varchar(30) not null,
city varchar(30) not null,
zip_code varchar(20) not null,
phone_number varchar (20),
email_address varchar(40),
membership_flag char(1) not null,
country_id int not null,
constraint membership_check check (membership_flag ='0' or membership_flag ='1'),
constraint fk_customer_country_id foreign key (country_id) references country (country_id)
);

CREATE INDEX idx_customer_country_id
on customer(country_id);

-- employee_department definition

CREATE TABLE employee_department (
department_id int constraint department_id_pk primary key,
employee_department varchar(30) not null
);

-- "position" definition

CREATE TABLE position (
position_id int constraint position_id_pk primary key,
position varchar(30) not null
);

-- employees definition

CREATE TABLE employees(
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
constraint fk_employee_country_id foreign key (country_id) references country (country_id),
constraint fk_department_id foreign key (department_id) references employee_department (department_id),
constraint fk_position_id foreign key (position_id) references position (position_id),
constraint temporary_employee_value_check check (temporary_employee =0 or temporary_employee=1)
);

alter table employees
add constraint fk_manager_id foreign key (manager_id) references employees (employee_id);

-- invoice definition

CREATE TABLE invoice(
invoiceno varchar(7) constraint invoiceno_pk primary key,
invoicedate timestamp not null,
customer_id int not null,
employee_id int not null,
constraint fk_employee_id foreign key (employee_id)
references employees (employee_id),
constraint fk_invoice_customer_id foreign key (customer_id)
references customer (customer_id)
);

-- department definition

CREATE TABLE department (
department_id integer constraint product_department_id_pk primary key GENERATED ALWAYS AS IDENTITY,
product_department varchar(30) not null
);

-- category definition

CREATE TABLE category (
category_id int constraint category_id_pk primary key,
category_name varchar(30) not null,
department_id integer not null,
constraint fk_department_id foreign key (department_id)
references department (department_id)
);

-- product definition

CREATE TABLE product(
stockcode varchar(12) constraint stockcode_pk primary key,
description varchar(200) not null,
unit_price float(2) not null,
category_id int not null,
constraint fk_category_id foreign key (category_id)
references category (category_id)
);

-- invoice_product definition

CREATE TABLE invoice_product(
invoice_product_id int constraint invoice_product_id_pk primary key,
quantity int not null,
stockcode varchar (12) not null,
invoiceno varchar(7) not null,
constraint fk_invoiceno foreign key (invoiceno) references invoice (invoiceno),
constraint fk_stockcode foreign key (stockcode) references product (stockcode));

-- membership_type definition

CREATE TABLE membership_type(
membership_type_id int constraint membership_type_id_pk primary key,
membership_type varchar(30) not null,
constraint membership_type_check check(membership_type ='Silver' or 
membership_type ='Gold' or membership_type ='Bronze'));

-- membership definition

CREATE TABLE membership (
membership_id int constraint memebership_pk primary key,
membership_type_id int not null,
customer_id int not null,
constraint fk_membership_type_id foreign key (membership_type_id)
references membership_type (membership_type_id),
constraint fk_customer_id foreign key (customer_id)
references customer(customer_id)
);

create table campaign(
campaign_id int constraint campaign_pk primary key,
campaign_name varchar(30) not null,
campaign_type varchar(30) not null
);

create table customer_campaign(
customer_campaign_id int constraint customer_campaign_pk primary key,
sent_date date not null,
opened char(1) not null,
clicked char(1) not null,
converted char(1) not null,
conversion_amount float,
unsubscribe char(1) not null,
campaign_id int not null,
customer_id int not null,
constraint opened_check check (opened='Y' or opened='N'),
constraint clicked_check check (clicked='Y' or clicked='N'),
constraint converted_check check (converted='Y' or converted='N'),
constraint unsubscribe_check check (unsubscribe='Y' or unsubscribe='N'));

alter table customer_campaign
add constraint fk_customer_id foreign key (customer_id)
references customer (customer_id), 
add constraint fk_campaign_id foreign key (campaign_id)
references campaign (campaign_id);
