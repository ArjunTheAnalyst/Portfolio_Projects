use Lukas_SQL

select * from company_dim
select * from job_postings_fact
select * from skills_dim
select * from skills_job_dim

/*
Question: What are the top-paying data analyst jobs?
- Identify the top 10 highest-paying Data Analyst roles that are available remotely.
- Focuses on job postings with specified salaries (remove nulls).
- Why? Highlight the top-paying opportunities for Data Analysts, offering insights into employment options and location flexibility.
*/

select top 10
	a.job_id,
	a.job_title,
	a.job_location,
	a.job_schedule_type,
	cast(a.salary_year_avg as float) as average_yearly_salary,
	a.job_posted_date,
	b.name as company_name
from 
	job_postings_fact as a
left join
	company_dim as b
on 
	a.company_id = b.company_id
where 
	a.job_title_short = 'Data Analyst' 
and
	a.job_location = 'Anywhere'
and
	a.salary_year_avg is not null 
order by
	average_yearly_salary desc

/*
Breakdown of the top data analyst jobs in 2023:
The list showcases some of the highest-paying data analyst roles. The top position is a Data Analyst at Mantys, 
offering an annual salary of $650,000, followed by a Director of Analytics at Meta with $336,500. 
Other significant roles include an Associate Director of Data Insights at AT&T, offering $255,829.5, 
and a Data Analyst at Pinterest with $232,423. These roles are spread across various companies and offer a range of salaries, 
reflecting the high demand and value placed on data analytics expertise in different industries.
*/




/*
Question: What skills are required for the top-paying data analyst jobs?
- Use the top 10 highest-paying Data Analyst jobs from first query
- Add the specific skills required for these roles
- Why? It provides a detailed look at which high-paying jobs demand certain skills, 
  helping job seekers understand which skills to develop that align with top salaries
*/

with top_paying_jobs as
(
select top 10
	a.job_id,
	a.job_title,
	cast(a.salary_year_avg as float) as average_yearly_salary,
	b.name as company_name
from 
	job_postings_fact as a
left join
	company_dim as b
on 
	a.company_id = b.company_id
where 
	a.job_title_short = 'Data Analyst' 
and
	a.job_location = 'Anywhere'
and
	a.salary_year_avg is not null 
order by
	average_yearly_salary desc
)
select 
	c.*,-- selecting all columns
	e.skills
from 
	top_paying_jobs as c
join
	skills_job_dim as d 
on
	c.job_id = d.job_id -- connecting job postings with their skills
join
	skills_dim as e
on
	d.skill_id = e.skill_id -- connecting skills with their names
-- the primary reason for using INNER JOIN is to ensure that the final result set only includes job postings with corresponding skills, 
-- NOT to account for jobs without skills
order by
	average_yearly_salary desc

/*
Breakdown of the top skills for top data analyst jobs:
SQL, Python, Tableau, Excel, R, Snowflake, Pandas, AWS, and Azure are the key tools.
Proficiency in SQL, Python, and data visualization tools like Tableau is highly emphasised crucial. 
Cloud computing and collaboration platforms are also vital in higher-paying roles.*/	
/*




Question: What are the most in-demand skills for data analysts?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market, 
  providing insights into the most valuable skills for job seekers.
*/
with remote_job_skills as
(
select
	b.skill_id,
	count(b.skill_id) as skill_count
from 
	job_postings_fact as a
join
	skills_job_dim as b
on
	a.job_id = b.job_id
where
	job_title_short = 'Data Analyst'
and	
	job_work_from_home = 1
group by
	b.skill_id
)
select top 5
	c.skill_id,
	d.skills as skill_name,
	skill_count
from 
	remote_job_skills as c
join
	skills_dim as d
on
	c.skill_id = d.skill_id
order by
	skill_count desc


-- Alternate approach WITHOUT CTE
select top 5 
	b.skill_id,
	c.skills as skill_name,
	count(b.skill_id) as skill_count
from 
	job_postings_fact as a
join
	skills_job_dim as b
on
	a.job_id = b.job_id
join
	skills_dim as c
on
	b.skill_id = c.skill_id
where 
	a.job_title_short = 'Data Analyst'
and
	a.job_work_from_home = 1
group by
	b.skill_id,
	c.skills
order by
	skill_count desc

