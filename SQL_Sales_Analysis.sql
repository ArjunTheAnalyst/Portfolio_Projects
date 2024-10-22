use Placement_Project

select * from Orders
select * from Returns

/* 
Question:
Find the top 5 customers with the highest lifetime value (LTV), where LTV is calculated as the sum of their 
profits divided by the number of years they have been customer 
*/

with total_profits as
(select
	[Customer ID],
	[Customer Name],
	sum(Profit) as total_profit
from
	Orders as a
left join
	Returns as b
on
	a.[Order ID] = b.[Order ID]
where
	b.[Order ID] is null /* left join returns only matching rows from 'Returns' table, if an order was not returned, the column will be null */
group by
	[Customer ID],
	[Customer Name]),
number_of_years as
(select
	[Customer ID],
	[Customer Name],
	datediff(year, min([Order Date]), max([Order Date]) + 1) as total_years /* + 1 was added to include starting year  */
from
	Orders
group by
	[Customer ID],
	[Customer Name]),
life_time_value as
(select
	c.[Customer ID],
	c.[Customer Name],
	case when total_years = 0 then 0 
	else
	(total_profit / total_years) end as LTV /* we used a case statement because we were encountering a divide by zero error */
from
	total_profits as c
join
	number_of_years as d /* used inner join to only get customers with both 'total_profit' and 'total_years' */
on
	c.[Customer ID] = d.[Customer ID]
and
	c.[Customer Name] = d.[Customer Name])
select top 5
	[Customer ID],
	[Customer Name],
	round(LTV, 2) as LTV
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

with sales_cte as 
(select
	Category,
	[Sub-Category],
	sum(Sales) as total_sales
from 
	Orders
group by
	Category,
	[Sub-Category])
select
	Category,
	coalesce(Supplies, 0) as Supplies, 
	coalesce(Storage, 0) as Storage, 
	coalesce(Phones, 0) as Phones, 
	coalesce(Fasteners, 0) as Fasteners, 
	coalesce(Copiers, 0) as Copiers, 
	coalesce(Chairs, 0) as Chairs, 
	coalesce(Bookcases, 0) as Bookcases, 
	coalesce(Machines, 0) as Machines, 
	coalesce(Art, 0) as Art, 
	coalesce(Envelopes, 0) as Envelopes, 
	coalesce(Binders, 0) as Binders, 
	coalesce(Labels, 0) as Labels, 
	coalesce(Furnishings, 0) as Furnishings, 
	coalesce(Accessories, 0) as Accessories, 
	coalesce(Appliances, 0) as Appliances, 
	coalesce(Paper, 0) as Paper, 
	coalesce(Tables, 0) as Tables
from
	sales_cte
pivot(
	sum(total_sales)
for 
	[Sub-Category] in 
	(Supplies, Storage, Phones, Fasteners, Copiers, Chairs, Bookcases, Machines, Art, Envelopes, Binders, Labels, 
	Furnishings, Accessories, Appliances, Paper, Tables)
	) as pivot_table

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

with total_orders as 
(select
	[Customer ID],
	[Customer Name],
	Category,
	count([Order ID]) as order_count
from
	Orders
group by
	[Customer ID],
	[Customer Name],
	Category),
max_orders as
(select
	Category,
	max(order_count) as max_order_count
from
	total_orders
group by
	Category)
select
	a.[Customer ID],
	a.[Customer Name],
	a.Category,
	max_order_count
from
	total_orders as a
join
	max_orders as b
on
	a.Category = b.Category
and
	order_count = max_order_count
order by
	max_order_count desc

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
(select
	[Product ID],
	[Product Name],
	Category,
	sum(Sales) as total_sales
from
	Orders
group by
	[Product ID],
	[Product Name],
	Category),
top_3_products as 
(select
	*,
	--[Product ID],
	--[Product Name],
	--Category,
	--total_sales
	row_number() over(partition by Category order by total_sales desc) as rn
from 
	sales_total)
select
	[Product ID],
	[Product Name],
	Category,
	total_sales
from 
	top_3_products
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

drop function if exists dbo.days_between_dates

--creating a user defined function
create function dbo.days_between_dates
(@start_date date, 
 @end_date date) --defining parameters
returns int 
as 
begin 
	return datediff(day, @start_date, @end_date)
end


drop procedure if exists get_customer_orders 

-- creating a stored procedure 
create procedure get_customer_orders 
	@Customer_ID nvarchar(10)
as
begin
	with customer_orders as 
	(select
		[Order Date],
		Sales as total_amount,
		Profit,
		row_number() over(order by [Order Date] desc) as order_rank, --will be useful when we filter only to get the latest order
		count([Order ID]) over() as total_orders,
		avg(Sales) over() as avg_sales,
		max([Order Date]) over() as last_order_date,
		dbo.days_between_dates(max([Order Date]) over(), getdate()) as days_since_last_order
	from 
		Orders
	where
		[Customer ID] = @Customer_ID) --only orders belonging to specific customers are considered for calculations
	select
		[Order Date],
		total_amount,
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

-- executing the procedure
exec get_customer_orders @Customer_ID = 'JL-15235' 

/*
Breakdown:
We created a function dbo.days_between_dates that calculates the number of days between two dates. 
Following that, we developed a stored procedure called get_customer_orders to retrieve and analyze order information for a specific customer. 
The procedure calculates key metrics like the total number of orders, average sales, and the number of days since the customer's last order.

When executed, the stored procedure returns details about the customer's most recent order, including the order date, total amount, profit, 
and additional metrics.
*/

