
select *
from world_layoffs.layoffs;


-- 1. Remove duplicates 
-- 2. Standardize the Data (spelling errors)
-- 3. treat null values and Blank values
-- 4. Remove unneccessary columns ( create a staging table to do this)

Create table layoffs_staging
like layoffs;

select * 
from layoffs_staging;

Insert layoffs_staging
select *
from layoffs;

select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) As row_num
from layoffs_staging;

with duplicate_cte As
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) As row_num
from layoffs_staging
)
select * 
from duplicate_cte
where row_num > 1;

select * 
from layoffs_staging
where company = 'cazoo';


select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) As row_num
from layoffs_staging;

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

select * 
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) As row_num
from layoffs_staging;

select * 
from layoffs_staging2
where row_num > 1;

delete 
from layoffs_staging2
where row_num > 1;

select distinct (trim(company))
from layoffs_staging2;

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry = 'crypto'
where industry like 'crypto%';

select distinct country
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where location like 'DÃ¼sseldorf%';

update layoffs_staging2
set location = 'Düsseldorf'
where location like 'DÃ¼sseldorf%';

select *
from layoffs_staging2
where country like 'united states%'
order by 1;

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';


select `date`
from layoffs_staging2;

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;

select distinct industry
from layoffs_staging2
order by 1;

select * 
from layoffs_staging2
where industry is null
or industry = '';


update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';


select *
from layoffs_staging2 t1
join layoffs_staging2 t2
   on t1.company = t2.company
   where (t1.industry is null and t2.industry is not null);
   
   select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
   on t1.company = t2.company
   where (t1.industry is null and t2.industry is not null);
   
   update layoffs_staging2 t1
   join layoffs_staging2 t2
   on t1.company = t2.company
   set t1.industry = t2.industry
   where (t1.industry is null and t2.industry is not null);
   
#deleting rows and columns 

select *
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;

#Data cleaning project by Azuka Igbah