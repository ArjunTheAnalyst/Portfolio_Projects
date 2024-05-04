--Data Cleaning
use Portfolio_Project

--1. Remove Duplicates
--2. Standardization of data
--3. Null values or blank values
--4. Removal of any columns or rows

--Copying the data into a new table for cleaning
select *
into 
	Layoffs_staging
from
	Layoffs

select *
from 
	Layoffs_staging

--Handling duplicates
with duplicate_cte as
(
select *,
row_number()
over
(
partition by
	company,
	location,
	industry,
	total_laid_off,
	percentage_laid_off,
	date,
	stage,
	country,
	funds_raised_millions
	order by company
)
	as row_num
from 
	Layoffs_staging
)

delete
from	
	duplicate_cte
where 
	row_num > 1

select *
from 
	duplicate_cte
where 
	row_num > 1


--Standardizing data
select 
	company,
	trim(company)
from 
	Layoffs_staging

update 
	Layoffs_staging
set company = trim(company)

select distinct
	industry
from
	Layoffs_staging
order by
	1

select *
from 
	Layoffs_staging
where 
	industry like 'Crypto%'
order by
	company

update 
	Layoffs_staging
set 
	industry = 'Crypto'
where 
	industry like 'Crypto%'

select distinct 
	location
from 
	Layoffs_staging
order by
	1

select distinct
	country, trim(trailing '.' from country)
from 
	Layoffs_staging
order by 1

update 
	Layoffs_staging
set
	country = trim(trailing '.' from country)
where 
	country like 'United States%'

/* change date dtype from datetime to date */
alter table
	Layoffs_Staging
alter column
	date DATE


--Handling null values
select *
from 
	Layoffs_staging
where 
	total_laid_off IS NULL
	AND
	try_cast(percentage_laid_off as float) IS NULL 
/* try_cast attempts conversion, but when it fails, it return NULL instead of raising error */

select *	
from
	Layoffs_staging
where 
	industry is null

select *
from 
	Layoffs_staging
where 
	company = 'Airbnb'

/* populating null values in industry column */
select a.company, a.location, a.industry, b.company, b.location, b.industry
from 
	Layoffs_staging as a
	join
	Layoffs_staging as b
	on
	a.company = b.company
where 
	a.industry is null 
order by 
	a.company

update 
	 a
set 
	a.industry = b.industry
from 
	Layoffs_staging as a
	join
	Layoffs_staging as b
	on
	a.company = b.company
where 
	a.industry is null 

select * /* verifying */
from 
	Layoffs_staging
where 
	industry is null

delete 
from 
	Layoffs_staging
where 
	total_laid_off IS NULL
	AND
	try_cast(percentage_laid_off as float) IS NULL 



