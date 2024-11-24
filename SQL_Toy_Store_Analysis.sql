use Placement_Project

select * from sales
select * from inventory
select * from products
select * from stores


/* DATA CLEANING */

--checking the datatype of 'Date' column in 'sales' table
select column_name, data_type
from information_schema.columns
where table_name = 'sales' and column_name = 'Date'

--checking the datatype of 'Stock_Open_Date' column in 'stores' table
select column_name, data_type
from information_schema.columns
where table_name = 'stores' and column_name = 'Store_Open_Date'

-- altering the Date column
alter table sales
alter column [Date] date

-- altering the Store_Open_Date column
alter table stores
alter column Store_Open_Date date

--checking for non-integer values before conversion to int datatype in 'sales' table 
select *
from sales
where 
	Sale_ID <> FLOOR(Sale_ID)
 or Store_ID <> FLOOR(Store_ID)
 or Product_ID <> FLOOR(Product_ID)
 or Units <> FLOOR(Units) 
 /* The FLOOR() function returns the integer less than or equal to the given number, 
 the query checks if the original sale_id, store_id, product_id and units are NOT equal to their floored (whole number) versions.
 If the original value is different from its whole number version, it means the value has decimals.*/

--altering datatype of columns in 'sales' table
alter table sales
alter column Sale_ID int

alter table sales
alter column Store_ID int

alter table sales
alter column Product_ID int

alter table sales
alter column Units int


--checking for non-integer values before conversion to int datatype in 'inventory' table 
select *
from inventory
where 
	Store_ID <> FLOOR(Store_ID)
 or Product_ID <> FLOOR(Product_ID)
 or Stock_On_Hand <> FLOOR(Stock_On_Hand)

--altering datatype of columns in 'inventory' table from float to int
alter table inventory
alter column Store_ID int

alter table inventory
alter column Product_ID int

alter table inventory
alter column Stock_On_Hand int


--replacing '$' in 'Product_Cost' of 'products' table with ''
update products
set Product_Cost = REPLACE(Product_Cost, '$', '')

alter table products
alter column Product_Cost decimal(10, 2)


--replacing '$' in 'Product_Price' of 'products' table with ''
update products
set Product_Price = REPLACE(Product_Price, '$', '')

alter table products
alter column Product_Price decimal(10, 2)

--altering datatype of columns in 'products' table from float to int
alter table products
alter column Product_ID int


--altering datatype of columns in 'products' table from float to int
alter table stores
alter column Store_ID int




/* DATA ANALYSIS */
select * from sales
select * from inventory
select * from products
select * from stores


/*
Question 1:
Write an SQL query to compare monthly and quarterly sales performance for the years 2022 and 2023. 
The query should return the total units sold for each store, city, and location, categorized by "Monthly" and "Quarterly" periods. 
Include the year, month or quarter, store name, city, location, and total units sold. 
*/
-- monthly sales
select 
	'Monthly' as Period_Type,
	YEAR(a.Date) as [Year],
	MONTH(a.Date) as [Month / Quarter],
	b.Store_Name,
	b.Store_City,
	b.Store_Location,
	SUM(a.Units) as total_units_sold
from 
	sales as a
join
	stores as b
on
	a.Store_ID = b.Store_ID
where 
	YEAR(a.Date) in (2022, 2023)
group by
	YEAR(a.Date),
	MONTH(a.Date),
	b.Store_Name,
	b.Store_City,
	b.Store_Location

union all

--quartely sales 
select 
	'Quarterly' as Period_Type,
	YEAR(a.Date) as [Year],
	DATEPART(QUARTER, a.Date) as [Quarter],
	b.Store_Name,
	b.Store_City,
	b.Store_Location,
	SUM(a.Units) as total_units_sold
from 
	sales as a
join
	stores as b
on
	a.Store_ID = b.Store_ID
where 
	YEAR(a.Date) in (2022, 2023)
group by
	YEAR(a.Date),
	DATEPART(QUARTER, a.Date),
	b.Store_Name,
	b.Store_City,
	b.Store_Location


/*
Question 2:
Identify the top 5 and bottom 5 stores based on their sales performance in 2023.
*/
with store_sales as 
(select 
	YEAR(a.Date) as sales_year,
	b.Store_ID,
	b.Store_Name,
	b.Store_City,
	b.Store_Location,
	SUM(a.Units) as total_units_sold
from 
	sales as a 
join
	stores as b
on
	a.Store_ID = b.Store_ID 
group by
	YEAR(a.Date),
	b.Store_ID,
	b.Store_Name,
	b.Store_City,
	b.Store_Location),
ranked_stores as 
(select
	sales_year,
	Store_ID,
	Store_Name,
	Store_City,
	Store_Location,
	total_units_sold,
	RANK() OVER(PARTITION BY sales_year order by total_units_sold desc) as Rank_High,
	RANK() OVER(PARTITION BY sales_year order by total_units_sold asc) as Rank_Low
from
	store_sales)
select 
	sales_year,
	Store_ID,
	Store_Name,
	Store_City,
	Store_Location,
	total_units_sold,
	'Top 5' as Category
from 
	ranked_stores 
where	
	Rank_High <= 5

union all

select 
	sales_year,
	Store_ID,
	Store_Name,
	Store_City,
	Store_Location,
	total_units_sold,
	'Bottom 5' as Category
