select * from adinsight_analytics.interest_map;
select * from adinsight_analytics.interest_metrics;

--**AdInsight Analytics: Case Study Questions**

--The following are core business questions designed to be explored using SQL queries and logical reasoning. These will help AdInsight Analytics gain actionable insights into customer behavior and interest segmentation.

-----

--### Data Exploration and Cleansing
-- ******************************************************************************************************************************************************************************************************************************************************************************************
--1. Update the `month_year` column in `adinsight_analytics.interest_metrics` to be of `DATE` type, with values representing the first day of each month.

select month_year, TRY_CAST(CONCAT(year,'-',month,'-01') as date) month_start from adinsight_analytics.interest_metrics;

/*
update adinsight_analytics.interest_metrics
set month_year=try_cast(concat(year,'-',month,'-01')  as date)

select * from  adinsight_analytics.interest_metrics;

alter table adinsight_analytics.interest_metrics
alter column month_year date;

*/

-- ******************************************************************************************************************************************************************************************************************************************************************************************
--2. Count the total number of records for each `month_year` in the `interest_metrics` table, sorted chronologically, ensuring that NULL values (if any) appear at the top.

select month_year , count(*) as total_number_record from adinsight_analytics.interest_metrics
group by month_year
order by month_year;

-- ******************************************************************************************************************************************************************************************************************************************************************************************
--3. Based on your understanding, what steps should be taken to handle NULL values in the `month_year` column?

select month_year  from adinsight_analytics.interest_metrics
group by month_year
having month_year is not null;

-- or count kr denge unko alg

SELECT 
  ISNULL(try_cast(month_year as varchar), 'Missing Date') AS month_report,
  COUNT(*) AS total_records
FROM adinsight_analytics.interest_metrics
GROUP BY month_year;

-- using convert fun

SELECT 
  ISNULL(CONVERT(VARCHAR, month_year, 23), 'Missing Date') AS month_report,
  COUNT(*) AS total_records
FROM adinsight_analytics.interest_metrics
GROUP BY month_year;

-- ******************************************************************************************************************************************************************************************************************************************************************************************
--4. How many `interest_id` values exist in `interest_metrics` but not in `interest_map`? And how many exist in `interest_map` but not in `interest_metrics`?

-- with exists
with metrics as (
select count(distinct interest_id) metrics_not_in_map  from adinsight_analytics.interest_metrics
where not exists (select distinct id  from adinsight_analytics.interest_map where id=interest_id)
), map as (
select count( distinct id) map_not_in_metrics from adinsight_analytics.interest_map
where not exists (select distinct id  from adinsight_analytics.interest_metrics where interest_id=id)
)
select * from metrics,map;

-- with set

with metrics as 
(	select count(*) metrics_not_map from (select  interest_id from adinsight_analytics.interest_metrics
	where interest_id is not null
	except
	select id from adinsight_analytics.interest_map) as me
) , map as
(	select count(*) map_not_metric  from (select id from adinsight_analytics.interest_map
	where id is not null
	except
	select  interest_id from adinsight_analytics.interest_metrics) as ma
	)
select * from metrics,map;

-- with join
with metrics as (
select count (distinct interest_id) metrics_not_map from adinsight_analytics.interest_metrics me left join adinsight_analytics.interest_map ma
on me.interest_id=ma.id where id is null and interest_id is not null
) , map as (
select count( distinct id) map_not_metrics from adinsight_analytics.interest_map ma left join adinsight_analytics.interest_metrics me 
on ma.id=me.interest_id where interest_id is null  and id is not null
)
select * from metrics,map;


-- ******************************************************************************************************************************************************************************************************************************************************************************************
--5. Summarize the `id` values from the `interest_map` table by total record count.

select id, interest_name ,count(me.interest_id) as total_record_count from adinsight_analytics.interest_map map left join adinsight_analytics.interest_metrics
me on map.id=me.interest_id
group by id,interest_name
order by total_record_count desc;

