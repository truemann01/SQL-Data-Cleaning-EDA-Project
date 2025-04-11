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
SELECT *,
       ROW_NUMBER() OVER(
         PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

