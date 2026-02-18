SELECT 
    job_id, 
    job_title_short, 
    salary_year_avg, 
    company_id 
FROM 
    job_postings_fact 
LIMIT 10;

SELECT 
    company_id
FROM 
    company_dim
limit 10;

SELECT
    *
FROM
    company_dim
LIMIT 10;

SELECT
    *
FROM
    skills_job_dim
LIMIT 5;

SELECT
    *
FROM
    skills_dim
LIMIT 5;

select
    *
FROM
    information_schema.tables
where
    table_catalog like 'data_jobs';

pragma show_tables_expanded;

describe job_postings_fact;

select * FROM sys.databases