-- ******************************************************************************************************************************************************************************************************************************************************************************************
--6. What type of join is most appropriate between the `interest_metrics` and `interest_map` tables for analysis? 
-- Justify your approach and verify it by retrieving data where `interest_id = 21246`, 
-- including all columns from `interest_metrics` and all except `id` from `interest_map`.

select month,year,month_year,interest_id,composition,index_value,ranking,percentile_ranking,interest_name,interest_summary,created_at,last_modified 
from adinsight_analytics.interest_metrics me join adinsight_analytics.interest_map ma
on me.interest_id=ma.id
where interest_id=21246;

----or
select me.* , interest_name,interest_summary,created_at,last_modified 
from adinsight_analytics.interest_metrics me join adinsight_analytics.interest_map ma
on me.interest_id=ma.id
where interest_id=21246;


-- ******************************************************************************************************************************************************************************************************************************************************************************************
--7. Are there any rows in the joined data where `month_year` is earlier than `created_at` in `interest_map`?
-- Are these values valid? Why or why not?

select month_year,interest_id,created_at from adinsight_analytics.interest_metrics me join adinsight_analytics.interest_map ma
on me.interest_id=ma.id
where month_year<created_at


--### Interest Analysis


-- *******************************************************************************************************************************************************************************************************
--8. Which interests appear consistently across all `month_year` values in the dataset?

with t1 as (
select interest_id,count(distinct month_year) as month_count
from adinsight_analytics.interest_metrics
where month_year is not null
group by interest_id
), t2 as (
select count (distinct month_year) m from adinsight_analytics.interest_metrics
where month_year is not null
)
select interest_id ,m.interest_name from t1 join adinsight_analytics.interest_map m
on t1.interest_id=m.id
where month_count=(select m from t2)

--or 
-- only intrest id
SELECT interest_id FROM adinsight_analytics.interest_metrics
GROUP BY interest_id
HAVING  COUNT(DISTINCT month_year) = ( SELECT COUNT(DISTINCT month_year) 
										FROM adinsight_analytics.interest_metrics );


-- *******************************************************************************************************************************************************************************************************
--9. Calculate the cumulative percentage of interest records starting from those present in 14 months. 
-- What is the `total_months` value where the cumulative percentage surpasses 90%?

with t1 as (
select interest_id ,count(distinct month_year) as total_months from adinsight_analytics.interest_metrics
where month_year is not null
group by interest_id ),t2 as (
select total_months,COUNT(*) as total_m_freq from t1
group by total_months ) ,t3 as (
select *,sum(total_m_freq)over(order by total_months desc) as cumulative_sum,sum(total_m_freq)over() as total_freq from t2 ) ,t4 as (
select * , round(cumulative_sum/cast(total_freq as float),4)*100 cumulative_percentage from t3 )
select  total_months from t4 where cumulative_percentage>90;

-- or niche cumulative distribution se

with t1 as (
select  interest_id,count(distinct month_year) m  from adinsight_analytics.interest_metrics
where month is not null
group by interest_id
),
t2 as (
select interest_id,m,round(CUME_DIST()over(order by m desc),4)*100 as cum from t1
)
select distinct m as toal_months from t2 where cum>90;

-- *******************************************************************************************************************************************************************************************************
--10. If interests with `total_months` below this threshold are removed, how many records would be excluded?

with t1 as (
select interest_id ,count(distinct month_year) as total_months from adinsight_analytics.interest_metrics
where month_year is not null
group by interest_id ),t2 as (
select total_months,COUNT(*) as total_m_freq from t1
group by total_months ) ,t3 as (
select *,sum(total_m_freq)over(order by total_months desc) as cumulative_sum,sum(total_m_freq)over() as total_freq from t2 ) ,t4 as (
select * , round(cumulative_sum/cast(total_freq as float),4)*100 cumulative_percentage from t3 ) ,below_threshold_total_months as
(
select  total_months from t4 where cumulative_percentage<90 ) ,below_threshold_intrest_id as (
select interest_id from t1 join below_threshold_total_months bm on t1.total_months=bm.total_months )

