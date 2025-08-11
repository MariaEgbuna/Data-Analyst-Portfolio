-- Exploratory Analysis

-- Total employees laid off
SELECT SUM(total_laid_off) AS no_of_employees
FROM layoffs_staging AS ls;

-- Top 10 Countries with the highest number of employees laid off
SELECT country, SUM(total_laid_off) AS no_laid_off
FROM layoffs_staging AS ls
GROUP BY country
HAVING SUM(total_laid_off) > 0
ORDER BY 2 DESC
LIMIT 10;

--  Layoffs Over Time (Year)
SELECT DISTINCT EXTRACT (YEAR FROM date_laid_off) AS years, SUM(total_laid_off) AS no_of_employees
FROM layoffs_staging AS ls
GROUP BY EXTRACT (YEAR FROM date_laid_off)
ORDER BY 1;

-- Which industries were most affected?
SELECT industry, SUM(total_laid_off) AS no_of_employees
FROM layoffs_staging AS ls
GROUP BY industry
HAVING SUM(total_laid_off) > 0
ORDER BY 2 DESC;

-- Layoffs by Industry Per Year
SELECT industry, EXTRACT(YEAR FROM date_laid_off) AS years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE industry IS NOT NULL
GROUP BY industry, EXTRACT(YEAR FROM date_laid_off)
ORDER BY industry, years;

-- Industry layoffs Year-over-Year Change (YoY)
SELECT industry, years, total_laid_off, total_laid_off - LAG(total_laid_off) OVER ( PARTITION BY industry ORDER BY years) AS previous_year_change
FROM (
  	SELECT industry, EXTRACT(YEAR FROM date_laid_off)::INT AS years, SUM(total_laid_off) AS total_laid_off
  	FROM layoffs_staging
 	 WHERE industry IS NOT NULL
  	GROUP BY industry, EXTRACT(YEAR FROM date_laid_off)
) AS yearly_industry_layoffs
ORDER BY industry, years;

-- Companies with the most layoffs
SELECT company, SUM(total_laid_off) AS no_of_employees
FROM layoffs_staging AS ls
GROUP BY company
HAVING SUM(total_laid_off) > 0
ORDER BY 2 DESC ;

-- Companies with highest layoff percentages
SELECT company, SUM(percentage_laid_off) AS laid_off_percent
FROM layoffs_staging AS ls
GROUP BY company
HAVING SUM(percentage_laid_off) > 0
ORDER BY 2 DESC;

-- Are early-stage or late-stage companies laying off more?
SELECT stage, SUM(percentage_laid_off) AS percent_laid_off, SUM(total_laid_off) AS no_laid_off
FROM  layoffs_staging AS ls
GROUP BY stage
ORDER BY 1;

-- Do companies with more funding lay off fewer people? Or more?
SELECT company, SUM(funds_raised_millions) AS total_funds_raised, SUM(total_laid_off) AS no_laid_off
FROM layoffs_staging AS ls
GROUP BY company
HAVING SUM(funds_raised_millions) > 0
ORDER BY total_funds_raised DESC ;

-- Companies with Multiple Layoff Events
SELECT company, COUNT(*) AS layoff_events
FROM layoffs_staging AS ls
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY 2 DESC;

-- Layoff Events Over Time (Per Company)
SELECT company, EXTRACT(YEAR FROM date_laid_off) AS years, COUNT(*) AS events_in_year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY company, EXTRACT(YEAR FROM date_laid_off)
ORDER BY company, years;
