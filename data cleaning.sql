SELECT *
FROM layoffs;


-- Create a staging table
CREATE TABLE layoffs_staging
LIKE layoffs;


-- Copy the original data into the staging table
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


-- Check the staging table
SELECT *
FROM layoffs_staging;


-- Identify potential duplicates
SELECT *,
       ROW_NUMBER() OVER(
           PARTITION BY company,
                        industry,
                        total_laid_off,
                        percentage_laid_off,
                        `date`
       ) AS row_num
FROM layoffs_staging;


-- Create a CTE to identify duplicates
WITH duplicate_cte AS
(
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY company,
                            industry,
                            total_laid_off,
                            percentage_laid_off,
                            `date`,
							stage,
							country,
							funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte;

SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- Checking the duplicate data
SELECT * 
FROM layoffs_staging
WHERE company = 'Cazoo';


-- Making another table for deleting duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserting data
INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER(
           PARTITION BY company,
                        industry,
                        total_laid_off,
                        percentage_laid_off,
                        `date`,
                        stage,
                        country,
                        funds_raised_millions
       ) AS row_num
FROM layoffs_staging;


-- checking if it works
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Deleting duplicates
SET SQL_SAFE_UPDATES = 0;
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- Standadizing data(finding issuess and fixing it)
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company=TRIM(company);

SELECT distinct(industry) 
FROM layoffs_staging2
ORDER BY 1;


SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT distinct(industry)
FROM layoffs_staging2;

SELECT distinct(location)
FROM layoffs_staging2
ORDER BY 1;

SELECT distinct(country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT country, TRIM(country)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET country=TRIM(country);

SELECT date,
str_to_date(date , '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date=str_to_date(date, '%m/%d/%Y');

SELECT *
from layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY column date DATE;


-- 3. Null values/Blank

-- CHECKING FOR NULLS 
SELECT *
from layoffs_staging2
WHERE TOTAL_LAID_OFF IS NULL AND PERCENTAGE_LAID_OFF IS NULL;


SELECT *
from layoffs_staging2
where industry is null or industry = '';

select *
from layoffs_staging2
where company='Airbnb';

-- populating values where one is null and other is not null based on some match
select *
from layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

update layoffs_staging2
set industry = null
where industry = '';


update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company and t1.location = t2.location
set t1.industry = t2.industry
where (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


-- deleting rows we dont need
DELETE	
from layoffs_staging2
WHERE TOTAL_LAID_OFF IS NULL AND PERCENTAGE_LAID_OFF IS NULL;

select *
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;
