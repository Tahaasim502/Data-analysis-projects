select * 
from layoffs_staging2;

-- 1. Which companies/industries were hit hardest — in absolute and relative terms?
SELECT company, industry, total_laid_off, funds_raised_millions
FROM layoffs_staging2
WHERE percentage_laid_off = '1'
ORDER BY funds_raised_millions DESC;

-- 2. layoffs over time (monthly/yearly trend + a turning point)
select year(date), sum(total_laid_off)
from layoffs_staging2
group by year(date)
order by year(date) asc;

with month_cte AS
(
	select date_format(date, '%Y-%m') as month, sum(total_laid_off) as total_laid_off
	from layoffs_staging2
    where date is not null
	group by month
)

select *,sum(total_laid_off) over (order by month) as rolling_total
from month_cte
order by month;


-- Q3: Did well-funded companies lay off proportionally more or less than poorly-funded ones?
select company, industry, funds_raised_millions, percentage_laid_off
from layoffs_staging2
where funds_raised_millions > 100
order by percentage_laid_off desc;


-- Q4: Which companies had repeat rounds of layoffs, and how far apart were they?
select *
from (
    select company, date, 
           lag(date) over(partition by company order by date) as prev_date_round_layoff,
           datediff(date, lag(date) over(partition by company order by date)) as days_last_layoff
    from layoffs_staging2
) t
where prev_date_round_layoff is not null;
    
