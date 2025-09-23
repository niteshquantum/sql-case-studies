--### A. Customer and Plan Insights (Foodflix)
use funtions;
select * from foodflix.subscriptions;
select * from foodflix.plans;

--1. How many unique customers have ever signed up with Foodflix?
select COUNT(distinct customer_id) as unique_customers
from foodflix.subscriptions;

--2. What is the monthly distribution of trial plan start dates in the dataset?

-- har 1 month ka trial plan count
select MONTH(s.start_date) month,count(p.plan_id) as trial_count
from foodflix.subscriptions s 
join foodflix.plans p on s.plan_id=p.plan_id
where p.plan_name='trial'
group by MONTH(s.start_date);
---------------------------------
with tcount as ( -- total plan count month ke accroding 
select MONTH(s.start_date) monthname,count(p.plan_id) as totalcount
from foodflix.subscriptions s 
join foodflix.plans p on s.plan_id=p.plan_id
group by MONTH(s.start_date) )
, pcount as (   -- trial plan count
select MONTH(s.start_date) monthname,count(p.plan_id) as p_totalcount
from foodflix.subscriptions s 
join foodflix.plans p on s.plan_id=p.plan_id
where p.plan_name='trial'
group by MONTH(s.start_date)
)

-- main 
 select tcount.monthname,totalcount,p_totalcount,
round(cast(p_totalcount as float)/totalcount*100.0,2) as distributions
 from tcount
join pcount on tcount.monthname=pcount.monthname;


/*
select MONTH(s.start_date) month,count(p.plan_id) as monthly_count,
str(round(CUME_DIST()OVER( ORDER BY count(p.plan_id)),2)*100) +'%' as monthy_distribution
from foodflix.subscriptions s 
join foodflix.plans p on s.plan_id=p.plan_id
where p.plan_name='trial'
group by MONTH(s.start_date)
order by MONTH(s.start_date); 
*/

select MONTH(s.start_date) month,count(p.plan_id) as monthly_count,
CUME_DIST()OVER( ORDER BY count(p.plan_id))*100 as monthy_distribution
from foodflix.subscriptions s 
join foodflix.plans p on s.plan_id=p.plan_id
where p.plan_name='trial'
group by MONTH(s.start_date)
order by MONTH(s.start_date);

-- count of year and month
select year(s.start_date) year,MONTH(s.start_date) month,count(p.plan_id) as monthlydistributions 
from foodflix.subscriptions s 
join foodflix.plans p on s.plan_id=p.plan_id
where p.plan_name='trial'
group by year(s.start_date),MONTH(s.start_date)
order by year(s.start_date),MONTH(s.start_date);
 
--3. Which plan start dates occur after 2020?

select p.plan_id,p.plan_name from (
select  plan_id ,start_date from foodflix.subscriptions
where year(start_date)>2020) as sub
join foodflix.plans p on sub.plan_id=p.plan_id

select p.plan_id,p.plan_name,count(*) from (
select  plan_id ,start_date from foodflix.subscriptions
where year(start_date)>2020) as sub
join foodflix.plans p on sub.plan_id=p.plan_id
group by p.plan_id,p.plan_name;

---------------------------

select plan_id,min(start_date) as sdate from foodflix.subscriptions
group by plan_id
having year(min(start_date))>2020;

--

--4. What is the total number and percentage of customers who have churned?

select total_churn_customer ,round(cast(total_churn_customer as float)/total_customer*100.0,2) as curnpersent 
from(
select (select count(*)  from  foodflix.subscriptions) as total_customer,
count(*) total_churn_customer from foodflix.subscriptions s
join foodflix.plans p on s.plan_id=p.plan_id
where p.plan_name='churn'
) as c

select total_churn_customer ,round(cast(total_churn_customer as float)/total_customer*100.0,2) as curnpersent 
from(
select (select count(distinct customer_id)  from  foodflix.subscriptions) as total_customer,
count(distinct customer_id) total_churn_customer from foodflix.subscriptions s
join foodflix.plans p on s.plan_id=p.plan_id
where p.plan_name='churn'
) as c

