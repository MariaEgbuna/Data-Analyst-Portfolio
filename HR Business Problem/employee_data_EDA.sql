-- Business Problem for HR Analyst: Employee Retention and Workforce Optimization

-- Basic Info
-- Total number of employees
SELECT COUNT(*) AS no_of_employees
FROM employee_data AS ed;
-- A total of 3000 employees

-- Gender Count
SELECT ed.gender, COUNT(*) AS gender_count
FROM employee_data AS ed
GROUP BY ed.gender;
-- There is a noticeable difference in gender representation, with Female employees (1682) outnumbering Male employees (1318).

-- Diversity Check
SELECT ed.race_description, COUNT(*) AS ethnicity_count 
FROM employee_data AS ed
GROUP BY ed.race_description
ORDER BY ethnicity_count;
-- The most striking observation is that the employee population is fairly evenly distributed across all listed racial descriptions. The counts for each group are relatively close, ranging from 572 (Hispanic) to 629 (Asian). This indicates that the company appears to have a fairly diverse workforce in terms of racial description, with no single group overwhelmingly dominating or being significantly underrepresented compared to the others.

-- 1. WORKFORCE DEMOGRAPHICS & DIVERSITY

-- (a). What is the gender, race, and age distribution of employees across different business units?
-- Gender Distribution Across Business Units
SELECT 
	ed.business_unit,
	COUNT(ed.gender) FILTER (WHERE ed.gender = 'Male') AS male_count,
    COUNT(ed.gender) FILTER (WHERE ed.gender = 'Female') AS female_count
FROM employee_data AS ed
GROUP BY ed.business_unit;

-- Race Distribution Across Business Units
SELECT 
	ed.business_unit,
	COUNT(ed.race_description) FILTER (WHERE ed.race_description = 'Asian') AS asians,
    COUNT(ed.race_description) FILTER (WHERE ed.race_description = 'Black') AS blacks,
    COUNT(ed.race_description) FILTER (WHERE ed.race_description = 'Hispanic') AS hispanics,
    COUNT(ed.race_description) FILTER (WHERE ed.race_description = 'Other') AS other_race,
    COUNT(ed.race_description) FILTER (WHERE ed.race_description = 'White') AS whites
FROM employee_data AS ed
GROUP BY ed.business_unit;

-- Average Age and Age Group Distribution Across Business Units
-- Age Group Distribution
SELECT 
	ed.business_unit,
	COUNT(ed.age_group) FILTER (WHERE ed.age_group = 'Ages 20-35') AS ages_20_35_count,
    COUNT(ed.age_group) FILTER (WHERE ed.age_group = 'Ages 36-55') AS ages_36_55_count,
    COUNT(ed.age_group) FILTER (WHERE ed.age_group = 'Ages 56-70') AS ages_56_70_count,
    COUNT(ed.age_group) FILTER (WHERE ed.age_group = 'Above 70') AS above_70_count
FROM employee_data AS ed
GROUP BY ed.business_unit;
-- Average Age across business units
SELECT 
	ed.business_unit,
	AVG(ed.age) AS average_age,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ed.age) AS median_age,
    STDDEV(ed.age) AS age_std_dev,
    COUNT(ed.age) AS employee_count
FROM employee_data AS ed
GROUP BY ed.business_unit;
-- Insight: Overall Mature Workforce. The average and median ages across all business units are relatively high, generally ranging from 51 to 55 years.

-- (b). Which departments have the highest concentration of employees from specific demographic groups?
-- By race description
SELECT 
	ed.department_type,
	COUNT(ed.race_description) FILTER (WHERE ed.race_description = 'Asian') AS asians,
    COUNT(ed.race_description) FILTER (WHERE ed.race_description = 'Black') AS blacks,
    COUNT(ed.race_description) FILTER (WHERE ed.race_description = 'Hispanic') AS hispanics,
    COUNT(ed.race_description) FILTER (WHERE ed.race_description = 'Other') AS other_race,
    COUNT(ed.race_description) FILTER (WHERE ed.race_description = 'White') AS whites
FROM employee_data AS ed
GROUP BY ed.department_type;

-- By number of employees
SELECT 
	ed.department_type,
	COUNT(ed.gender) FILTER (WHERE ed.gender = 'Male') AS men,
	COUNT(ed.gender) FILTER (WHERE ed.gender = 'Female') AS women
FROM employee_data AS ed
GROUP BY ed.department_type;

-- (c). What is the average employee tenure based on age groups and employee classification types?
SELECT
    ed.age_group,
    ed.employee_classification_type,
    AVG(
        EXTRACT(YEAR FROM AGE(COALESCE(ed.exit_date, '2025-06-10'::date), ed.start_date)) +
        EXTRACT(MONTH FROM AGE(COALESCE(ed.exit_date, '2025-06-10'::date), ed.start_date)) / 12.0 +
        EXTRACT(DAY FROM AGE(COALESCE(ed.exit_date, '2025-06-10'::date), ed.start_date)) / 365.25
    ) AS average_tenure_years
