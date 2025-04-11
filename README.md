# SQL-Data-Cleaning-Project "Tech-Layoffs-Dataset"
## Project Description 
In this project, I performed data cleaning on a real-world dataset involving global tech layoffs. The dataset was sourced from The Analyst Builder GitHub and is licensed under Creative Commons. The goal was to clean and prepare the data for analysis using SQL in MySQL Workbench.

## Dataset Used 
- <a href="https://github.com/truemann01/SQL-Data-Cleaning-Project/blob/main/layoffs.csv">Tech-Layoffs-Dataset</a>

## 🛠️ Tools Used
- MySQL Workbench

- SQL

- GUI-based Data Import Wizard

  ## 📁 Dataset
 The dataset contains records of company layoffs globally from 2020 to 2023, including:

- Company name

- Location

- Industry

- Number of employees laid off

- Date

- Stage of company

- Country

- Funds raised

 ##  📌 Project Workflow
### SQL Code

```sql
-- SQL Data Cleaning Project - Tech Layoffs Dataset

-- Downloaded this dataset from The Analyst Builder GitHub (under CC rights)

-- First, I created a new database called world_layoffs using the GUI:
-- Click on “Create New Schema”, renamed it to world_layoffs, clicked Apply (twice), then Finish

-- After that, I imported the dataset using the Table Data Import Wizard
-- Right-click on Tables under world_layoffs schema, choose "Table Data Import Wizard"
-- Browsed and selected the raw dataset "layoffs.csv"
-- MySQL auto-detected the column data types. I didn’t make changes. Just clicked Next, then Finish

-- Viewing the raw dataset
SELECT * FROM world_layoffs.layoffs;

-- Cleaning plan:
-- 1. Remove duplicates
-- 2. Standardize the data (spelling, formatting)
-- 3. Handle nulls and blanks
-- 4. Remove unnecessary rows and columns

-- To avoid modifying the raw dataset, I created a staging table
CREATE TABLE layoffs_staging LIKE layoffs;

-- Populating the staging table
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- Dataset didn’t have unique IDs, so I added row numbers
SELECT *,
       ROW_NUMBER() OVER (
         PARTITION BY company, location, industry, total_laid_off,
         percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

-- Created a CTE to help find and filter duplicates
WITH duplicate_cte AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off,
           percentage_laid_off, `date`, stage, country, funds_raised_millions
         ) AS row_num
  FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

-- Verified duplicates manually
SELECT * FROM layoffs_staging WHERE company = 'cazoo';

-- Created a second staging table to safely delete duplicates
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

-- Populated it with data and added row numbers again
INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
         PARTITION BY company, location, industry, total_laid_off,
         percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

-- Identified duplicates
SELECT * FROM layoffs_staging2 WHERE row_num > 1;

-- Make sure safe updates is off in preferences before deleting
DELETE FROM layoffs_staging2 WHERE row_num > 1;

-- Standardizing data: removing extra spaces in company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Fixing inconsistent industry names like "cryptocurrency"
UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

-- Fixing special character issue in location
UPDATE layoffs_staging2
SET location = 'Düsseldorf'
WHERE location LIKE 'DÃ¼sseldorf%';

-- Removing trailing dots from country names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Formatting the date column from string to date
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Handling blanks and nulls in industry
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Filling null industries using company matches
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Removing rows where both total_laid_off and percentage_laid_off are null
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Dropping the row_num column since it’s no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