--5. How many customers churned immediately after their free trial?
with c as (
select s.customer_id,plan_name,LEAD(plan_name)over(partition by s.customer_id order by s.start_date ) as nextplan 
from foodflix.subscriptions s
join foodflix.plans p on s.plan_id=p.plan_id
)
select COUNT(*) total from c
where c.plan_name='trial' and c.nextplan='churn' 

--6. What is the count and percentage of customers who transitioned to a paid plan after their initial trial?
with c as (
select s.customer_id,plan_name,LEAD(price)over(partition by s.customer_id order by s.start_date ) as nextplanprice 
from foodflix.subscriptions s
join foodflix.plans p on s.plan_id=p.plan_id
) ,allcount as (select count(*) no_customer ,(select count(*) from foodflix.subscriptions) as totalcount from c
where plan_name='trial' and nextplanprice>0.0)
select no_customer,round(cast(no_customer as float)/totalcount*100,2) as percentage from allcount;


with c as (
select s.customer_id,plan_name,LEAD(price)over(partition by s.customer_id order by s.start_date ) as nextplanprice 
from foodflix.subscriptions s
join foodflix.plans p on s.plan_id=p.plan_id
) ,allcount as (select count(distinct customer_id) no_customer ,(select count(distinct customer_id) from foodflix.subscriptions) as totalcount from c
where plan_name='tr ial' and nextplanprice>0.0)
select no_customer,round(cast(no_customer as float)/totalcount*100,2) as percentage from allcount

--select *  from foodflix.subscriptions s
--join foodflix.plans p on s.plan_id=p.plan_id;
;
--7. As of 2020-12-31, what is the count and percentage of customers in each of the 5 plan types?

-- jiska current plant active hai usko
-- unka percentage btana hai hr hr ek plan me

with active_plan as (
select *, row_number() over(partition by customer_id order by start_date desc) as rn 
        from foodflix.subscriptions
		where start_date<='2020-12-31'
			) 
select plan_id,count(*) as no_of_customers ,count(*)*100.0/(select count(*) as total_of_customers from active_plan where rn=1) as percentofcus
from active_plan
where rn=1
group by plan_id;

-- provided by sir
WITH latest_plan AS (
    SELECT
        s.customer_id,
        s.plan_id,
        s.start_date,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.start_date DESC) AS rn
    FROM foodflix.subscriptions s
    WHERE s.start_date <= '2020-12-31'
)

SELECT 
    p.plan_name,
    COUNT(lp.customer_id) AS customer_count,
    ROUND(100.0 * COUNT(lp.customer_id) / SUM(COUNT(lp.customer_id)) OVER (), 2) AS percentage
FROM latest_plan lp
JOIN foodflix.plans p ON lp.plan_id = p.plan_id
WHERE lp.rn = 1
GROUP BY p.plan_name
ORDER BY customer_count DESC;

--8. How many customers upgraded to an annual plan during the year 2020?


with c as (
select plan_id,start_date from foodflix.subscriptions
) select count(*) customer_count from c
where plan_id=3 and YEAR(start_date)=2020;


--9. On average, how many days does it take for a customer to upgrade to an annual plan from their sign-up date?
with c as (
select plan_id,start_date,
first_value(plan_id) over(partition by customer_id order by start_date) as first_plan,
first_value(start_date) over(partition by customer_id order by start_date) as first_date
from foodflix.subscriptions
) select avg(DATEDIFF(day,first_date,start_date )) as avgdate from c
where plan_id=3;


with c as (
select plan_id,start_date,
first_value(plan_id) over(partition by customer_id order by start_date) as first_plan,
first_value(start_date) over(partition by customer_id order by start_date) as first_date
from foodflix.subscriptions
) select *from c
where plan_id=3;


--10 Can you break down the average days to upgrade to an annual plan into 30-day intervals.

