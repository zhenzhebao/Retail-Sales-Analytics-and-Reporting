create role agent_user
with login
password  '<SET_PASSWORD_LOCALLY>';

grant connect on database postgres to agent_user;
grant usage on schema public to agent_user;
grant select on public.all_return_data to agent_user;
grant select on public.product_return_summary to agent_user;
grant select on public.product_category_return_summary to agent_user;
grant select on public.product_department_return_summary to agent_user;
grant select on public.customer_return_summary to agent_user;
grant select on public.country_return_summary to agent_user;