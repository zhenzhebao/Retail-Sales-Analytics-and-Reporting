-- Campaign Performance View
-- Aggregated result for each Campaign
create view campaign_performance_view as 
with summary as (select ca.campaign_id,ca.campaign_name,ca.campaign_type,
count (c.customer_id) as customers_targeted,
count (case when cc.opened='Y' then 1 end) as opened_count,
count (case when cc.clicked='Y' then 1 end) as clicked_count,
count (case when cc.converted='Y' then 1 end) as converted_count,
count (case when cc.unsubscribe='Y' then 1 end) as unsubscribe_count,
sum(cc.conversion_amount) as total_conversion_amount
from campaign ca
join customer_campaign cc
on  cc.campaign_id=ca.campaign_id
join customer c
on cc.customer_id=c.customer_id
group by ca.campaign_id,ca.campaign_name,ca.campaign_type)
select campaign_id,campaign_name,campaign_type,customers_targeted,opened_count,
clicked_count,converted_count,unsubscribe_count,total_conversion_amount,
round(cast(opened_count*1.0/nullif(customers_targeted,0)*100 as numeric),2) as open_rate,
round(cast(clicked_count*1.0/nullif(opened_count,0)*100 as numeric),2) as clicked_rate,
round(cast(converted_count*1.0/nullif(clicked_count,0)*100 as numeric),2) as conversion_rate,
round(cast(unsubscribe_count*1.0/nullif(customers_targeted,0)*100 as numeric),2) as unsubscribe_rate,
round(cast(total_conversion_amount*1.0/nullif(converted_count,0) as numeric),2) as average_conversion_amount
from summary
order by campaign_id;