select count(*) as total_record_below_threshold from adinsight_analytics.interest_metrics im
where month_year is not null and exists ( select 1 from below_threshold_intrest_id bi where bi.interest_id=im.interest_id); 
-- ***********************************************************************************************************************
--11. Evaluate whether removing these lower-coverage interests is justified from a business perspective.
-- Provide a comparison between a segment with full 14-month presence and one that would be removed.

with t1 as (
select interest_id ,count(distinct month_year) as total_months from adinsight_analytics.interest_metrics
where month_year is not null
group by interest_id ),t2 as (
select total_months,COUNT(*) as total_m_freq from t1
group by total_months ) ,t3 as (
select *,sum(total_m_freq)over(order by total_months desc) as cumulative_sum,sum(total_m_freq)over() as total_freq from t2 ) ,t4 as (
select * , round(cumulative_sum/cast(total_freq as float),4)*100 cumulative_percentage from t3 ) ,below_threshold_total_months as
(
select  total_months from t4 where cumulative_percentage<90 ) ,below_threshold_intrest_id as (
select interest_id from t1 join below_threshold_total_months bm on t1.total_months=bm.total_months )
, lower_coverage as (
select 'Lower Coverage ' as record,
       count(distinct month_year) as uniqe_month_year,
		count(distinct interest_id) as uniqe_intrest_id,
		count(*) as total_record,
		sum(composition) as com_sum,sum(index_value) as ind_sum from adinsight_analytics.interest_metrics im
where month_year is not null and exists ( select 1 from below_threshold_intrest_id bi where bi.interest_id=im.interest_id)
) 
, presnt_14_month as (
select '14 month present ' as record,
       count(distinct month_year) as uniqe_month_year,
		count(distinct interest_id) as uniqe_intrest_id,
		count(*) as total_record,
		sum(composition) as com_sum,sum(index_value) as ind_sum

from adinsight_analytics.interest_metrics im
where month_year is not null and exists( select 1 from t1 where total_months=14 and im.interest_id=t1.interest_id)
)
select * from lower_coverage
union all
select * from presnt_14_month;


 
-- *******************************************************************************************************************************************************************************************************
--12. After filtering out lower-coverage interests, how many unique interests remain for each month?

with t1 as (
select interest_id ,count(distinct month_year) as total_months from adinsight_analytics.interest_metrics
where month_year is not null
group by interest_id ),t2 as (
select total_months,COUNT(*) as total_m_freq from t1
group by total_months ) ,t3 as (
select *,sum(total_m_freq)over(order by total_months desc) as cumulative_sum,sum(total_m_freq)over() as total_freq from t2 ) ,t4 as (
select * , round(cumulative_sum/cast(total_freq as float),4)*100 cumulative_percentage from t3 ) ,
below_threshold_total_months as
(select  total_months from t4 where cumulative_percentage<90 ) ,
below_threshold_intrest_id as (
select distinct interest_id from t1 join below_threshold_total_months bm on t1.total_months=bm.total_months )
select year,month , count(distinct interest_id) as unique_interests from adinsight_analytics.interest_metrics im
where exists ( select 1 from below_threshold_intrest_id bi where bi.interest_id=im.interest_id) and month_year is not null
group by year,month;
---------------
-- other--------------------
with t1 as (
select interest_id ,count(distinct month_year) as total_months from adinsight_analytics.interest_metrics
where month_year is not null
group by interest_id ),t2 as (
select total_months,COUNT(*) as total_m_freq from t1
group by total_months ) ,t3 as (
select *,sum(total_m_freq)over(order by total_months desc) as cumulative_sum,sum(total_m_freq)over() as total_freq from t2 ) ,t4 as (
select * , round(cumulative_sum/cast(total_freq as float),4)*100 cumulative_percentage from t3 ) ,below_threshold_total_months as
(
select  total_months from t4 where cumulative_percentage<90 ) ,below_threshold_intrest_id as (
select interest_id from t1 join below_threshold_total_months bm on t1.total_months=bm.total_months )
, below_total_record as (
select count(*) as total_record_below_threshold from adinsight_analytics.interest_metrics im
where month_year is not null and exists ( select 1 from below_threshold_intrest_id bi where bi.interest_id=im.interest_id))
, total_record as (
select count(*) as total_record from adinsight_analytics.interest_metrics
where month_year is not null)
select total_record_below_threshold    from total_record,below_total_record