from 
	ranked_stores
where
	Rank_Low <= 5


/*
Question 3:
Compare the sales performance of stores between 2023 and 2022, considering cases where there were no sales in 2022.
*/
with store_sales as 
(select
	YEAR(a.Date) as sales_year,
	b.Store_ID,
	b.Store_Name,
	b.Store_City,
	b.Store_Location,
	SUM(a.Units) as total_units_sold
from 
	sales as a 
join
	stores as b
on
	a.Store_ID = b.Store_ID 
where
	YEAR(a.Date) in (2022, 2023)
group by	
	YEAR(a.Date),
	b.Store_ID,
	b.Store_Name,
	b.Store_City,
	b.Store_Location),
performance_comparison as
(select
	c.Store_ID,
	c.Store_Name,
	c.Store_City,
	c.Store_Location,
	c.total_units_sold as Units_Sold_2023,
	coalesce(d.total_units_sold, 0) as Units_Sold_2022,
	(c.total_units_sold - coalesce(d.total_units_sold, 0)) as sales_difference
from 
	store_sales as c
left join 
	store_sales as d
on
	c.Store_ID = d.Store_ID -- both rows must belong to the same store (c.Store_ID = d.Store_ID)
and
	c.sales_year = 2023 -- the left-side row (c) must correspond to 2023
and
	d.sales_year = 2022) -- the right-side row (d) must correspond to 2022
select
	2023 as sales_year,
	Store_ID,
	Store_Name,
	Store_City,
	Store_Location,
	Units_Sold_2023,
	'Improved' as Category
from 
	performance_comparison 
where
	sales_difference > 0
/*
Notes: 
The LEFT JOIN makes sure all the 2023 data appears, even if there's no matching 2022 data for the same store. 
So, for each store, you'll see the 2023 sales, and if the store didn't have sales in 2022, it will show as empty (NULL). 
The conditions a.sales_year = 2023 and b.sales_year = 2022 make sure you're comparing the right years.
*/


/*
Question 4:
Which product had the highest total sales in the entire dataset, and what were its total units sold and sales value?
*/
select top 1
	b.Product_ID,
	b.Product_Name,
	SUM(a.Units) as total_units_sold,
	ROUND(SUM(a.Units * b.Product_Price), 0) as total_sales 
from 
	sales as a 
join
	products as b
on
	a.Product_ID = b.Product_ID
group by
	b.Product_ID,
	b.Product_Name
order by 
	total_sales desc

/*
Question 5:
How does the sales performance of each product compare across different half-year periods (H1 and H2) in the last 18 months?
*/
select 
	b.Product_ID,
	YEAR(a.Date) as sales_year,
	case when MONTH(a.Date) <= 6 then 'H1' else 'H2' end as Half_Year, -- H1 is first half and H2 is second half
	SUM(a.Units) as total_units_sold,
	ROUND(SUM(a.Units * b.Product_Price), 0) as total_sales 
from 
	sales as a 
join 
	products as b
on
	a.Product_ID = b.Product_ID
where
	a.Date > DATEADD(MONTH, -18, (select MAX(Date) from sales)) --include sales only for the last 3 half years (18 months), max(date) is most recent date 
group by
	b.Product_ID,
	YEAR(a.Date),
	case when MONTH(a.Date) <= 6 then 'H1' else 'H2' end
order by
	sales_year,
	Half_Year


/*
Question 6:
Which product had the highest total units sold across the entire dataset, and how do the total units sold compare to other products?
*/
select top 1
	b.Product_ID,
	b.Product_Name,
	SUM(a.Units) as total_units_sold
from 
	sales as a 
join
	products as b
on
	a.Product_ID = b.Product_ID
group by
	b.Product_ID,
	b.Product_Name
order by 
	total_units_sold desc


/*
Question 7:
Calculate the average inventory for each store and product combination.
*/
select 
	Store_ID,
	Product_ID,
	AVG(Stock_On_Hand) as avg_inventory
from 
	inventory 
group by
	Store_ID,
	Product_ID


/*
Question 8:
Generate a comparative report of the inventory turnover ratio alongside the average inventory, grouped by store and product.
*/
with average_inventory as 
(select 
	Store_ID,
	Product_ID,
	AVG(Stock_On_Hand) as avg_inventory
from 
	inventory 
group by
	Store_ID,
	Product_ID),
store_sales as 
(select
	a.Store_ID,
	b.Product_ID,
	ROUND(SUM(a.Units * b.Product_Price), 0) as total_sales,
	SUM(a.Units) as total_units_sold
from 
	sales as a 
join
	products as b
on
	a.Product_ID = b.Product_ID
group by
	a.Store_ID,
	b.Product_ID)	
select
	c.Store_ID,
	c.Product_ID,
	total_sales,
	avg_inventory,
	case when avg_inventory = 0 then 0 
	else ROUND((total_sales / avg_inventory), 0) end as inventory_turnover_ratio
from 
	average_inventory as c
left join
	store_sales as d
on
	c.Store_ID = d.Store_ID
and 
	c.Product_ID = d.Product_ID
/*
Notes:
1. Inventory Turnover Ratio = Total Sales / Average Inventory
2. If Avg_Inventory is 0, the ratio is set to 0 (since you can't have a turnover ratio with no inventory)
3. Higher the ratio, the better 
*/