-- step 1: calculate annual plan sub date ,first time wale
-- step 2: uski satrting date se anual date ka diff 
-- step 3: aab unko divide kr dean hai group me like 30 din fir 60... ese interwal me

-- step 1 anualplan date
with anuald
as (
select customer_id,min(start_date) as anualdate from foodflix.subscriptions
where plan_id=3
group by customer_id)
, firstd as ( --- first plan date
select customer_id,min(start_date) as first_date from foodflix.subscriptions
group by customer_id
), m as (  -- customer ke date diffrence kitna time lga
select a.customer_id, DATEDIFF(day,f.first_date,a.anualdate) as diff from anuald a
join firstd f on a.customer_id=f.customer_id)
select concat(diff/30*30 ,'-',(diff/30+1)*30-1)as interval , count(customer_id) as count,
sum(diff)*1.0/count(customer_id) as perc
from m
group by diff/30;




-- provided by sir
-- Step 1: Get each customer's first-ever subscription date
WITH first_subscription AS (
    SELECT
        customer_id,
        MIN(start_date) AS first_sub_date
    FROM foodflix.subscriptions
    GROUP BY customer_id
),

-- Step 2: Get each customer's first upgrade to the annual plan (plan_id = 3)
first_annual_upgrade AS (
    SELECT
        customer_id,
        MIN(start_date) AS annual_upgrade_date
    FROM foodflix.subscriptions
    WHERE plan_id = 3
    GROUP BY customer_id
),

-- Step 3: Combine both to compute days to upgrade
upgrade_diff AS (
    SELECT
        fa.customer_id,
        DATEDIFF(DAY, fs.first_sub_date, fa.annual_upgrade_date) AS days_to_upgrade
    FROM first_subscription fs
    JOIN first_annual_upgrade fa ON fs.customer_id = fa.customer_id
)

-- Step 4: Group customers into 30-day buckets
SELECT
    CONCAT(
        FLOOR(days_to_upgrade / 30) * 30, 
        '-', 
        (FLOOR(days_to_upgrade / 30) + 1) * 30 - 1, 
        ' days'
    ) AS upgrade_interval,
    COUNT(*) AS customer_count,
    ROUND(AVG(CAST(days_to_upgrade AS FLOAT)), 1) AS avg_days_to_upgrade
FROM upgrade_diff
GROUP BY FLOOR(days_to_upgrade / 30)
ORDER BY FLOOR(days_to_upgrade / 30);

--11. How many customers downgraded from a Pro Monthly to a Basic Monthly plan in 2020?
with c as (
select p.plan_name,LEAD(p.plan_name)over(partition by s.customer_id order by start_date) as next_plan from foodflix.subscriptions s
join foodflix.plans p on s.plan_id=p.plan_id
)
select count(*) as downgratecount from c
where plan_name='pro monthly' and next_plan='basic monthly';

with c as (
select plan_id,LEAD(plan_id)over(partition by customer_id order by start_date) as next_plan from foodflix.subscriptions
)
select count(*) as downgratecount from c
where plan_id=2 and next_plan=1;

-----

--Challenge – Payments Table for Foodflix (2020)

--The Foodflix   team would like you to generate a payments table for the year 2020 that reflects actual payment activity. The logic should include:

--* Monthly payments are charged on the same day of the month as the start date of the plan.
--* Upgrades from Basic to Pro plans are charged immediately, with the upgrade cost reduced by the amount already paid in that month.
--* Upgrades from Pro Monthly to Pro Annual are charged at the end of the current monthly billing cycle, and the new plan starts at the end of that cycle.
--* Once a customer churns, no further payments are made.

--Example output rows for the payments table could include:
--("customer_id", "plan_id", "plan_name", "payment_date", "amount", "payment_order")

