use [Contoso V2 100K]

select * from Sales
select * from Store
select * from [Product]
select * from Customer
select * from [Date]
select * from [Currency Exchange]

/*
Question: VIEW CREATION
Write an SQL query to create a view named customer_summary that shows each customer’s ID, name, country, total orders, 
total revenue (Quantity * NetPrice), and earliest purchase date from the Sales and Customer tables.
*/
drop view cohort_analysis

create view cohort_analysis as
select distinct
	a.CustomerKey,
	b.[Name],
	b.Country,
	a.[Order Date],
	count(a.[Order Number]) over(partition by a.CustomerKey) as Total_Orders,
	round(sum((a.[Net Price] * a.Quantity) / a.[Exchange Rate]) over(partition by a.CustomerKey),0) as Total_Revenue,
	min(a.[Order Date]) over(partition by a.CustomerKey) as First_Purchase_Date,
	year(min(a.[Order Date]) over(partition by a.CustomerKey)) as Cohort_Year
from
	Sales as a
left join
	Customer as b
on
	a.CustomerKey = b.CustomerKey

--accessing the view
select * from cohort_analysis


/*
Question: CUSTOMER SEGMENTATION
Segment customers by lifetime value (LTV) into Low, Medium, and High segments using the 25th and 75th percentiles, and show for each segment: 
total LTV, customer count, and average LTV.
*/
with customer_ltv as
(select distinct
	CustomerKey,
	[Name],
	sum(Total_Revenue) over(partition by CustomerKey) as LTV
from
	cohort_analysis),

customer_segments as
(select distinct
	PERCENTILE_CONT(0.25) within group (order by LTV) over() as [25th_Percentile],
	PERCENTILE_CONT(0.75) within group (order by LTV) over() as [75th_Percentile]
from
	customer_ltv),

segment_values as
(select
	a.*,
	case
	when LTV < [25th_Percentile] then '1 - LOW_VALUE'
	when LTV > [75th_Percentile] then '3 - HIGH_VALUE'
	else '2 - MEDIUM_VALUE'
	end as Customer_Segment
from
	customer_ltv as a
cross join
	customer_segments)

select
	Customer_Segment,
	sum(LTV) as Total_LTV,
	count(distinct CustomerKey) as Customer_Cnt, -- using distinct to maintain caution
	round(avg(LTV),0) as Average_LTV
from
	segment_values
group by
	Customer_Segment
order by
	Customer_Segment


/*
COHORT ANALYSIS
Question 1 – Customer Revenue by Cohort (NOT adjusted for time in market):
Analyze the query that calculates metrics for each cohort_year. What does SUM(total_net_revenue) / COUNT(DISTINCT customerkey) represent?
*/
select
	Cohort_Year,
	count(distinct CustomerKey) as Customer_Cnt,
	sum(Total_Revenue) as Revenue_Total,
	round(sum(Total_Revenue) / count(distinct CustomerKey),0) as Revenue_per_Customer
from
	cohort_analysis
group by
	Cohort_Year
order by
	Cohort_Year

/*
Question 2 – Customer Revenue by Cohort (Adjusted for time in market):
Examine the query using days_since_first_purchase. What does cumulative_percentage_of_total_revenue represent?
*/
with purchase_days as
(select
	CustomerKey,
	Total_Revenue,
	DATEDIFF(day, min([Order Date]) over(partition by CustomerKey), [Order Date]) as Days_Since_First_Purchase 
from
	cohort_analysis),

daily_revenue as
(select
	Days_Since_First_Purchase,
	sum(Total_Revenue) as Revenue_per_day
from
	purchase_days
group by
	Days_Since_First_Purchase)
select
	Days_Since_First_Purchase,
	Revenue_per_day,
	round((Revenue_per_day / (select sum(Total_Revenue) from cohort_analysis)) * 100, 2) as Percentage_Total_Revenue,
	round(sum((Revenue_per_day / (select sum(Total_Revenue) from cohort_analysis)) * 100) over(order by Days_Since_First_Purchase),2) as Cumulative_Percentage_Total_Revenue
from
	daily_revenue

/*
Question 3 - Customer Revenue by Cohort (Adjusted for time in market) - Only First Purchase Date
Examine the query titled Customer Revenue by Cohort (Adjusted for time in market) – Only First Purchase Date.
*/
select
	Cohort_Year,
	count(distinct CustomerKey) as Customer_Cnt,
	sum(Total_Revenue) as Revenue_Total,
	round(sum(Total_Revenue) / count(distinct CustomerKey),0) as Revenue_per_Customer
from 
	cohort_analysis
where
	[Order Date] = First_Purchase_Date
group by
	Cohort_Year


/*
Question: RETENTION ANALYSIS
Write an SQL query on the cohort_analysis table to perform a cohort-based churn analysis that identifies each customer’s latest purchase, 
classifies them as Active or Churned based on their last purchase date relative to the dataset, excludes customers with less than six months tenure, 
and calculates the number, total, and percentage of customers by status for each cohort year.
*/
with customer_purchase_history as
(select
	CustomerKey,
	[Order Date],
	First_Purchase_Date,
	Cohort_Year,
	ROW_NUMBER() over(partition by CustomerKey order by [Order Date] desc) as rn
from
	cohort_analysis),

customer_segments as
(select
	CustomerKey,
	[Order Date] as Latest_Puchase_Date,
	First_Purchase_Date,
	Cohort_Year,
	case 
	when [Order Date] < dateadd(month, -6, (select max([Order Date]) from cohort_analysis)) then 'CHURNED'
	else 'ACTIVE'
	end as Customer_Status
from
	customer_purchase_history
where -- filtering customers eligible for churn analysis: by focusing on the latest purchase and considering only those customers whose first purchase date is at least 6 months before the most recent order in the dataset
	rn = 1
and
	First_Purchase_Date < dateadd(month, -6, (select max([Order Date]) from cohort_analysis)) ),

cohort_summary as
(select
	Cohort_Year,
	Customer_Status,
	count(CustomerKey) as Num_Customers
from
	customer_segments
group by
	Cohort_Year,
	Customer_Status)

select
	Cohort_Year,
	Customer_Status,
	Num_Customers,
	sum(Num_Customers) over(partition by Cohort_Year) as Total_Customers,
	round((Num_Customers / cast(sum(Num_Customers) over(partition by Cohort_Year) as float)) * 100, 2) as Percentage_Total_Customers
from
	cohort_summary
order by
	Cohort_Year,
	Customer_Status