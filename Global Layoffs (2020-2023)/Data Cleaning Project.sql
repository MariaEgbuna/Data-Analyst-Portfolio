-- Data Cleaning Project

-- Steps to clean data
-- 1. Remove Duplicates (If any)
-- 2. Standardize the data
-- 3. Null or Blank Values
-- 4. Remove unnecessary columns

-- Create staging dataset (copy of the dataset)
CREATE TABLE layoffs_staging
(
	LIKE layoffs_raw
	INCLUDING ALL 
);

-- Inserting all data from raw file
INSERT INTO layoffs_staging
SELECT *
FROM layoffs_raw;

-- 1. REMOVING DUPLICATES

-- Checking for duplicates using partition by for ALL columns
WITH duplicate_count AS 
(
	SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY company, company_location, industry, total_laid_off, percentage_laid_off, date_laid_off, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging AS ls
)
SELECT *
FROM duplicate_count
WHERE row_num > 1;

-- Deleting duplicates
WITH duplicate_count AS 
(
	SELECT ctid, 
	ROW_NUMBER() OVER(PARTITION BY company, company_location, industry, total_laid_off, percentage_laid_off, date_laid_off, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging AS ls
)
DELETE 
FROM layoffs_staging
WHERE ctid IN ( SELECT ctid FROM duplicate_count WHERE row_num > 1);

-- 2. STANDARDIZING THE DATA

-- checking for extra spaces
SELECT company, TRIM(company)
FROM layoffs_staging AS ls;

-- removing extra spaces
UPDATE layoffs_staging
SET company = TRIM(company);

-- update duplicate industry names
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry ILIKE 'Crypto%';

-- updating company loactions for düsseldorf
UPDATE layoffs_staging
SET company_location = 'Düsseldorf'
WHERE company_location ILIKE 'Dusseldorf';

-- updating company loactions for malmö
UPDATE layoffs_staging
SET company_location = 'Malmö'
WHERE company_location ILIKE 'Malmo';

-- updating country name USA
UPDATE layoffs_staging
SET country = 'United States'
WHERE country ILIKE 'United States%';

-- converting the date_laid_off to type DATE
SELECT date_laid_off, to_date(date_laid_off, 'MM-DD-YYYY') AS converted_date
FROM layoffs_staging AS ls;

SELECT *
FROM layoffs_staging AS ls
WHERE date_laid_off ILIKE 'NU%';

-- update the row that had NULL as a string
UPDATE layoffs_staging AS ls
SET date_laid_off = NULL
WHERE date_laid_off ILIKE 'NU%';

-- update to date format
UPDATE layoffs_staging AS ls
SET date_laid_off = to_date(date_laid_off,  'MM-DD-YYYY');

-- change data type from VARCHAR to DATE
ALTER TABLE layoffs_staging
ALTER COLUMN date_laid_off TYPE date USING date_laid_off::date;

-- 3. WORKING WITH NULL AND BLANK VALUES

-- updated colums that had NULL as text
UPDATE layoffs_staging AS ls
SET total_laid_off = NULL
WHERE total_laid_off ILIKE 'NU%';

UPDATE layoffs_staging AS ls
SET percentage_laid_off = NULL
WHERE percentage_laid_off ILIKE 'NU%';

UPDATE layoffs_staging AS ls
SET funds_raised_millions = NULL
WHERE funds_raised_millions ILIKE 'NU%';

UPDATE layoffs_staging
SET Industry = NULL
WHERE Industry = '';

UPDATE layoffs_staging
SET stage = NULL
WHERE stage ILIKE 'NULL%';

-- populating data (where industry is NULL is some places)
SELECT ls1.company,  ls1.industry, ls2.company, ls2.industry
FROM layoffs_staging AS ls1
JOIN layoffs_staging AS ls2
	ON ls1.company = ls2.company
WHERE ls1.industry IS NULL
AND ls2.industry IS NOT NULL;

UPDATE layoffs_staging ls1
SET industry = ls2.industry
FROM layoffs_staging ls2
WHERE ls1.company = ls2.company
  AND ls1.industry IS NULL
  AND ls2.industry IS NOT NULL;

-- altering [total_laid_off, percentage_laid_off, funds_raised_millions] data type
-- Convert total_laid_off to INTEGER
ALTER TABLE layoffs_staging
ALTER COLUMN total_laid_off TYPE INTEGER
USING total_laid_off::INTEGER;

-- Convert percentage_laid_off to FLOAT
ALTER TABLE layoffs_staging
ALTER COLUMN percentage_laid_off TYPE FLOAT
USING percentage_laid_off::FLOAT;

-- Convert funds_raised_millions to FLOAT
ALTER TABLE layoffs_staging
ALTER COLUMN funds_raised_millions TYPE FLOAT
USING funds_raised_millions::FLOAT;

-- 4. REMOVE UNNECESSARY COLUMNS
DELETE
FROM	layoffs_staging AS ls
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