/*
Breakdown of the top demanded skills:
The top skills for remote data analyst jobs are SQL (7,291), Excel (4,611), Python (4,330), Tableau (3,745), and Power BI (2,609). 
SQL dominates, essential for querying databases, while Excel remains key for data manipulation. 
Python's versatility in analysis and automation is crucial, and both Tableau and Power BI are highly valued for data visualization. 
These skills reflect the core technical expertise needed in the industry.
*/




/*
What are the top skills based on salary?
- Look at the average salary associated with each skill for Data Analyst positions
- Focuses on roles with specified salaries, regardless of location
- Why? It reveals how different skills impact salary levels for Data Analysts and 
  helps identify the most financially rewarding skills to acquire or improve
*/
select top 25 
	c.skills as skill_name,
	round(avg(cast(a.salary_year_avg as float)), 0) as avg_salary
from 
	job_postings_fact as a
join
	skills_job_dim as b
on
	a.job_id = b.job_id
join
	skills_dim as c
on
	b.skill_id = c.skill_id
where 
	a.job_title_short = 'Data Analyst'
and
	a.salary_year_avg is not null
and
	a.job_work_from_home = 1
group by
	b.skill_id,
	c.skills
order by
	avg_salary desc

/*
Breakdown of top skills based on salary:
Top-paying skills for data roles include PySpark, Bitbucket, and Couchbase, highlighting demand for big data processing and version control. 
Watson and DataRobot also command high salaries, reflecting the value of AI and machine learning expertise. 
Other key skills like GitLab, Swift, Jupyter, and Kubernetes emphasize the importance of coding, data management, 
and cloud technologies in securing lucrative positions.
*/




/*
What are the most optimal skills to learn (that are in in high demand and a high-paying skill)?
- Identify skills in high demand and associated with high average salaries for Data Analyst roles
- Concentrates on remote positions with specified salaries
- Why? Targets skills that offer job security (high demand) and financial benefits (high salaries), 
  offering strategic insights for career development in data analysis
*/

--top demanded skills
with skills_demand as
(
select
	b.skill_id,
	c.skills as skill_name,
	count(b.skill_id) as skill_count
from
	job_postings_fact as a
join
	skills_job_dim as b
on
	a.job_id = b.job_id 
join
	skills_dim as c
on
	b.skill_id = c.skill_id
where
	a.job_title_short = 'Data Analyst' and a.job_work_from_home = 1 and a.salary_year_avg is not null
group by
	b.skill_id,
	c.skills
),
--top paying skills
average_salary as 
(
select
	e.skill_id,
	f.skills as skill_name,
	round(avg(cast(d.salary_year_avg as float)), 0) as avg_salary
from 
	job_postings_fact as d
join
	skills_job_dim as e
on
	d.job_id = e.job_id
join
	skills_dim as f
on
	e.skill_id = f.skill_id
where 
	d.job_title_short = 'Data Analyst' and d.job_work_from_home = 1 and d.salary_year_avg is not null
group by
	e.skill_id,
	f.skills
)
--return high demand and high salaries where skill_count is greater than 10
select top 25
	g.skill_id,
	g.skill_name, 
	skill_count,
	avg_salary
from 
	skills_demand as g
join
	average_salary as h
on
	g.skill_id = h.skill_id
where
	skill_count > 10
order by
	avg_salary desc,
	skill_count desc

--rewriting the same query more concisely
select top 25
	b.skill_id,
	c.skills as skill_name,
	count(b.skill_id) as skill_count,
	round(avg(cast(a.salary_year_avg as float)), 0) as avg_salary
from 
	job_postings_fact as a
join
	skills_job_dim as b
on
	a.job_id = b.job_id
join
	skills_dim as c
on
	b.skill_id = c.skill_id
where 
	job_title_short = 'Data Analyst' and job_work_from_home = 1 and salary_year_avg is not null
group by
	b.skill_id,
	c.skills 
having 
	count(b.skill_id) > 10
order by
	avg_salary desc,
	skill_count desc

/*
Breakdown of optimal skills:
Skills like Go, Hadoop, Snowflake, and Azure offer salaries above $100,000 and are in high demand. 
Key tools like AWS, Python, and Tableau are also highly valued, making them essential in today’s tech landscape. 
Mastering these skills can significantly boost career prospects and earning potential.
*/