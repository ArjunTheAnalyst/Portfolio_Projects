use Portfolio_Project

select *
from 
	Layoffs_staging

select
	max(total_laid_off), 
	max(try_cast(percentage_laid_off as float))
from
	Layoffs_staging

select *
from 
	Layoffs_staging
where
	try_cast(percentage_laid_off as float) = 1
order by
	total_laid_off desc

select *
from 
	Layoffs_staging
where
	try_cast(percentage_laid_off as float) = 1
order by
	funds_raised_millions desc

select 
	company, sum(total_laid_off)
from
	Layoffs_staging
group by
	company
order by
	2 desc

select 
	min(date), max(date)
from 
	Layoffs_staging

select 
	industry, sum(total_laid_off)
from
	Layoffs_staging
group by
	industry
order by
	2 desc

select 
	country, sum(total_laid_off)
from
	Layoffs_staging
group by
	country
order by
	2 desc

select 
	year(date), sum(total_laid_off)
from
	Layoffs_staging
group by
	year(date)
order by
	1 desc

select 
	stage, sum(total_laid_off)
from
	Layoffs_staging
group by
	stage
order by
	2 desc

select
	year(date) as year_number,
	month(date) as month_number,
	sum(total_laid_off) 
from
	Layoffs_staging
where
	year(date) is not null
	and
	month(date) is not null
--	month(date) between 1 and 12 
group by
	year(date),
	month(date)
order by
	1,2

with rolling_total as
(
select
	year(date) as year_number,
	month(date) as month_number,
	sum(total_laid_off) as laid_off_total
from
	Layoffs_staging
where
	year(date) is not null
	and
	month(date) is not null
group by
	year(date),
	month(date)
	--order by
	--1,2
)
select
	year_number,
	month_number,
	laid_off_total,
	sum(laid_off_total)
	over(order by year_number, month_number) as cumulative_count /* we didn't use partition by because we used group by */
from
	rolling_total

select 
	company, 
	year(date), 
	sum(total_laid_off)
from
	Layoffs_staging
group by
	company, 
	year(date)
order by
	3 desc 
 
 with company_year
 as
 (
 select 
	company, 
	year(date) as year_number, 
	sum(total_laid_off) as laid_off_total
from
	Layoffs_staging
where 
	year(date) is not null
group by
	company,
	year(date)
--order by
--	3 desc
)
, company_year_rank as
(
select *,
	dense_rank() over(partition by year_number order by laid_off_total desc) as ranks
from
	company_year
)
select * 
from 
	company_year_rank
where ranks <= 5
 



 
