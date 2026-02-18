SELECT * FROM job_postings_fact LIMIT 10;
SELECT * FROM skills_dim LIMIT 10;
SELECT * FROM skills_job_dim LIMIT 10;
SELECT * FROM company_dim LIMIT 10;

/*
Question: 
Write a SQL query to identify high-demand skills and 
their salary trends for remote “Data Engineer” job postings.
*/

SELECT
    b.skill_id,
    c.skills,
    count(b.skill_id) as skill_cnt,
    round(median(a.salary_year_avg),0) as median_salary
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
    median_salary desc
LIMIT 25;

/*
┌──────────┬───────────┬───────────┬───────────────┐
│ skill_id │  skills   │ skill_cnt │ median_salary │     
│  int32   │  varchar  │   int64   │    double     │
├──────────┼───────────┼───────────┼───────────────┤
│       32 │ rust      │        23 │      210000.0 │     
│      195 │ sheets    │         2 │      196698.0 │
│       26 │ solidity  │         3 │      192500.0 │     
│       34 │ golang    │        39 │      184000.0 │     
│      217 │ terraform │       193 │      184000.0 │
│      156 │ next.js   │         2 │      180000.0 │     
│      115 │ ggplot2   │         2 │      176250.0 │     
│      103 │ spring    │        33 │      175500.0 │
│       40 │ ocaml     │         1 │      172500.0 │     
│       51 │ erlang    │         1 │      172500.0 │     
│       41 │ haskell   │         1 │      172500.0 │     
│       64 │ neo4j     │        11 │      170000.0 │
│      112 │ gdpr      │        22 │      169616.0 │     
│      253 │ zoom      │        12 │      168438.0 │     
│      116 │ graphql   │        28 │      167500.0 │
│       96 │ plotly    │         3 │      162500.0 │     
│       11 │ mongo     │        14 │      162250.0 │
│      171 │ centos    │         2 │      159350.0 │     
│      113 │ mxnet     │         1 │      157500.0 │     
│      140 │ fastapi   │         3 │      157500.0 │
│      158 │ drupal    │         1 │      156000.0 │     
│      146 │ vue       │         1 │      156000.0 │
│      239 │ trello    │         1 │      155000.0 │     
│      224 │ bitbucket │         9 │      155000.0 │     
│      145 │ django    │         5 │      155000.0 │
├──────────┴───────────┴───────────┴───────────────┤
│ 25 rows                                4 columns │     
└──────────────────────────────────────────────────┘
*/

SELECT
    b.skill_id,
    c.skills,
    count(b.skill_id) as skill_cnt,
    round(median(a.salary_year_avg),0) as median_salary
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
having
    count(b.skill_id) > 100
order by
    median_salary desc
LIMIT 25;

/*
┌──────────┬────────────┬───────────┬───────────────┐
│ skill_id │   skills   │ skill_cnt │ median_salary │
│  int32   │  varchar   │   int64   │    double     │    
├──────────┼────────────┼───────────┼───────────────┤
│       32 │ rust       │       232 │      210000.0 │    
│       34 │ golang     │       912 │      184000.0 │
│      217 │ terraform  │      3248 │      184000.0 │
│      103 │ spring     │       364 │      175500.0 │    
│       64 │ neo4j      │       277 │      170000.0 │    
│      112 │ gdpr       │       582 │      169616.0 │
│      253 │ zoom       │       127 │      168438.0 │    
│      116 │ graphql    │       445 │      167500.0 │    
│       11 │ mongo      │       265 │      162250.0 │    
│      140 │ fastapi    │       204 │      157500.0 │
│      145 │ django     │       265 │      155000.0 │    
│      224 │ bitbucket  │       478 │      155000.0 │    
│        5 │ crystal    │       129 │      154224.0 │    
│      211 │ atlassian  │       249 │      151500.0 │
│       27 │ c          │       444 │      151500.0 │    
│       30 │ typescript │       388 │      151000.0 │    
│      213 │ kubernetes │      4202 │      150500.0 │    
│      150 │ node       │       179 │      150000.0 │    
│      104 │ airflow    │      9996 │      150000.0 │    
│       20 │ css        │       262 │      150000.0 │    
│       10 │ ruby       │       368 │      150000.0 │
│      139 │ ruby       │       368 │      150000.0 │    
│       61 │ redis      │       605 │      149000.0 │
│      220 │ ansible    │       475 │      148798.0 │    
│       82 │ vmware     │       136 │      148798.0 │    
├──────────┴────────────┴───────────┴───────────────┤
│ 25 rows                                 4 columns │    
└───────────────────────────────────────────────────┘
*/
