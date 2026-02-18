-- creating a database
create database dcluttr

-- accessing the database
use dcluttr

/*
You are provided with three tables: raw_file, cities, and categories.
Write a complete SQL script that:
1. Creates a view named inventory_details.
2. Uses appropriate CTEs and window functions to estimate daily quantity sold for each SKU.
3. Aggregates the estimated sales at the city, category, and sub-category level.
4. Stores the final aggregated output in a new table named blinkit_city_insights.
*/

-- accessing the tables
select * from raw_file
select * from cities
select * from categories

drop view if exists inventory_details

create view inventory_details as
(select
	a.store_id,
	a.sku_id,
	a.l1_category_id as category_id,
	c.l1_category as category,
	a.l2_category_id as sub_category_id,
	c.l2_category as [sub-category],
	a.inventory,
	cast(a.created_at as date) as order_date,
	b.city_name as city
from
	raw_file as a
join
	cities as b
on
	a.store_id = b.store_id
join
	categories as c
on
	a.l1_category_id = c.l1_category_id
and
	a.l2_category_id = c.l2_category_id)

--accessing the view
select
	*
from
	inventory_details

with inventory_history as
(select
	store_id,
	sku_id,
	category_id,
	category,
	sub_category_id,
	[sub-category],
	inventory,
	coalesce(lag(inventory) over(partition by store_id, sku_id order by order_date),0) as previous_inventory,
	order_date,
	city	
from
	inventory_details),

estimated_sales as
(select
	*,
	case
	when previous_inventory = 0 then 0
	when previous_inventory > inventory then previous_inventory - inventory -- sales have occurred
	when previous_inventory < inventory 
	then
	coalesce(
	avg(case when previous_inventory > inventory then previous_inventory - inventory end)
	over(partition by store_id, sku_id order by order_date rows between unbounded preceding and 1 preceding),
	0)
	else 0
	end as estimated_quantity_sold
-- if previous_inventory < inventory then restock has taken place, estimating sales by using historical average of previous decrements
from
	inventory_history)

select
	city,
	category_id,
	category,
	sub_category_id,
	[sub-category],
	sum(estimated_quantity_sold) as est_qty_sold
into blinkit_city_insights
from
	estimated_sales
group by
	city,
	category_id,
	category,
	sub_category_id,
	[sub-category]
order by
	city,
	category,
	[sub-category]

drop table if exists blinkit_city_insights

-- accessing the output
select 
	* 
from 
	blinkit_city_insights
order by
	est_qty_sold desc