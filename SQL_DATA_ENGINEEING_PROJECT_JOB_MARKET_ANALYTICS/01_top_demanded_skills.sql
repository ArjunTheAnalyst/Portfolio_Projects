
SELECT * FROM job_postings_fact LIMIT 10;
SELECT * FROM skills_dim LIMIT 10;
SELECT * FROM skills_job_dim LIMIT 10;
SELECT * FROM company_dim LIMIT 10;

/*
Question: 
Write a SQL query to identify the top 10 most in-demand skills 
for remote “Data Engineer” job postings.
*/

SELECT
    b.skill_id,
    c.skills as skill_name,
    count(b.skill_id) as skill_cnt
FROM
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
    a.job_title_short like 'Data Engineer'
and
    a.job_work_from_home = TRUE
group by
    b.skill_id,
    c.skills
order by
    skill_cnt desc
LIMIT 10;

/*
┌──────────┬────────────┬───────────┐
│ skill_id │ skill_name │ skill_cnt │
│  int32   │  varchar   │   int64   │
├──────────┼────────────┼───────────┤
│        0 │ sql        │     29221 │
│        1 │ python     │     28776 │
│       77 │ aws        │     17823 │
│       74 │ azure      │     14143 │
│       92 │ spark      │     12799 │
│      104 │ airflow    │      9996 │
│       73 │ snowflake  │      8639 │
│       75 │ databricks │      8183 │
│       12 │ java       │      7267 │
│       78 │ gcp        │      6446 │
├──────────┴────────────┴───────────┤
│ 10 rows                 3 columns │
└───────────────────────────────────┘
*/