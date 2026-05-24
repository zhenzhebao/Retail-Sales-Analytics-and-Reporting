--Report 5 Employee Sales Performance
--This report reveals the employee performance for people working in the sales department.
select concat(e.first_name,' ',e.last_name) as Name,
po.position as Position,ed.employee_department as Department,count(distinct i.invoiceno) as'Number of invoices processed',
round(sum(ip.quantity *p.unit_price),2) as 'Total Sales',
round(sum(ip.quantity *p.unit_price)*1.0/count(distinct i.invoiceno),2) as 'Average Sales'
from employees e
join position po
on e.position_id=po.position_id
join employee_department ed
on e.department_id=ed.department_id
join invoice i
on i.employee_id=e.employee_id
join invoice_product ip 
on i.invoiceno=ip.invoiceno
join product p
on ip.stockcode=p.stockcode
group by e.employee_id,e.first_name,e.last_name,po.position,ed.employee_department
order by round(sum(ip.quantity *p.unit_price),2) DESC;