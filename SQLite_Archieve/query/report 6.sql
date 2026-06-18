-- Report 6 Manager Hierarchy Report
-- This report displays some information about managers and employees.
select concat(m.first_name,' ',m.last_name) as 'Manager Name',p.position as Position,
count (e.employee_id) as 'Number of Direct Reports',
coalesce(round(avg(e.salary),2),'N/A') as'Average Salary of Direct Reports',
coalesce(min(e.salary),'N/A') as'Lowest salary of direct reports',
coalesce(max(e.salary),'N/A') as'Highest salary of direct reports'
from employees e
right join employees m
on e.manager_id=m.employee_id
join position p
on m.position_id=p.position_id
where p.position in ('Director','Manager','Senior Manager')
group by m.employee_id,m.first_name,m.last_name,p.position
order by count (e.employee_id) DESC;