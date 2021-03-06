/*-------------------------------------------------------------------*/
create or replace view vw_call_volume_link as
select distinct  
	v.id as uniqueid,
	v.call_duration as duration,
	c.id as contractid,
	o.id as operatorid,
	o.code as operator_code,
	t.id as tierid,
	t.tier_code as tier_code,
	s.id as serviceid,
	s.code as service_code,
	mx.id as recentcontractid,
	vbr.id as vbrid,
	p.code as product_code,
	ifnull(vrp.is_vbr,'no') as is_vbr,
	vrp.rate_profile_detail_id,
	vrp.rate_type,
	v.start_date,
	v.end_date
from 
    ntc.data_call_volumes v
left join
    ntc.operators o
on
    v.operator_code=o.code
left join
    ntc.tier_details t
on
    v.tier=t.tier_code
left join
    ntc.services s
on
    v.call_type= s.code
left join
    ntc.contracts c
on 
    v.start_date >= c.start_date 
and 
    v.end_date<= c.end_date
and 
    o.id= c.operator_id
and
    s.id=c.service_id
left join
    vw_contract_recent mx
on
    mx.operator_id=o.id
and
    mx.service_id=s.id 
left join 
	vw_rate_profile_link vrp
on	
	vrp.operator_id=o.id
and 
	vrp.service_id=s.id
and	
	vrp.contract_id= coalesce(c.id, mx.id)
and
	vrp.tier_detail_id=t.id
left join	
	vbr_combinations vbr
on	
	t.id= vbr.tier_detail_id
and
	vrp.rate_profile_detail_id=vbr.rate_profile_detail_id
left join
	products p
on
	vbr.product_id=p.id
where 
    v.calculate_flag;
/*-------------------------------------------------------------------*/