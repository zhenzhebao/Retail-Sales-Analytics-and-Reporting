-- report 1 Customer Directory Report
--This report provides an overview of all customers, displaying their personal information and 
--indicating whether they are members or not.

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
order by c.last_name,c.first_name;