--### Segment Analysis
select * from adinsight_analytics.interest_metrics;
--13. From the filtered dataset (interests present in at least 6 months), identify the top 10 and bottom 10 interests based on 
--their maximum `composition` value.Also, retain the corresponding `month_year`.
 
with interest_metrics as (
  select * from adinsight_analytics.interest_metrics
  where month_year is not null )
  , filter_months as (
  select distinct interest_id  from interest_metrics
  group by interest_id
  having count(distinct month_year)>5 )
, filter_intrest_metrics as (
	select i.* from interest_metrics i
	join filter_months fm on i.interest_id=fm.interest_id ),
top_records as (								
select interest_id,composition,month_year,rn_inid from ( select * ,row_number()over(partition by interest_id order by composition desc) rn_inid from filter_intrest_metrics ) i
where rn_inid=1 ),
top_10 as (
select interest_id,composition,month_year,rn
from (
select * , row_number()over(order by composition desc) as rn from top_records ) i
where rn<11
),
bottom_10 as (								
select interest_id,composition,month_year,rn
from (
select * , row_number()over(order by composition) as rn from top_records ) i
where rn<11 )
select t.interest_id as top_interest,t.composition,t.month_year
,' | ' as ' | ',
b.interest_id as bottom_interest_id,b.composition,b.month_year
from top_10 t join bottom_10  b on t.rn=b.rn
order by t.composition desc;


--14. Identify the five interests with the lowest average `ranking` value.

with t as (
select interest_id,avg(ranking)as average_ranking,ROW_NUMBER()over( order by avg(ranking)) as rn
from adinsight_analytics.interest_metrics
where month_year is not null 
group by interest_id )
select interest_id,average_ranking from t
where rn <6;

-- with the help of top
select top 5 interest_id,avg(ranking)as average_ranking
from adinsight_analytics.interest_metrics
where month_year is not null group by interest_id order by average_ranking;

--15. Determine the five interests with the highest standard deviation in their `percentile_ranking`.
select top 5 interest_id,stdev(percentile_ranking) as stdev_on_Pranking
from adinsight_analytics.interest_metrics
where month_year is not null group by interest_id order by stdev_on_Pranking desc;

	--16. For the five interests found in the previous step, report the minimum and maximum `percentile_ranking` 
	--values and their corresponding `month_year`. What trends or patterns can you infer from these fluctuations?
with intrests_record as (
select top 5 interest_id from adinsight_analytics.interest_metrics
where month_year is not null group by interest_id order by stdev(percentile_ranking)desc )
, t as (select im.interest_id,percentile_ranking,month_year 
      from intrests_record i join adinsight_analytics.interest_metrics im on i.interest_id=im.interest_id ) 
,max_intrest_value as
(  select interest_id,percentile_ranking,month_year from t 
	where percentile_ranking = (select max(i.percentile_ranking) from t as i where i.interest_id=t.interest_id))
,min_intrest_value as
(  select interest_id,percentile_ranking,month_year from t 
	where percentile_ranking = (select min(i.percentile_ranking) from t as i where i.interest_id=t.interest_id)) 
select ma.interest_id,ma.month_year as max_month_year, ma.percentile_ranking as max_percentage,mi.month_year as min_month_year,mi.percentile_ranking as min_percentage
from max_intrest_value ma join min_intrest_value mi on ma.interest_id=mi.interest_id;


