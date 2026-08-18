/*Showcases how each sales representative performs based on sales value and order volume.*/
select e.employee_id,concat(e.first_name,' ',e.last_name) as employee_name,po.position,
ed.employee_department,concat(m.first_name,' ',m.last_name)as manager_name,
count(distinct i.invoiceno) as number_of_invoices, count(distinct c.customer_id) as number_of_customers,
round(sum(ip.quantity*p.unit_price)::numeric,2) as total_revenue, 
round(cast(sum(ip.quantity*p.unit_price)*1.0/count(distinct i.invoiceno)as numeric),2) as avg_invoice_value
from employees e
left join employees m
on e.manager_id=m.employee_id
join position po
on po.position_id=e.position_id
join employee_department ed
on e.department_id=ed.department_id
join invoice i
on i.employee_id=e.employee_id
join invoice_product ip
on ip.invoiceno=i.invoiceno
join product p
on p.stockcode=ip.stockcode
join customer c
on c.customer_id=i.customer_id
where ed.employee_department='Sales' and ip.quantity>0
group by e.employee_id,concat(e.first_name,' ',e.last_name),po.position,
ed.employee_department,concat(m.first_name,' ',m.last_name);