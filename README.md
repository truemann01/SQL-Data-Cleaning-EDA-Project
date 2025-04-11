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
Key Cleaning Steps
1. Database Setup & Data Import
sql
-- Created database
CREATE SCHEMA `world_layoffs`;

-- Imported raw data using GUI Table Data Import Wizard
-- Preserved original data types during initial import
2. Staging Environment Setup
sql
-- Created staging tables to preserve raw data
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;

-- Added row number for duplicate identification
ALTER TABLE layoffs_staging2 ADD COLUMN row_num INT;
3. Duplicate Removal
Technique Used: Window functions + CTE

sql
WITH duplicate_cte AS (
  SELECT *,
  ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, 
    total_laid_off, percentage_laid_off, 
    date, stage, country, funds_raised_millions
  ) AS row_num
  FROM layoffs_staging2
)
DELETE FROM layoffs_staging2 WHERE row_num > 1;
Result: Removed 12 duplicate records

4. Data Standardization
A. Text Cleaning

sql
-- Trim whitespace
UPDATE layoffs_staging2 
SET company = TRIM(company);

-- Industry normalization
UPDATE layoffs_staging2
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

-- Special character handling
UPDATE layoffs_staging2
SET location = 'Düsseldorf' 
WHERE location LIKE 'DÃ¼sseldorf%';
B. Date Conversion

sql
-- Convert text to DATE type
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging2 
MODIFY COLUMN date DATE;
5. Null Value Treatment
A. Blank → NULL Conversion

sql
UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';
B. Self-Join Imputation

sql
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
  AND t2.industry IS NOT NULL;
C. Irrelevant Data Removal

sql
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL 
  AND percentage_laid_off IS NULL;
Final Output
Cleaned Dataset Metrics:

Removed duplicates: 12 records

Standardized industries: 3 categories corrected

Fixed date formats: 100% conversion success

Null values reduced: 87.5% decrease

Schema Optimization:

sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
