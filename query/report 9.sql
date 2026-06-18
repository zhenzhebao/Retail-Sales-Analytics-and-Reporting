-- Report 9 Data Quality Audit
-- Verify data quality for certain tables in the database

-- Part 1 Customer Data Quality
select customer_id, ('no first name') as issue
from customer
where first_name is null
union all 
select customer_id, ('no last name') as issue
from customer
where last_name is null
union all 
select customer_id, ('no email address') as issue
from customer
where email_address is null
union all
select customer_id, ('no phone number') as issue
from customer
where phone_number is null;

-- Part 2 Product Data Quality
select stockcode, ('no description') as issue
from product
where description is null
union all
select stockcode, ('no category') as issue
from product
where category_id is null
union all
select stockcode, ('negative price') as issue
from product
where unit_price<0
union all
select stockcode, ('zero price') as issue
from product
where unit_price=0;

-- Part 3 Membership Data Quality
select m.customer_id, ('non-member with membership record') as issue
from membership m
where m.customer_id in (select customer_id from customer where membership_flag='0')
union all
select customer_id, ('member without membership record') as issue
from customer
where membership_flag='1'
and customer_id not in (select customer_id from membership);