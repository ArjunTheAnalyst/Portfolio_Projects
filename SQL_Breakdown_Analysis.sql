use Placement_Project

select * from breakdown_data

/*
Question:
Analyze the machines based on their age and calculate the average number of breakdowns for each age group to determine 
if older machines tend to break down more frequently.
*/
-- age of each machine
with machine_age as 
(
select 
	machine_number,
	datediff(year, commencement_date, getdate()) as age_of_machine
from 
	breakdown_data
where
	machine_active = 1 -- excluding deactivated machines
and
	commencement_date is not null --  excluding machines where commencement_date is null because if commencement_date is null, we cannot accurately calculate the machine's age
group by
	machine_number, commencement_date
--order by
--	age_of_machine desc
),
-- count of breakdowns
breakdown_counts as
(
select 
	machine_number,
	count(breakdown_id) as count_of_breakdowns
from 
	breakdown_data
where
	machine_active = 1 -- excluding deactivated machines
group by
	machine_number
--order by
--	count_of_breakdowns desc
),
-- combining age of machine and count of breakdowns ctes
machine_age_breakdown as
(
select
	a.machine_number,
	age_of_machine,
	coalesce(count_of_breakdowns, 0) as count_of_breakdowns-- left join will return only matching rows from breakdown_counts, if a machine has no breakdown, it will return null
from 
	machine_age as a
left join
	breakdown_counts as b
on
	a.machine_number = b.machine_number
)
-- returning average breakdowns per age group
select
	age_of_machine,
	avg(count_of_breakdowns) as avg_breakdown_per_age_group
from 
	machine_age_breakdown
group by 
	age_of_machine
order by
	age_of_machine

/*
Here’s a brief breakdown of the results:
Age 0-1: Machines in their first year have minimal breakdowns, averaging 4-6.
Age 2-4: A sharp increase in breakdowns occurs, peaking at age 4 with 69 average breakdowns.
Age 5-7: The trend remains high, with averages between 51 and 67.
Age 8: Breakdowns start to decline, averaging 40.
Age 24: Machines at this age see significantly fewer breakdowns, averaging 23.

This pattern suggests that machines are most prone to breakdowns between 2-7 years of age.
*/

/* 
Note:
We did not group the age into buckets like 0-1 year, 1-2 years, etc., because it can potentially throw off the results, 
especially for the average number of breakdowns per machine. This is because the average will be calculated for each bucket as a whole, 
rather than reflecting the precise age of each individual machine. 
The broader the bucket, the more generalized and potentially misleading the results might be.
*/




/*
Question:
Determine the top five machines with the highest frequency of breakdowns and analyze the corresponding downtime associated with each.
*/
with total_breakdowns as 
(
select 
	machine_number,
	count(breakdown_id) as number_of_breakdowns
from 
	breakdown_data
where
	machine_active = 1 -- excluding deactivated machines
group by
	machine_number
)
select top 5
	machine_number,
	number_of_breakdowns
from 
	total_breakdowns
order by
	number_of_breakdowns desc

/*
Here’s a brief breakdown of the results:
We could not use the sum(datediff(hour, request_created_time, request_fixed_date)) approach 
for calculating downtime due to invalid dates (e.g., year 1899) 
in the 'request_created_time' and 'request_fixed_date' columns, which rendered the calculations inaccurate. 
Instead, we focused on counting the number of breakdowns per machine. 
This method avoids complications related to erroneous dates and provides a clear, 
actionable metric for identifying the top breakdown-prone machines. 
By analyzing breakdown counts, we ensure the results remain reliable and relevant despite data quality issues.
*/




/*
Question:
Determine the pattern of cost impacts resulting from machine breakdowns across different states.
*/
select 
	state,
	count(distinct machine_number) as count_of_machines,
	round(sum(case when quotation_approval_status = 'APPROVED' then amt_based_on_quotation else 0 end), 0) as total_cost
from 
	breakdown_data
