use Placement_Project

select * from Orders
select * from Returns

/* 
Question:
Find the top 5 customers with the highest lifetime value (LTV), where LTV is calculated as the sum of their 
profits divided by the number of years they have been customer 
*/
with total_profits as 
(
select 
	a.[Customer ID], 
	a.[Customer Name],
	sum(a.Profit) as total_profit
from 
	Orders as a
left join
	Returns as b
on
	a.[Order ID] = b.[Order ID]
where
	b.[Order ID] is null /* left join returns only matching rows from 'Returns' table, if an order was not returned, the column will be null */
group by
	a.[Customer ID], 
	a.[Customer Name] /* used brackets around column names to handle space */
),
number_of_years as
(
select 
	[Customer ID],
	[Customer Name],
	datediff(year, min([Order Date]), max([Order Date]) + 1) as total_years /* +1 was added to include starting year  */
from 
	Orders
group by
	[Customer ID],
	[Customer Name]
),
life_time_value as
(
select 
	c.[Customer ID],
	c.[Customer Name],
	case when d.total_years = 0 then 0 
	else c.total_profit / d.total_years 
	end as LTV /* we used a case statement because we were encountering divide by zero error */
from 
	total_profits as c
join
	number_of_years as d /* used inner join to only get customers with both 'total_profit' and 'total_years' */
on
	c.[Customer ID] = d.[Customer ID] 
and
	c.[Customer Name] = d.[Customer Name] 
)
select top 5
	[Customer ID],
	[Customer Name],
	LTV
from
	life_time_value
order by
	LTV desc

/*
Breakdown:
The results highlight the lifetime value of the top 5 customers. Tamara Chand has the highest lifetime value at 4,499.32, 
followed by Christopher Conant at 2,177.05. Christopher Martinez and Sanjit Chand have lifetime values of 1,949.95 and 1,877.21, respectively.
Hunter Lopez is close behind with a value of 1,874.14. This analysis underscores the significant contributions of these customers over time.
*/




/*
Question:
Create a pivot table to show total sales by product category and sub-category
*/
select distinct Category from Orders
select distinct [Sub-Category] from Orders

select 
	Category,
	coalesce(Art, 0) as Art,
	coalesce(Chairs, 0) as Chairs,
	coalesce(Fasteners, 0) as Fasteners,
	coalesce(Envelopes, 0) as Envelopes,
    coalesce(Supplies, 0) as Supplies,
    coalesce(Copiers, 0) as Copiers,
    coalesce(Labels, 0) as Labels,
    coalesce(Binders, 0) as Binders,
    coalesce(Storage, 0) as Storage,
    coalesce(Machines, 0) as Machines,
    coalesce(Bookcases, 0) as Bookcases,
    coalesce(Accessories, 0) as Accessories,
    coalesce(Paper, 0) as Paper,
    coalesce(Appliances, 0) as Appliances,
    coalesce(Phones, 0) as Phones,
    coalesce(Tables, 0) as Tables
from
(
select 
	Category,
	[Sub-Category],
	sum(Sales) as total_sales
from 
	Orders
group by
	Category,
	[Sub-Category]
) as data_for_pivot
pivot (
	sum(total_sales)
	for [Sub-Category] in (Art, Chairs, Fasteners, Furnishings, Envelopes, Supplies, Copiers, Labels, Binders, Storage, Machines, 
	Bookcases, Accessories, Paper, Appliances, Phones, Tables)) as pivot_table

/*
Breakdown:
-- Furniture: Significant sales are observed in Chairs, Bookcases, and Tables.
-- Office Supplies: Major sales come from Supplies, Binders, Storage, and Paper, with notable contributions from Envelopes and Labels.
-- Technology: Prominent sales in Supplies, Machines, Accessories, and Phones, with additional sales in Paper and Copiers.
*/




/*
Question:
Find the customer who has made the maximum number of orders in each category
*/
with order_count as 
(
select 
	[Customer ID],
	[Customer Name],
	Category,
	count([Order ID]) as order_count
from 
	Orders	
group by
	[Customer ID],
	[Customer Name],
	Category
), maximum_orders as
(
select 
	Category,
	max(order_count) as max_order_count
from 
	order_count
group by
	Category
)
select 
	a.[Customer ID],
	a.[Customer Name],
	b.Category,
	b.max_order_count
from 
	order_count as a
