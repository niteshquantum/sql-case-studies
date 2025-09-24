use dmart;
--1. What day of the week does each week_date fall on?
--→ Find out which weekday (e.g., Monday, Tuesday) each sales week starts on.
select * from qt.clean_weekly_sales;

select distinct DATEName(WEEKDAY,week_date) weekday from qt.clean_weekly_sales;

--2. What range of week numbers are missing from the dataset?

select week_numbers from  (
select top 53 sales,ROW_NUMBER() over(order by sales) as week_numbers from qt.weekly_sales) w
where week_numbers not in ( select distinct week_number from qt.clean_weekly_sales);

--3. How many purchases were made in total for each year?
--→ Count the total number of transactions for every year in the dataset.

 select calendar_year,count(transactions) total_number_purchase from qt.clean_weekly_sales
 group by calendar_year;
 

--4. How much was sold in each region every month?
--→ Show total sales by region, broken down by month.

select region,month(week_date) months,sum(try_cast(sales as bigint)) as total_sales from qt.clean_weekly_sales
group by region ,month(week_date)
order by region,months;
 

--5. How many transactions happened on each platform?
--→ Count purchases separately for the online store and the physical store.
select platform,count(transactions) as number_transitions from qt.clean_weekly_sales
group by PLATFORM;


--6. What share of total sales came from Offline vs Online each month?
--→ Compare the percentage of monthly sales from the physical store vs. the online store.

with cte as (
select 
    month(week_date) months ,
	platform, sum(cast(sales as bigint)) sales
	--,sum(cast(sales as bigint))over() as months_sales
from qt.clean_weekly_sales
group by month(week_date) ,platform
--order by months ,platform
)
select months,platform,round(cast(sales as float)/ sum(cast(sales as bigint))over(partition by months),4)*100 as percentage from cte
order by months ,platform;


--7. What percentage of total sales came from each demographic group each year?
--→ Break down annual sales by customer demographics (e.g., age or other groupings).

select  calendar_year,demographic,round(cast(sales as float)/sum(sales)over(partition by calendar_year),4)*100 percentage

     from (
			select c.calendar_year,demographic ,
			sum(cast(sales as bigint)) sales
			from qt.clean_weekly_sales as c
			group by c.calendar_year,demographic
			--order by calendar_year,demographic
			) as c
-- another way

with sales_by_years as
(
	select  calendar_year, try_cast(sum(cast(sales as bigint)) as float) total
  from qt.clean_weekly_sales group by calendar_year
)
select c.calendar_year,demographic ,
round(sum(cast(sales as bigint))/s.total,4)*100 as percentage
from qt.clean_weekly_sales as c
join sales_by_years s on c.calendar_year=s.calendar_year
group by c.calendar_year,demographic,s.total;


--8. Which age groups and demographic categories had the highest sales in physical stores?
--→ Find out which age and demographic combinations contribute most to Offline-Store sales.

with cte as(
select age_band,demographic,sum(cast(sales as float)) sales from qt.clean_weekly_sales
where platform='Offline-Store' and age_band<>'unknown'
group by age_band,demographic )
select  age_band,demographic,sales from cte
where sales=( select max(sales) from cte);

---- another way
select top 1 age_band,demographic,sum(cast(sales as float)) sales from qt.clean_weekly_sales
where platform='Offline-Store' and age_band<>'unknown'
group by age_band,demographic
order by sales desc

-- another way
with cte as(
select age_band,demographic,sum(cast(sales as float)) sales ,
row_number()over(order by sum(cast(sales as float)) desc) rn
from qt.clean_weekly_sales
where platform='Offline-Store' and age_band<>'unknown'
group by age_band,demographic )
select  age_band,demographic,sales from cte where rn=1;

-- 9. Can we use the avg_transaction column to calculate average purchase size by year and platform? If not, how should we do it?
-- Check if the avg_transaction column gives us correct yearly average sales per transaction for Offline vs Online. 
--  If it doesn't, figure out how to calculate it manually (e.g., by dividing total sales by total transactions).

select calendar_year,
round( sum(case when platform='online-Store' then cast(sales as bigint) end )/ 
		cast(sum( case when platform='online-Store' then cast(transactions as bigint) end ) as float) ,2) as online_store
,round( sum( case when platform='offline-Store' then cast(sales as bigint) end )/ 
		cast(sum(case when platform='offline-Store' then cast(transactions as bigint) end ) as float),2)  as offline_store
from qt.clean_weekly_sales
group by calendar_year;


--### Pre-Change vs Post-Change Analysis
--This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

--Taking the week_date value of 2020-06-15 as the baseline week where the DMart sustainable packaging changes came into effect.

--We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

--1. What is the total sales for the 4 weeks pre and post 2020-06-15? What is the growth or reduction rate in actual values and percentage of sale