where 
	machine_active = 1 -- excluding deactivated machines
and
	commencement_date is not null -- helps us achieve more meaningful and accurate cost analysis
and	
	commencement_date >= dateadd(year, -5, '2025-01-01') -- considering the years 2020,2021,2022,2023,2024 to have a balanced perspective
group by
	state
order by
	total_cost desc

/*
Here’s a brief breakdown of the results:
From 2020 to 2024, Punjab and Haryana, with 363 and 349 machines respectively, led in total breakdown costs, each exceeding ₹3 crores. 
Gujarat, Rajasthan, and Madhya Pradesh followed, with costs ranging from ₹1.09 to ₹1.60 crores. 
States with fewer machines, like Andhra Pradesh, Telangana, and Maharashtra, showed lower costs, while smaller states had minimal expenses. 
This analysis highlights the correlation between machine density and the financial impact of breakdowns across states.
/*




*/
Question:
Evaluate the influence of machine location on the frequency of breakdowns.
*/
select
	state,
	count(distinct machine_number) as machine_count,
	count(breakdown_id) as breakdown_counts,
	round(sum(case when quotation_approval_status = 'APPROVED' then amt_based_on_quotation else 0 end), 0) as total_cost,
	avg(datediff(day, commencement_date, getdate())) as avg_age_of_machine_in_days
from 
	breakdown_data
where
	machine_active = 1 -- excluding deactivated machines
and 
	commencement_date is not null
group by
	state
order by
	breakdown_counts desc

/*
Here’s a brief breakdown of the results:
Rajasthan, Haryana, and Punjab have the highest breakdown counts and costs, with machines averaging 4-5 years old. 
Gujarat and Madhya Pradesh also show significant costs, with slightly newer machines. 
Maharashtra has many machines but lower costs, despite an average machine age of 5 years. 
Andhra Pradesh and Telangana follow with moderate costs. 
Karnataka, Andaman and Nicobar Islands, Uttar Pradesh, and Jammu and Kashmir have the fewest breakdowns and costs, 
with fewer and generally newer machines.
*/




/*
Question:
Compare the breakdown frequency of machines that have undergone preventive maintenance with those that have not, 
in order to assess the impact of maintenance on machine reliability.
*/

-- total count of breakdowns after maintenance V/S total count of breakdowns before maintenance
select 
	count(case when maintenance_status = 'COMPLETED' then breakdown_id else null end) as breakdowns_after_maintenance,
	count(case when maintenance_status != 'COMPLETED' then breakdown_id else null end) as breakdowns_before_maintenance
from 
	breakdown_data


with machine_breakdowns as 
(
select 
	machine_number,
	case when maintenance_status = 'COMPLETED' then 'with_maintenance' else 'without_maintenance' end as maintenance_detail,
	count(breakdown_id) as breakdown_counts,
	round(sum(case when quotation_approval_status = 'APPROVED' then amt_based_on_quotation else 0 end), 0) as total_cost 
from 
	breakdown_data
group by
	machine_number,
	case when maintenance_status = 'COMPLETED' then 'with_maintenance' else 'without_maintenance' end 
)
select 
	maintenance_detail,
	count(distinct machine_number) as machine_count,
	sum(breakdown_counts) as total_breakdowns,
	sum(total_cost) as total_cost
from 
	machine_breakdowns
group by
	maintenance_detail

/*
Note: sum(breakdown_counts) is used in the main query to aggregate the total number of breakdowns across all machines within 
each maintenance category, ensuring that the total breakdowns are accurately reflected, rather than just counting the rows or machines.
*/

/*
Here’s a brief breakdown of the results:
Machines without preventive maintenance experienced more breakdowns (114,358) and incurred higher costs (₹17.1 crores) 
compared to those with maintenance (64,105 breakdowns, ₹10.9 crores). 
The data highlights the effectiveness of preventive maintenance in reducing both breakdown frequency and associated costs.
*/




