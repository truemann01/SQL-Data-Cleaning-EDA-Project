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
- STEP 1: Create Staging Table
  
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging SELECT * FROM layoffs;

- STEP 2: Add Row Number for Duplicate Identification
ALTER TABLE layoffs_staging ADD COLUMN row_num INT;

WITH duplicate_cte AS (
  SELECT *,
  ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, 
    total_laid_off, percentage_laid_off, 
    date, stage, country, funds_raised_millions
  ) AS row_num
  FROM layoffs_staging
)
DELETE FROM layoffs_staging WHERE row_num > 1;

-- STEP 3: Standardize Text Data
-- Trim whitespace from company names
UPDATE layoffs_staging 
SET company = TRIM(company);

-- Normalize industry names (e.g., Cryptocurrency → Crypto)
UPDATE layoffs_staging
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

-- Fix special characters in location column
UPDATE layoffs_staging
SET location = 'Düsseldorf' 
WHERE location LIKE 'DÃ¼sseldorf%';

-- STEP 4: Convert Date Format and Update Data Type
UPDATE layoffs_staging
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging 
MODIFY COLUMN date DATE;

-- STEP 5: Handle Null Values
-- Replace blanks with NULL in the industry column
UPDATE layoffs_staging
SET industry = NULL 
WHERE industry = '';

-- Impute missing values using self-join (e.g., fill NULL industries)
UPDATE layoffs_staging t1
JOIN layoffs_staging t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
  AND t2.industry IS NOT NULL;

-- STEP 6: Remove Irrelevant Data
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL 
  AND percentage_laid_off IS NULL;

-- Drop unnecessary columns (e.g., row_num)
ALTER TABLE layoffs_staging DROP COLUMN row_num;