with postt as(
select sum(cast(sales as float)) as post from qt.clean_weekly_sales 
where week_date between '2020-06-15' and DATEADD(week,3,'2020-06-15') 
),previous as(
select sum(cast(sales as float)) as pre from qt.clean_weekly_sales 
where week_date between  DATEADD(week,-4,'2020-06-15') and '2020-06-14' 
)
select pre,post,post-pre value ,round( (post-pre)/cast(pre as float),4)*100 as percentage from postt,previous;

-- 2. What is the total sales for the 12 weeks pre and post 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

with postt as(
select sum(cast(sales as float)) as post from qt.clean_weekly_sales 
where week_date between '2020-06-15' and DATEADD(week,11,'2020-06-15') 
),previous as(
select sum(cast(sales as float)) as pre from qt.clean_weekly_sales 
where week_date between  DATEADD(week,-12,'2020-06-15') and '2020-06-14' 
)
select pre,post,post-pre value ,round( (post-pre)/cast(pre as float),4)*100 as percentage from postt,previous;

-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
with postt as(
select sum(cast(sales as float)) as post from qt.clean_weekly_sales 
where week_date between '2018-06-15' and DATEADD(week,11,'2018-06-15') 
),previous as(
select sum(cast(sales as float)) as pre from qt.clean_weekly_sales 
where week_date between  DATEADD(week,-12,'2018-06-15') and '2018-06-14' 
),
postt2 as(
select sum(cast(sales as float)) as post from qt.clean_weekly_sales 
where week_date between '2019-06-15' and DATEADD(week,11,'2019-06-15') 
),previous2 as(
select sum(cast(sales as float)) as pre from qt.clean_weekly_sales 
where week_date between  DATEADD(week,-12,'2019-06-15') and '2019-06-14' 
)
select 2018 years , pre,post,post-pre value ,round( (post-pre)/cast(pre as float),4)*100 as percentage from postt,previous

union all

select 2019 years, pre,post,post-pre value ,round( (post-pre)/cast(pre as float),4)*100 as percentage from postt2,previous2;


-- ### Bonus Question
-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

-- 1. region
-- 2. platform
-- 3. age_band
-- 4. demographic
-- 5. customer_type


with post as(
select * from qt.clean_weekly_sales 
where week_date between '2020-06-15' and DATEADD(week,11,'2020-06-15') and age_band<>'Unknown')
,pre as(
select * from qt.clean_weekly_sales 
where week_date between  DATEADD(week,-12,'2020-06-15') and '2020-06-14'and age_band<>'Unknown')
 --,region_s as (
        select distinct
       region , sum(cast(sales as float))over(partition by region) as max_region
       from post
        )


	-- ### Bonus Question
-- Which areas of the business have the highest negative impact in sales metrics performance 
-- in 2020 for the 12 week before and after period?
   
-- 1. region
-- 2. platform
-- 3. age_band
-- 4. demographic
-- 5. customer_type

select top 5 * from qt.clean_weekly_sales;

with postt as(
select sum(cast(sales as float)) as post from qt.clean_weekly_sales 
where week_date between '2020-06-15' and DATEADD(week,11,'2020-06-15') 
),previous as(
select sum(cast(sales as float)) as pre from qt.clean_weekly_sales 
where week_date between  DATEADD(week,-12,'2020-06-15') and '2020-06-14' )
------------------




-- 1. region
-- 2. platform
-- 3. age_band
-- 4. demographic
-- 5. customer_type

select top 5 * from qt.clean_weekly_sales;


-- 1. region,2. platform ,3. age_band ,4. demographic ,5. customer_type


--------------
with post as (
		select * from qt.clean_weekly_sales 
		where week_date between '2020-06-15' and DATEADD(week,11,'2020-06-15')
		and age_band<>'unknown'
		
		)
,region_s as (
       select distinct top 1
       region , sum(cast(sales as float))over(partition by region) as max_region
       from post 
       order by max_region desc )
,platform_s as(
       select distinct top 1
       platform , sum(cast(sales as float))over(partition by platform ) as max_platform
       from post 
       order by max_platform desc )
,age_band_s as (
       select distinct top 1
       age_band , sum(cast(sales as float))over(partition by age_band ) as max_age_band
       from post 
       order by max_age_band desc )
,demographic_s as (
       select distinct top 1
       demographic , sum(cast(sales as float))over(partition by demographic ) as max_demographic
       from post 
       order by max_demographic desc )
,customer_type_s as (
       select distinct top 1
       customer_type , sum(cast(sales as float))over(partition by customer_type ) as max_customer_type
       from post 
       order by max_customer_type desc )
select * from region_s,platform_s,age_band_s,demographic_s,customer_type_s;