join
	maximum_orders as b
on 
	a.Category = b.Category
and 
	a.order_count = b.max_order_count
order by
	b.max_order_count desc

/*
Breakdown:
-- Office Supplies: Edward Hooks has the highest number of orders with a total of 26.
-- Furniture: Seth Vernon leads in orders with 15.
-- Technology: Laura Armstrong tops the list with 9 orders.
*/




/* 
Question:
Find the top 3 products in each category based on their sales
*/
with sales_total as
(
select 
	Category,
	[Product ID],
	[Product Name],
	sum(Sales) as total_sales
from	
	Orders
group by
	Category,
	[Product ID],
	[Product Name]
), ranks as 
(
select *,
	--Category,
	--[Product ID],
	--[Product Name],
	--total_sales,
	row_number() over(partition by Category order by total_sales desc) as rn
from 
	sales_total
)
select 
	Category,
	[Product ID],
	[Product Name],
	total_sales
from 
	ranks
where 
	rn <= 3
order by
	Category

/*
Breakdown:
Furniture:
-- The HON 5400 Series Task Chairs for Big and Tall tops the list with $21,870.58 in sales.
-- The Riverside Palais Royal Lawyers Bookcase follows with $15,610.97.
-- The Bretford Rectangular Conference Table Tops ranks third with $12,995.29.

Office Supplies:
-- The Fellowes PB500 Electric Punch Plastic Comb Binding Machine leads with $27,453.38.
-- The GBC DocuBind TL300 Electric Binding System is next at $19,823.48.
-- The GBC Ibimaster 500 Manual ProClick Binding System comes third with $19,024.50.

Technology:
-- The Canon imageCLASS 2200 Advanced Copier has the highest sales at $61,599.82.
-- The Cisco TelePresence System EX90 Videoconferencing Unit follows with $22,638.48.
-- The Hewlett Packard LaserJet 3310 Copier rounds out the top three with $18,839.69.
*/
	



/*
Question:
In the table Orders with columns OrderID, CustomerID, OrderDate, TotalAmount. 
You need to create a stored procedure Get_Customer_Orders that takes a CustomerID as input and returns a table with the following columns, 
you will need to create a function also that calculates the number of days between two dates.  
1. OrderDate
2. TotalAmount
3. TotalOrders: The total number of orders made by the customer.
4. AvgAmount: The average total amount of orders made by the customer.
5. LastOrderDate: The date of the customer's most recent order.
6. DaysSinceLastOrder: The number of days since the customer's most recent order. 
*/

--creating a user defined function
drop function if exists dbo.days_between_dates

create function dbo.days_between_dates
(
	@start_date date, --defining parameters
	@end_date date
)
returns int 
as 
begin 
	return datediff(day, @start_date, @end_date)
end
go

--creating a stored procedure
drop procedure if exists get_customer_orders

create procedure get_customer_orders
	@Customer_ID nvarchar(255)
as
begin
	set nocount on; -- to make the code run faster and ensure it is terminated with a semicolon

	with customer_orders as 
	(select 
		[Order Date],
		Sales,
		Profit,
		row_number() over(order by [Order Date] desc) as order_rank, --will be useful when we filter only to get the latest order
		count([Order ID]) over() as total_orders,
		avg(cast(Sales as float)) over() as avg_sales,
		max([Order Date]) over() as last_order_date,
		dbo.days_between_dates(max([Order Date]) over(), getdate()) as days_since_last_order
	from
		Orders
	where [Customer ID] = @Customer_ID --only orders belonging to specific customers are considered for calculations
	) 
	select 
		[Order Date],
		Sales as total_amount,
		Profit,
		total_orders,
		avg_sales,
		last_order_date,
		days_since_last_order
	from 
		customer_orders
	where 
		order_rank = 1
	end
	go

--executing the procedure
declare @Customer_ID nvarchar(255) 
set @Customer_ID = 'JL-15235' --example
exec get_customer_orders @Customer_ID
	 
/*
Breakdown:
We created a function dbo.days_between_dates that calculates the number of days between two dates. 
Following that, we developed a stored procedure called get_customer_orders to retrieve and analyze order information for a specific customer. 
The procedure calculates key metrics like the total number of orders, average sales, and the number of days since the customer's last order.

When executed, the stored procedure returns details about the customer's most recent order, including the order date, total amount, profit, 
and additional metrics.
*/