FROM employee_data AS ed
GROUP BY ed.age_group, ed.employee_classification_type
ORDER BY ed.age_group, average_tenure_years;
-- Observations: Full-Time employees tend to have slightly higher average tenures across most age groups compared to Part-Time and Temporary employees. The "Ages 20-35" Full-Time group shows the highest average tenure at approximately 3.07 years.

-- 2. EMPLOYEE RETENTION & ATTRITION ANALYSIS

-- (a). What percentage of employees have exited the company over the years?
SELECT
    EXTRACT(YEAR FROM ed.exit_date) AS exit_year,
    (COUNT(ed.emp_id)::numeric * 100) / (SELECT COUNT(*) FROM employee_data)::numeric AS percentage_exited
FROM employee_data AS ed
WHERE ed.exit_date IS NOT NULL
GROUP BY exit_year
ORDER BY exit_year;
-- Observation: There's a clear upward trend in the number and percentage of employees exiting the company year over year from 2018 to 2023. This is a substantial increase and indicates a growing challenge with employee retention in recent years.

-- (b). What are the top reasons for employee exits (resignation, involuntary termination, retirement)?
SELECT ed.termination_type, COUNT(*) AS count_of_exits
FROM employee_data AS ed
WHERE ed.termination_type IS NOT NULL AND ed.termination_type != 'Unknown'
GROUP BY ed.termination_type
ORDER BY count_of_exits DESC;
-- Observation: There isn't one single reason that dominates the exits, instead, there's a relatively even distribution across these four main categories. This implies that HR strategies might need to address multiple facets of retention and exit management.

-- (c). Which job titles and pay zones have the highest turnover rates?
-- Turnover Rate by Job Title
WITH TotalEmployeesByTitle AS (
    SELECT title, COUNT(*) AS total_employees
    FROM employee_data
    GROUP BY title
),
ExitedEmployeesByTitle AS (
    SELECT title, COUNT(*) AS exited_employees
    FROM employee_data
    WHERE exit_date IS NOT NULL
    GROUP BY title
)
SELECT
    t.title, t.total_employees,
    COALESCE(e.exited_employees, 0) AS exited_employees,
    (COALESCE(e.exited_employees, 0)::numeric * 100.0) / t.total_employees::numeric AS turnover_rate
FROM TotalEmployeesByTitle AS t
LEFT JOIN ExitedEmployeesByTitle AS e ON t.title = e.title
ORDER BY turnover_rate DESC, t.title;
-- Observation: Extremely High Turnover in Specialized Roles. "Data Architect" shows a 100% turnover rate, meaning all 5 employees in this role have exited. "Enterprise Architect" and "Software Engineering Manager" also have very high rates at 80% and 70% respectively.

-- Turnover Rate by Pay Zone
WITH TotalEmployeesByPayzone AS (
    SELECT payzone, COUNT(*) AS total_employees
    FROM employee_data
    GROUP BY  payzone
),
ExitedEmployeesByPayzone AS (
    SELECT payzone, COUNT(*) AS exited_employees
    FROM employee_data
    WHERE exit_date IS NOT NULL
    GROUP BY payzone
)
SELECT
    p.payzone,
    p.total_employees,
    COALESCE(e.exited_employees, 0) AS exited_employees,
    (COALESCE(e.exited_employees, 0)::numeric * 100.0) / p.total_employees::numeric AS turnover_rate
FROM TotalEmployeesByPayzone AS p
LEFT JOIN ExitedEmployeesByPayzone AS e ON p.payzone = e.payzone
ORDER BY turnover_rate DESC, p.payzone;
-- Observation: The pay zones show a very uniform attrition pattern. This suggests that compensation might not be a differentiating factor in high turnover, or perhaps the issue is systemic across all compensation tiers rather than concentrated in one.

-- (d). What is the relationship between tenure and termination type?
--  Average Tenure by Termination Type
SELECT
    ed.termination_type,
    AVG(
        EXTRACT(YEAR FROM AGE(ed.exit_date, ed.start_date)) +
        EXTRACT(MONTH FROM AGE(ed.exit_date, ed.start_date)) / 12.0 +
        EXTRACT(DAY FROM AGE(ed.exit_date, ed.start_date)) / 365.25
    ) AS average_tenure_years
FROM employee_data AS ed
WHERE ed.termination_type IS NOT NULL AND ed.termination_type != 'Unknown'
GROUP BY ed.termination_type
ORDER BY average_tenure_years DESC;
-- Observation: The average tenure for all termination types is quite low, ranging from approximately 1.29 to 1.41 years. This suggests that, on average, employees are not staying for very long before their employment ends, regardless of the reason.

-- Average Tenure by Employee Type and Termination Type
SELECT
    ed.employee_type, ed.termination_type,
    AVG(
        EXTRACT(YEAR FROM AGE(ed.exit_date, ed.start_date)) +
        EXTRACT(MONTH FROM AGE(ed.exit_date, ed.start_date)) / 12.0 +
        EXTRACT(DAY FROM AGE(ed.exit_date, ed.start_date)) / 365.25
    ) AS average_tenure_years
