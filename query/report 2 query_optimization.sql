-- This is a modified version of report 2 to display only sales in the biggest market, the U.K.
-- To improve query performance, an index was created on customer.country_id, 
-- which is frequently used in filtering and join operations. Before the index was implemented, 
-- SQLite performed a full table scan on the customer table to locate U.K. customers. 
-- After the index was created, SQLite utilized the index to directly locate matching records, 
-- reducing the amount of data that needed to be scanned. 

explain query plan
select c.customer_id as 'Customer ID',concat(c.first_name,' ',c.last_name) as 'Customer Name',
c.email_address as 'Email Address', c.phone_number as 'Phone Number',
co.country_name as Country,c.city as City ,c.state as State,
case
	when c.membership_flag ='1' then 'Yes'
	else 'No'
end as Membership
from customer c
join country co
on c.country_id=co.country_id
where c.country_id=2
order by c.last_name,c.first_name;

create index idx_customer_country_id
on customer(country_id);

explain query plan
select c.customer_id as 'Customer ID',concat(c.first_name,' ',c.last_name) as 'Customer Name',
c.email_address as 'Email Address', c.phone_number as 'Phone Number',
co.country_name as Country,c.city as City ,c.state as State,
case
	when c.membership_flag ='1' then 'Yes'
	else 'No'
end as Membership
from customer c
join country co
on c.country_id=co.country_id
where c.country_id=2
order by c.last_name,c.first_name;