-----------------------------------------------------------------------------------------------------------------
with cte1 as (
select customer_id,plan_id,
(case 
when plan_id=3 and lag(plan_id)over(partition by customer_id order by start_date)=2
then 
(case 
	when day(start_date)>day(lag(start_date)over(partition by customer_id order by start_date))
		then  DATEADD(day,-1*day(start_date)+day(lag(start_date)over(partition by customer_id order by start_date)), DATEADD(month,1,start_date))
end
)
else start_date
end) as payment_date,
( case
when  lead(start_date)over(partition by customer_id order by start_date)<='2020-12-31' then lead(start_date)over(partition by customer_id order by start_date)
else '2020-12-31'
end
) as end_date
from foodflix.subscriptions
where year(start_date)=2020 and plan_id !=0
) ,rec as (
select customer_id,plan_id,payment_date ,end_date from cte1
where plan_id!=4

union all

select customer_id,plan_id, DATEADD(month,1, payment_date),end_date from rec
where DATEADD(month,1, payment_date)<end_date and plan_id !=3
) --("customer_id", "plan_id", "plan_name", "payment_date", "amount", "payment_order")

  select customer_id,r.plan_id,p.plan_name ,r.payment_date,
  
  case
   when r.plan_id in (2,3) and lag(r.plan_id)over(partition by customer_id order by payment_date)=1 then p.price-((DATEDIFF(day,lag(r.payment_date)over(partition by customer_id order by payment_date),payment_date))*(lag(p.price)over(partition by customer_id order by payment_date))/30)
   else p.price
  end
  as amount
  ,
  ROW_NUMBER()over(partition by customer_id order by payment_date)
  as payment_order
  
  from rec r
  join foodflix.plans p on r.plan_id=p.plan_id
  order by customer_id,payment_date;


-- row data
with cte1 as (
select customer_id,plan_id,
(case 
when plan_id=3 and lag(plan_id)over(partition by customer_id order by start_date)=2
then 
(case 
	when day(start_date)>day(lag(start_date)over(partition by customer_id order by start_date))
		then  DATEADD(day,-1*day(start_date)+day(lag(start_date)over(partition by customer_id order by start_date)), DATEADD(month,1,start_date))
end
)
else start_date
end) as payment_date,
( case
when  lead(start_date)over(partition by customer_id order by start_date)<='2020-12-31' then lead(start_date)over(partition by customer_id order by start_date)
else '2020-12-31'
end
) as end_date
from foodflix.subscriptions
where year(start_date)=2020 and plan_id !=0
) ,rec as (
select customer_id,plan_id,payment_date ,end_date from cte1
where plan_id!=4

union all

select customer_id,plan_id, DATEADD(month,1, payment_date),end_date from rec
where DATEADD(month,1, payment_date)<end_date and plan_id !=3
)
  select customer_id,r.plan_id,r.payment_date,
  
  
  p.price,end_date
  ,
  case
   when r.plan_id in (2,3) and lag(r.plan_id)over(partition by customer_id order by payment_date)=1 then p.price-((DATEDIFF(day,lag(r.payment_date)over(partition by customer_id order by payment_date),payment_date))*(lag(p.price)over(partition by customer_id order by payment_date))/30)
   else p.price
  end
  as payment
  
  from rec r
  join foodflix.plans p on r.plan_id=p.plan_id
  order by customer_id,payment_date;







-------------------------------------------------------------------------------------------------------------------
use funtions
-- with 2 cta
with t1 as (
			select s.customer_id,p.plan_id,p.plan_name,start_date,p.price,
			-- end_date
			lag(p.plan_id)over(partition by customer_id order by start_date) as pre_plan,
			--old amount
			lag(price)over(partition by customer_id order by start_date) as pre_price,
			lag(start_date)over(partition by customer_id order by start_date) as old_start,
				case
							when p.plan_id=3 and lag(p.plan_id)over(partition by customer_id order by start_date)=2  then dateadd(month,1,lag(start_date)over(partition by customer_id order by start_date))
							when p.plan_id=4 then null
							else start_date
						end as payment_date	
			from foodflix.subscriptions s
			join foodflix.plans p on s.plan_id=p.plan_id
			) 
			,t2 as(
			select * ,case 
			 when plan_id = 0 then dateadd(day,7,payment_date)
			 when plan_id in (1,2) then dateadd(month,1,payment_date)
			 when plan_id = 3 then dateadd(YEAR,1,payment_date)
			end
			as end_date 
			,
			case 
			 when plan_id = 2 and pre_plan=1 then price-pre_price
			  when plan_id = 3 and pre_plan=1 then price-pre_price
			  when plan_id = 3 and pre_plan=2 then price
			 else price
			end
			as amount
			from t1 --("customer_id", "plan_id", "plan_name", "payment_date", "amount", "payment_order")
			) select customer_id,plan_name,payment_date ,amount from t2
			order by customer_id;