FROM employee_data AS ed
WHERE ed.termination_type IS NOT NULL AND ed.termination_type != 'Unknown'
GROUP BY ed.employee_type, ed.termination_type
ORDER BY ed.employee_type, average_tenure_years DESC;
-- Observation: These results indicate that while there are slight variations, the overall pattern is one of very short tenure for employees who exit, regardless of their employment classification or the specific reason for their departure.

-- 3. PERFORMANCE & COMPENSATION INSIGHTS

-- (a). How does employee classification impact performance ratings?
SELECT
    ed.employee_classification_type,
    AVG(
        CASE ed.performance_score
            WHEN 'Exceeds' THEN 4.0
            WHEN 'Fully Meets' THEN 3.0
            WHEN 'Needs Improvement' THEN 2.0
            WHEN 'PIP' THEN 1.0
            ELSE NULL -- Handle any unexpected values
        END
    ) AS avg_performance_score,
    AVG(ed.current_employee_rating) AS avg_current_employee_rating
FROM employee_data AS ed
GROUP BY ed.employee_classification_type
ORDER BY avg_performance_score DESC;
-- Observations: While Part-Time employees show a slight edge in current_employee_rating, the formal performance_score averages are practically the same for all classifications.

-- (b). Do certain business units have a higher percentage of low-performing employees?
SELECT
    ed.business_unit,
    COUNT(ed.emp_id) AS total_employees,
    SUM(CASE
            WHEN ed.performance_score = 'Needs Improvement' THEN 1
            WHEN ed.performance_score = 'PIP' THEN 1
            ELSE 0
        END) AS low_performing_count,
    (SUM(CASE
            WHEN ed.performance_score = 'Needs Improvement' THEN 1
            WHEN ed.performance_score = 'PIP' THEN 1
            ELSE 0
        END)::numeric * 100.0) / COUNT(ed.emp_id)::numeric AS percentage_low_performing
FROM employee_data AS ed
WHERE ed.performance_score IS NOT NULL
GROUP BY ed.business_unit
ORDER BY percentage_low_performing DESC;
-- Observation: Certain business units, particularly PYZ (12.04% low-performing), BPC (10.56%), and MSC (10.47%), had a noticeably higher percentage of low-performing employees ('Needs Improvement' or 'PIP'). This indicates potential areas for targeted performance management interventions.

-- 4. Departmental & Job Function Analysis

-- (a). Which departments have the highest employee attrition rates?
SELECT
    ed.department_type,
    COUNT(ed.emp_id) AS total_employees,
    SUM(CASE WHEN ed.exit_date IS NOT NULL THEN 1 ELSE 0 END) AS exited_employees,
    (SUM(CASE WHEN ed.exit_date IS NOT NULL THEN 1 ELSE 0 END)::numeric * 100.0) / COUNT(ed.emp_id)::numeric AS attrition_rate
FROM employee_data AS ed
GROUP BY ed.department_type
ORDER BY attrition_rate DESC;
-- Observation: The 'Executive Office' department stands out significantly with an attrition rate of approximately 79.17%. While it has a smaller total number of employees, this rate is exceptionally high.

-- (b). Are certain divisions experiencing more involuntary terminations than others?
SELECT
    ed.division,
    COUNT(ed.emp_id) AS total_employees,
    SUM(CASE
            WHEN ed.termination_type IN ('Involuntary', 'Layoff') THEN 1
            ELSE 0
        END) AS involuntary_termination_count,
    (SUM(CASE
            WHEN ed.termination_type IN ('Involuntary', 'Layoff') THEN 1
            ELSE 0
        END)::numeric * 100.0) / COUNT(ed.emp_id)::numeric AS percentage_involuntary_termination
FROM employee_data AS ed
WHERE ed.termination_type IS NOT NULL -- Only consider employees with a recorded termination type
GROUP BY ed.division
ORDER BY percentage_involuntary_termination DESC;
-- Observation: While some divisions might have fewer total employees but high percentages, there are larger divisions like 'Engineers' and 'Field Operations' which, despite their size, still have notable numbers of involuntary terminations. 

-- (c). What is the average tenure per job function?
SELECT
    ed.title AS job_function,
    AVG(
        EXTRACT(YEAR FROM AGE(ed.exit_date, ed.start_date)) +
        EXTRACT(MONTH FROM AGE(ed.exit_date, ed.start_date)) / 12.0 +
        EXTRACT(DAY FROM AGE(ed.exit_date, ed.start_date)) / 365.25
    ) AS average_tenure_years
FROM employee_data AS ed
WHERE
    ed.exit_date IS NOT NULL -- Only consider exited employees for tenure calculation
    AND ed.title IS NOT NULL -- Ensure job function is recorded
GROUP BY ed.title
ORDER BY average_tenure_years DESC;
-- Observation: Overall, the average tenure varies significantly by job function, highlighting specific areas of strength in retention (e.g., certain IT and leadership roles) and areas of concern (e.g., some highly specialized IT/Data Architect roles, and senior leadership like CIO).