--17. Based on composition and ranking data, describe the overall customer profile represented in this segment. 
--What types of products/services should be targeted, and what should be avoided?

 with t as (
 select *,ROW_NUMBER()over(partition by interest_id order by composition desc) as rn from adinsight_analytics.interest_metrics
 where month_year is not null
 ) select * from t
 where rn=1 order by composition desc;




--### Index Analysis

--18. Calculate the average composition for each interest by dividing `composition` by `index_value`, rounded to 2 decimal places.
select interest_id,round(avg(composition/index_value),2) as average_composition from adinsight_analytics.interest_metrics
where interest_id is not null
group by interest_id;


--19. For each month, identify the top 10 interests based on this derived average composition.
with t as (
select month_year,interest_id, round(avg(composition/index_value),2) as average_composition ,ROW_NUMBER()over(partition by month_year order by round(avg(composition/index_value),2) desc ) as rn from adinsight_analytics.interest_metrics
where month_year is not null
group by month_year,interest_id)
select month_year,month(month_year) as months,interest_id,average_composition from t
where rn<11
order by month_year,average_composition desc;

--20. Among these top 10 interests, which interest appears most frequently?
with t as (
select month_year,interest_id, round(avg(composition/index_value),2) as average_composition ,ROW_NUMBER()over(partition by month_year order by round(avg(composition/index_value),2) desc ) as rn from adinsight_analytics.interest_metrics
where month_year is not null
group by month_year,interest_id)
,t1 as (
select interest_id,count(*) intrest_freq,RANK()over(order by count(*) desc ) rk from t
where rn<11
group by interest_id ) select interest_id from t1 where rk=1;

--21. Calculate the average of these monthly top 10 average compositions across all months.

with t as (
select month_year,interest_id,avg(composition) as avg_com ,ROW_NUMBER()over(partition by month_year order by avg(composition) desc) rn from adinsight_analytics.interest_metrics
where month_year is not null
group by month_year,interest_id )
select month_year,month(month_year)  as months , avg_com from t
where rn<11
order by month_year,avg_com desc;

--22. From September 2018 to August 2019, calculate a 3-month rolling average of the highest average composition. Also, include the top interest names for the current, 1-month-ago, and 2-months-ago periods.
with t as (
select month,year,month_year,interest_id,composition from adinsight_analytics.interest_metrics
where month_year is not null and month_year between DATEFROMPARTS(2018,9,1) and  DATEFROMPARTS(2019,8,1))
,t1 as (
select month_year,interest_id,avg(composition) as avg_compositions,ROW_NUMBER()over(partition by month_year order by avg(composition) desc ) as rn from t
group by month_year,interest_id
),t2 as ( select month_year,interest_id,avg_compositions from t1 where rn=1)
select month_year,round(avg(avg_compositions)over(order by month_year Rows Between 2 preceding  and current row),2) rolling_avg ,
interest_name as current_intrest_name, lag(interest_name)over(order by month_year) as one_month_ago ,lag(interest_name,2)over(order by month_year) two_months_ago
from t2 join adinsight_analytics.interest_map m on t2.interest_id=m.id;

--23. Provide a plausible explanation for the month-to-month changes in the top average composition. Could it indicate any risks or insights into AdInsight�s business model?

with t as (
select month,year,month_year,interest_id,composition from adinsight_analytics.interest_metrics
where month_year is not null and month_year between DATEFROMPARTS(2018,9,1) and  DATEFROMPARTS(2019,8,1))
,t1 as (
select month_year,interest_id,avg(composition) as avg_compositions,ROW_NUMBER()over(partition by month_year order by avg(composition) desc ) as rn from t
group by month_year,interest_id
),t2 as ( select month_year,interest_id,avg_compositions from t1 where rn=1)
select month_year,round(avg(avg_compositions)over(order by month_year Rows Between 2 preceding  and current row),2) rolling_avg ,
interest_name as current_intrest_name, lag(interest_name)over(order by month_year) as one_month_ago ,lag(interest_name,2)over(order by month_year) two_months_ago
from t2 join adinsight_analytics.interest_map m on t2.interest_id=m.id;
