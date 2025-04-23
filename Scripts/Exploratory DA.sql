# Exploratory Data Analysis

Select *
from layoffs_staging2;

# Maximum number of people laid off in one company.
Select max(total_laid_off)
from layoffs_staging2;

Select *
from layoffs_staging2
where total_laid_off = 12000;

# maximum of percentage laid in each company. Note that 1 = 100%
Select max(percentage_laid_off)
from layoffs_staging2;

Select *
from layoffs_staging2
where percentage_laid_off = 1;

# using the Order by statement, i want to know which company had the highest number of people laid off among all the companies that went under.
Select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

# using group by to sum total laid off of each specific company in different year 
select min(`date`), max(`date`)
from layoffs_staging2;

#By Date
Select `date`, sum(total_laid_off)
from layoffs_staging2
group by `date` 
order by 2 desc; 

Select company, sum(total_laid_off)
from layoffs_staging2
group by company 
order by 2 desc; 

select *
from layoffs_staging2
where company = 'Amazon';

#By industry
Select industry, sum(total_laid_off)
from layoffs_staging2
group by industry 
order by 2 desc; 

#By Country
Select country, sum(total_laid_off)
from layoffs_staging2
group by country 
order by 2 desc; 

#By year, using the year function
Select Year(`date`), sum(total_laid_off)
from layoffs_staging2
group by Year(`date`) 
order by 1 desc; 

select * 
from layoffs_staging2;

#By company stage
Select stage, sum(total_laid_off)
from layoffs_staging2
group by stage 
order by 2 desc; 

#Rolling total
select substring(`date`,6,2) as `Month`
from layoffs_staging2;

select substring(`date`,1,7) as `Month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;

with Rolling_total as 
(
select substring(`date`,1,7) as `Month`, sum(total_laid_off) as total_layoff
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`, total_layoff, sum(total_layoff) over(order by `month`) as Roll_total
from Rolling_total;

# company by Ranking 

select company, sum(total_laid_off)
from layoffs_staging2
group by company 
order by 2 desc;


select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

with company_year (company, years, total_laid_off)  as 
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
)
select *, dense_rank() over (partition by years order by total_laid_off desc) as Ranking
from company_year
where years is not null
order by Ranking asc;

# added another cte

with company_year (company, years, total_laid_off)  as 
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_year_rank as 
(
select *, dense_rank() over (partition by years order by total_laid_off desc) as Ranking
from company_year
where years is not null
)
select *
from Company_year_rank
where Ranking <= 5;
