# SQL-Data-Cleaning-Project & EDA "Tech-Layoffs-Dataset"
## Project Overview
In this project, I performed data cleaning on a real-world dataset tracking global tech layoffs from 2020–2023. The dataset, originally sourced from The Analyst Builder GitHub, was cleaned and prepared using SQL in MySQL Workbench.

This was a hands-on demonstration of how to handle:

- messy real-world data,

- duplicates,

- missing values,

- and inconsistent formatting — all within SQL.

## Dataset Used 
- <a href="https://github.com/truemann01/SQL-Data-Cleaning-Project/blob/main/Data/layoffs.csv">Tech-Layoffs-Dataset</a>

## 🛠️ Tools Used
- MySQL Workbench

- SQL

- GUI-based Data Import Wizard

  ## 📁 Dataset Summary
- Source: Tech Layoffs Dataset
- License: Creative Commons
- Years Covered: 2020 - 2023

Key fields include:

- company
- location
- industry
- total_laid_off
- percentage_laid_off
- date
- stage
- country
- funds_raised_millions

 ##  📌 Project Workflow

🔹 1. Database Setup
Created a new schema in MySQL called world_layoffs.

Used the GUI import wizard to load the raw CSV file into a new table called layoffs.

🔹 2. Create Staging Tables
Created layoffs_staging as a working copy of the original data.

Created a second table layoffs_staging2 for refined cleaning to preserve each step and avoid modifying the raw data.

🔹 3. Remove Duplicates
Added a row_number() column using a PARTITION BY clause to detect duplicates.

Created a Common Table Expression (CTE) to identify duplicate records.

Verified and deleted duplicate rows.

🔹 4. Standardize Text Fields
Trimmed unnecessary white spaces from the company column.

Fixed inconsistent industry names, e.g., "cryptocurrency" to "crypto".

Cleaned special characters in the location field (e.g., "DÃ¼sseldorf" to "Düsseldorf").

Removed trailing punctuation from country names like “United States.”

🔹 5. Date Formatting
Converted the date column from TEXT to DATE using STR_TO_DATE() and ALTER TABLE.

🔹 6. Handling Null and Blank Values
Replaced blank strings with NULL for accurate analysis.

Used self-joins to populate missing industry values by matching records with the same company name that had non-null entries.

🔹 7. Remove Irrelevant Data
Deleted rows where both total_laid_off and percentage_laid_off were null.

Dropped the temporary row_num column as it was no longer needed.


 
### SQL Code

```sql

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

-- Use a CTE to isolate duplicate rows
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
``` 
## Final Result 

- <a href="https://github.com/truemann01/SQL-Data-Cleaning-Project/blob/main/Data/Final%20result.csv">layoffs_staging2</a>
- <a href="https://github.com/truemann01/SQL-Data-Cleaning-Project/blob/main/Snapshots/2025-04-11%20(7).png">snapshot</a>


## 📊 Part 2: Exploratory Data Analysis (EDA)

Using SQL queries, I explored patterns and trends in the cleaned layoffs data:

- Top companies by number of layoffs
- Trends across industries and countries
- Monthly and yearly layoff patterns
- Companies that laid off 100% of staff

## SQL script

```SQL
-- Description: SQL queries to explore trends and patterns in global tech layoffs.

USE world_layoffs;

-- 📌 1. Top Companies with the Most Layoffs
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- 📌 2. Total Layoffs Per Industry
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- 📌 3. Layoffs by Country
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- 📌 4. Yearly Layoffs Trend
SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY year;

-- 📌 5. Monthly Layoffs Trend
SELECT DATE_FORMAT(`date`, '%Y-%m') AS month, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY month
ORDER BY month;

-- 📌 6. Percentage Layoffs by Stage of Company
SELECT stage, COUNT(*) AS count, SUM(percentage_laid_off) AS total_percent
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_percent DESC;

-- 📌 7. Companies with 100% Layoffs
SELECT company, `date`, total_laid_off, percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = '100%';

-- 📌 8. Timeline of Layoffs for Top 5 Companies
SELECT company, DATE_FORMAT(`date`, '%Y-%m') AS month, SUM(total_laid_off) AS layoffs
FROM layoffs_staging2
WHERE company IN (
  SELECT company
  FROM layoffs_staging2
  GROUP BY company
  ORDER BY SUM(total_laid_off) DESC
  LIMIT 5
)
GROUP BY company, month
ORDER BY month, company;

```


This dataset is now cleaned, Analysed and ready for: 
- Further Analysis can be done (I'm open for collaboration)
- Visualisation
- Reporting

## Key Learnings
- Staging Environments: Essential for preserving raw data integrity

- Window Functions: Powerful for complex duplicate detection

- Transactional Updates: Always test UPDATE/DELETE with SELECT first

- Data Type Validation: Crucial for temporal analysis readiness

## 🚀 Thanks for reading!
Want to connect or collaborate? Let’s chat on <a href="https://www.linkedin.com/in/anderson-igbah?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app">LinkedIn</a> 

