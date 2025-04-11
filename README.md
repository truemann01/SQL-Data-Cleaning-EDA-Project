# SQL-Data-Cleaning-Project "Tech-Layoffs-Dataset"
##Project Description 
In this project, I performed data cleaning on a real-world dataset involving global tech layoffs. The dataset was sourced from The Analyst Builder GitHub and is licensed under Creative Commons. The goal was to clean and prepare the data for analysis using SQL in MySQL Workbench.


-- SQL Data Cleaning Script for Tech Layoffs Dataset

-- STEP 1: Create new schema
-- (Using MySQL Workbench GUI: Create Schema > Name it 'world_layoffs' > Apply)

-- STEP 2: Import CSV into a new table named 'layoffs' under 'world_layoffs' schema
-- (Use Table Data Import Wizard via GUI)

-- STEP 3: Create first staging table
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;

-- STEP 4: Add row number to identify duplicates
SELECT *,
       ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- STEP 5: Create second staging table
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
);

-- STEP 6: Populate second staging table
INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- STEP 7: Delete duplicate rows
DELETE FROM layoffs_staging2 WHERE row_num > 1;

-- STEP 8: Standardize data - Trim company name spaces
UPDATE layoffs_staging2 SET company = TRIM(company);

-- STEP 9: Standardize industry name 'cryptocurrency' to 'crypto'
UPDATE layoffs_staging2 SET industry = 'crypto' WHERE industry LIKE 'crypto%';

-- STEP 10: Fix special character in location
UPDATE layoffs_staging2 SET location = 'Düsseldorf' WHERE location LIKE 'DÃ¼sseldorf%';

-- STEP 11: Remove trailing periods from country names
UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'United States%';

-- STEP 12: Convert date column to proper DATE format
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;

-- STEP 13: Handle blank and null values in industry column
UPDATE layoffs_staging2 SET industry = NULL WHERE industry = '';

-- Use self join to fill in missing industry values
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- STEP 14: Delete rows where both total_laid_off and percentage_laid_off are NULL
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- STEP 15: Drop the row_num column
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;
