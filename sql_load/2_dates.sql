SELECT COUNT(job_id) AS job_posting,
    EXTRACT(MONTH FROM (job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York')) AS job_month
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM (job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York')) = 2023
GROUP BY job_month
ORDER BY job_month DESC;

--January
CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 1;

CREATE TABLE feburary_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 3;

SELECT job_posted_date
FROM march_jobs;

SELECT *
FROM company_dim
LIMIT 100;


SELECT c.name AS company_name, j.job_health_insurance 
FROM company_dim AS c
JOIN job_postings_fact As j
    ON c.company_id = j.company_id
WHERE j.job_health_insurance IS TRUE AND EXTRACT(QUARTER FROM job_posted_Date) = 2
    AND EXTRACT(YEAR FROM job_posted_date) = 2023;


SELECT COUNT(job_id) AS number_of_jobs,
    --job_title_short,
    --job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category;

SELECT *
FROM job_postings_fact
LIMIT 100;


SELECT job_id,salary_year_avg,salary_hour_avg,salary_rate,
    CASE 
        WHEN salary_year_avg >= 50000 THEN 'HIGH'
        WHEN salary_year_avg <50000 AND salary_year_avg > 0 THEN 'standard'
        ELSE 'low'
    END AS salary_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC;



SELECT *
FROM (--subquery starts here
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 1
) AS january_jobs;


WITH january_jobs AS( --CTE definition starts here
   SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 1 
)--CTE definition ends here

SELECT *
FROM january_jobs;


SELECT company_id,
    name AS company_name
FROM
    company_dim
WHERE company_id IN(
    SELECT company_id
    FROM job_postings_fact
    WHERE job_no_degree_mention = true
    ORDER BY company_id
)


/*
Find the companies that have the most job openings.
-Get the total number of job postings per company_id (job_posting_fact)
-Return the total number of jobs with the company name (company_dim)
*/

WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)

SELECT company_dim.name AS company_name,
    company_job_count.total_jobs
FROM company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY total_jobs DESC;

SELECT *
FROM job_postings_fact
LIMIT 100;

SELECT *
FROM skills_job_dim
LIMIT 100;

SELECT *
FROM skills_dim
LIMIT 100;

SELECT s.skills AS skill_name,
    top_skills.skill_count
FROM skills_dim AS s
LEFT JOIN(
    SELECT sj.skill_id,
        COUNT(*) AS skill_count
    FROM skills_job_dim AS sj
    GROUP BY sj.skill_id
    ORDER BY COUNT(*) DESC
    LIMIT 5
) AS top_skills
ON s.skill_id = top_skills.skill_id
ORDER BY top_skills.skill_count DESC;



SELECT s.skills AS skill_name,
    top_skills.skill_count
FROM skills_dim AS s
LEFT JOIN (
    SELECT sj.skill_id,COUNT(*) AS skill_count
    FROM skills_job_dim AS sj
    GROUP BY sj.skill_id
    ORDER BY COUNT(*) DESC
    LIMIT 5
) AS top_skills
ON s.skill_id = top_skills.skill_id
ORDER BY top_skills.skill_count DESC;



SELECT s.skills AS skill_name,
       top_skills.skill_count
FROM skills_dim AS s
JOIN (
    SELECT sj.skill_id,
           COUNT(*) AS skill_count
    FROM skills_job_dim AS sj
    GROUP BY sj.skill_id
    ORDER BY COUNT(*) DESC
    LIMIT 5
) AS top_skills
ON s.skill_id = top_skills.skill_id
ORDER BY top_skills.skill_count DESC;
