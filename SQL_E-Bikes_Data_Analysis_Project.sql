use Lukas_SQL


-- Accessing core datasets
select * from rides
select * from stations
select * from users


-- Understanding dataset size
select count(*) as total_rides from rides
select count(*) as total_stations from stations
select count(*) as total_users from users


-- Checking for NULLs in critical ride fields
select
	count(case when ride_id is null then 1 else null end) as null_ride_ids,
	count(case when [user_id] is null then 1 else null end) as null_user_ids,
	count(case when start_time is null then 1 else null end) as null_start_time,
	count(case when end_time is null then 1 else null end) as null_end_time
from
	rides


-- Summary Statistics
select distinct
	round(PERCENTILE_CONT(0.5) within group (order by distance_km) over(),2) as median,
	round(min(distance_km) over(),2) as min_dist,
	round(max(distance_km) over(),2) as max_dist,
	round(avg(distance_km) over(),2) as avg_dist,
	round(min(datediff(MINUTE,start_time,end_time)) over(),2) as min_duration_mins,
	round(max(datediff(MINUTE,start_time,end_time)) over(),2) as max_duration_mins,
	round(avg(datediff(MINUTE,start_time,end_time)) over(),2) as avg_duration_mins
from
	rides

/*
Insight:
Zero-distance and zero-duration rides likely represent false starts or lock/unlock behavior and should be excluded from deeper analysis.
*/


-- Identifying False or Invalid Rides
select
	count(case when datediff(minute,start_time,end_time) < 2 then 1 else null end) as short_duration_trips,
	count(case when distance_km = 0 then 1 else null end) as zero_distance_trips
from
	rides


-- Ride Analysis by Membership Level
select
	b.membership_level,
	count(a.ride_id) as total_rides,
	round(avg(a.distance_km),2) as avg_distance_km,
	round(avg(datediff(minute, a.start_time, a.end_time)),2) as avg_duration_mins
from
	rides as a
join
	users as b
on
	a.[user_id] = b.[user_id]
group by
	b.membership_level
order by
	total_rides desc


-- Peak Usage Hours
select
	DATEPART(hour,start_time) as hour_of_day,
	count(ride_id) as ride_count
from
	rides
group by
	DATEPART(hour,start_time)
order by
	hour_of_day


-- Most Popular Start Stations
select top 10
	b.station_name,
	count(a.ride_id) as total_starts
from
	rides as a
join
	stations as b
on
	a.start_station_id = b.station_id
group by
	b.station_name
order by
	total_starts desc


-- Ride Duration Segmentation
select
	
	case
	when datediff(minute, start_time, end_time) < 10 then '1. Short (<10M)'
	when datediff(minute, start_time, end_time) between 10 and 30 then '2. Medium (11-30M)'
	else '3. Long (>30M)'
	end as ride_category,

	count(ride_id) as ride_cnts
from
	rides
group by	
	case
	when datediff(minute, start_time, end_time) < 10 then '1. Short (<10M)'
	when datediff(minute, start_time, end_time) between 10 and 30 then '2. Medium (11-30M)'
	else '3. Long (>30M)'
	end
order by
	ride_category


-- Station Net Flow Analysis
with total_departures as

(select distinct
	start_station_id,
	count(ride_id) over(partition by start_station_id) as total_departure_cnt
from
	rides),

total_arrivals as

(select distinct
	end_station_id,
	count(ride_id) over(partition by end_station_id) as total_arrival_cnt
from
	rides)

select
	a.station_name,
	total_departure_cnt,
	total_arrival_cnt,
	(total_arrival_cnt - total_departure_cnt) as net_flow
from
	stations as a
join
	total_departures as b
on
	a.station_id = b.start_station_id
join
	total_arrivals as c
on
	a.station_id = c.end_station_id
order by
	net_flow


-- User Growth & Retention Analysis
with monthly_signups as

(select
	format(created_at, 'yyyy-MM') as signup_month,
	count([user_id]) as new_user_cnt
from
	users
group by
	format(created_at, 'yyyy-MM'))

select
	signup_month,
	new_user_cnt,
	coalesce(lag(new_user_cnt) over(order by signup_month),0) as previous_month_cnt,
	
	case
	when coalesce(lag(new_user_cnt) over(order by signup_month),0) = 0 then 0
	
	else
	(100 *
	(new_user_cnt - coalesce(lag(new_user_cnt) over(order by signup_month),0)))
	/ 
	coalesce(lag(new_user_cnt) over(order by signup_month),0)
	end as mom_growth
from
	monthly_signups