-- with 3 cta
with t1 as (
			select s.customer_id,p.plan_id,p.plan_name,start_date,p.price,
			-- end_date
			lag(p.plan_id)over(partition by customer_id order by start_date) as pre_plan,
			--old amount
			lag(price)over(partition by customer_id order by start_date) as pre_price,
			lag(start_date)over(partition by customer_id order by start_date) as old_start
			from foodflix.subscriptions s
			join foodflix.plans p on s.plan_id=p.plan_id
			) , t2  as (select * ,
						case
							when plan_id=3 and pre_plan=2 then dateadd(month,1,old_start)
							when plan_id=4 then null
							else start_date
						end as start_date1	

			from t1)
			,t3 as(
			select * ,case 
			 when plan_id = 0 then dateadd(day,7,start_date1)
			 when plan_id in (1,2) then dateadd(month,1,start_date1)
			 when plan_id = 3 then dateadd(YEAR,1,start_date1)
			end
			as end_date 
			,
			case 
			 when plan_id = 2 and pre_plan=1 then price-pre_price
			  when plan_id = 3 and pre_plan=1 then price-pre_price
			  when plan_id = 3 and pre_plan=2 then price
			 else price
			end
			as amount
			from t2 --("customer_id", "plan_id", "plan_name", "payment_date", "amount", "payment_order")
			) select customer_id,plan_name,start_date1 as payment_date ,amount from t3
			order by customer_id;

-- mohit

with subscribtion_details as (
select s.customer_id, s.plan_id, p.plan_name, s.start_date, lead(s.start_date,1,'2022-01-01') over(partition by s.customer_id order by customer_id) as next_date ,p.price 
from foodflix.subscriptions as s
inner join foodflix.plans as p
on s.plan_id = p.plan_id), nitesh as (
select case when s.plan_id !=4 then row_number() over(order by s.customer_id) end as Payment_id,s.customer_id, s.plan_id, p.plan_name, 
case
	when s.plan_id = 0 then s.start_date
	when s.plan_id in (1,2,3) then DATEADD(day,1,s.start_date)
	when s.plan_id = 4 then null
end as payment_date,
case
	when s.plan_id = 0 then DATEADD(day, 7, s.start_date)
	when s.plan_id in (1,2) then DATEADD(month,DATEDIFF(month,s.start_date,sd.next_date), s.start_date)
	when s.plan_id = 3 then DATEADD(year, 1, s.start_date)
end as Subscription_end_date,
case
	when s.plan_id = 0 then p.price
	when s.plan_id = 1 then p.price
	when s.plan_id = 2 then p.price - lag(p.price) over(partition by s.customer_id order by s.customer_id)
	when s.plan_id = 3 then p.price
end as amount,
case
	when s.plan_id = 0 then p.price
	when s.plan_id in (1,2) then cast(DATEDIFF(month,s.start_date,sd.next_date) as int) * p.price
	when s.plan_id = 3 then p.price
end as Total_amount
from subscribtion_details as sd
inner join foodflix.subscriptions as s
on s.customer_id = sd.customer_id and s.plan_id = sd.plan_id
inner join foodflix.plans as p
on s.plan_id = p.plan_id)
select Payment_id,customer_id,plan_id,plan_name,payment_date,Subscription_end_date
,
case
 when plan_id in (2,3) and LAG(plan_id)over(partition by customer_id order by payment_date)=1 then Total_amount-amount
 else Total_amount
end final_amount

from nitesh	