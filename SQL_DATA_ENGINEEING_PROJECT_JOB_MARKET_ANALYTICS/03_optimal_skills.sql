SELECT * FROM job_postings_fact LIMIT 10;
SELECT * FROM skills_dim LIMIT 10;
SELECT * FROM skills_job_dim LIMIT 10;
SELECT * FROM company_dim LIMIT 10;

/*
Question: 
Write a SQL query to identify the optimal skills and 
their salary trends for remote “Data Engineer” job postings.
*/

SELECT
    b.skill_id,
    c.skills,
    count(b.skill_id) as skill_cnt,
    round(median(a.salary_year_avg),0) as median_salary,
    round(ln(count(b.skill_id)),1) as log_normal_cnt,
    round(
    (median(a.salary_year_avg) * ln(count(b.skill_id)))
    /
    1_000_000,2) as optimal_score
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
and
    a.salary_year_avg is not null
group by
    b.skill_id,
    c.skills
order by
    optimal_score desc
LIMIT 25;

/*
┌──────────┬────────────┬───────────┬───────────────┬────────────────┬───────────────┐
│ skill_id │   skills   │ skill_cnt │ median_salary │ log_normal_cnt │ optimal_score │
│  int32   │  varchar   │   int64   │    double     │     double     │    double     │
├──────────┼────────────┼───────────┼───────────────┼────────────────┼───────────────┤
│      217 │ terraform  │       193 │      184000.0 │            5.3 │          0.97 │
│        1 │ python     │      1133 │      135000.0 │            7.0 │          0.95 │
│        0 │ sql        │      1128 │      130000.0 │            7.0 │          0.91 │
│       77 │ aws        │       783 │      137320.0 │            6.7 │          0.91 │
│      104 │ airflow    │       386 │      150000.0 │            6.0 │          0.89 │
│       92 │ spark      │       503 │      140000.0 │            6.2 │          0.87 │
│       73 │ snowflake  │       438 │      135500.0 │            6.1 │          0.82 │
│       97 │ kafka      │       292 │      145000.0 │            5.7 │          0.82 │
│       74 │ azure      │       475 │      128000.0 │            6.2 │          0.79 │
│       12 │ java       │       303 │      135000.0 │            5.7 │          0.77 │
│        7 │ scala      │       247 │      137290.0 │            5.5 │          0.76 │
│      213 │ kubernetes │       147 │      150500.0 │            5.0 │          0.75 │
│      215 │ git        │       208 │      140000.0 │            5.3 │          0.75 │
│       75 │ databricks │       266 │      132750.0 │            5.6 │          0.74 │
│       79 │ redshift   │       274 │      130000.0 │            5.6 │          0.73 │
│       78 │ gcp        │       196 │      136000.0 │            5.3 │          0.72 │
│      106 │ hadoop     │       198 │      135000.0 │            5.3 │          0.71 │
│        9 │ nosql      │       193 │      134415.0 │            5.3 │          0.71 │
│       98 │ pyspark    │       152 │      140000.0 │            5.0 │           0.7 │
│      214 │ docker     │       144 │      135000.0 │            5.0 │          0.67 │
│       34 │ golang     │        39 │      184000.0 │            3.7 │          0.67 │
│        2 │ r          │       133 │      134775.0 │            4.9 │          0.66 │
│        3 │ go         │       113 │      140000.0 │            4.7 │          0.66 │
│       32 │ rust       │        23 │      210000.0 │            3.1 │          0.66 │
│       80 │ bigquery   │       123 │      135000.0 │            4.8 │          0.65 │
├──────────┴────────────┴───────────┴───────────────┴────────────────┴───────────────┤
│ 25 rows                                                                  6 columns │
└────────────────────────────────────────────────────────────────────────────────────┘
*/