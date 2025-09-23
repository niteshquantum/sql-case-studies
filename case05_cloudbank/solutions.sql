-- A. Customer Node Exploration
-- How many unique nodes exist within the Cloud Bank system?
select count(distinct node_id) number_of_uNodes from cloud_bank.customer_nodes;

-- What is the distribution of nodes across different regions?
select r.region_id,region_name,count(distinct cn.node_id)as node_distributions from cloud_bank.customer_nodes cn
join cloud_bank.regions r on cn.region_id=r.region_id
group by r.region_id,region_name

-- How many customers are allocated to each region?
select r.region_id,region_name,count(distinct cn.customer_id)as customers_are_allocated from cloud_bank.customer_nodes cn
join cloud_bank.regions r on cn.region_id=r.region_id
group by r.region_id,region_name

-- On average, how many days does a customer stay on a node before being reallocated?


select avg( DATEDIFF(day ,start_date,end_date)) as avg_days_node from cloud_bank.customer_nodes
where YEAR(end_date)<3020;

-- What are the median, 80th percentile, and 95th percentile reallocation durations (in days) for customers in each region?
-- *********************** break down  ********************************
-- hr region ka perrank uske day diff pr
with percentiles as (
select region_id , floor(PERCENT_RANK()over(partition by region_id order by datediff(day,start_date,end_date))*100) as percentile  from cloud_bank.customer_nodes where YEAR(end_date)<3020
)
select region_id,percentile ,count(percentile) counts from percentiles
where percentile in ( 80,95,50)
group by region_id,percentile
order by region_id,percentile;

---
with percentiles as (
select region_id , floor( PERCENT_RANK()over(partition by region_id order by datediff(day,start_date,end_date))*100) as percentile from cloud_bank.customer_nodes where YEAR(end_date)<3020
)
select region_id
,( select count(percentile) counts from percentiles where percentile=50 and p.region_id =region_id) as median
,(select count(percentile) counts from percentiles where percentile=80 and p.region_id =region_id) as percentile80
,(select count(percentile) counts from percentiles where percentile=95 and p.region_id =region_id) as percentile90
from percentiles p
group by region_id;


-- B. Customer Transactions

-- What are the unique counts and total amounts for each transaction type (e.g., deposit, withdrawal, purchase)?

-- ************************************** break down
-- unique count of customers and total amount of each transition type

select txn_type,count(distinct customer_id) as uniq_cus_count, sum(txn_amount) as tota_amount from cloud_bank.customer_transactions
group by txn_type;

-- What is the average number of historical deposits per customer, along with the average total deposit amount?
 
select customer_id,
		-- customer ka total transiton count divide by deposits ka couns
		round(try_cast(count(*) as float)/( select count(*) from  cloud_bank.customer_transactions ct
                   where ct.customer_id=customer_id),5)
		as avg_number_historical,
avg(txn_amount) as avg_total_deposit
from cloud_bank.customer_transactions
where txn_type='deposit'
group by customer_id
order by customer_id;

--- total transion me se ni kra only deposite ka count
select customer_id,
count(*) as avg_number_historical,
avg(txn_amount) as avg_total_deposit
from cloud_bank.customer_transactions
where txn_type='deposit'
group by customer_id
order by customer_id;
 

-- For each month, how many Cloud Bank customers made more than one deposit and either one purchase or one withdrawal?
with deposit_count as (
		select MONTH(txn_date) as months,customer_id,count(txn_type) num_of_transitions  from cloud_bank.customer_transactions
		where txn_type='deposit'
	    group by MONTH(txn_date),customer_id
		-- order by months,customer_id
			),
purchase_withdraw_count as (
			select MONTH(txn_date) as months,customer_id,count(txn_type) num_of_transitions  from cloud_bank.customer_transactions
		    where txn_type in ('purchase','withdrawal')
	        group by MONTH(txn_date),customer_id
			)
 select d.months,COUNT(d.customer_id) as no_of_customers  from deposit_count as d
 join purchase_withdraw_count pw on d.months=pw.months and d.customer_id=pw.customer_id
 where d.num_of_transitions>1 and pw.num_of_transitions=1
 group by d.months;

-- What is the closing balance for each customer at the end of every month?
--**************--
--1. hr customer ko month assign
--2 hr customer ke amount month wise
--3 dono ko join customer month and running total

with cm as (
           select distinct ct.customer_id ,try_cast(value as int) as months from cloud_bank.customer_transactions ct
           cross apply string_split('1,2,3,4',',') )
, ca as (
select customer_id , MONTH(txn_date) as months ,
                     sum( case  when txn_type ='deposit' then txn_amount else (-1)*txn_amount end ) as amount
		from cloud_bank.customer_transactions
		group by customer_id, MONTH(txn_date) 	)

select cm.customer_id,cm.months,ca.amount,
sum(ca.amount)over(partition by cm.customer_id order by cm.months) as month_closing
from cm left join ca on cm.customer_id=ca.customer_id and cm.months=ca.months;

-----*** same q with recusion using month genrate
with month_cte as (
select 1 as months
union all
select months+1 from month_cte
where months<4
)
, cm as (
           select distinct customer_id , months from cloud_bank.customer_transactions 
           cross apply month_cte )
, ca as (
         select customer_id , MONTH(txn_date) as months ,
                     sum( case  when txn_type ='deposit' then txn_amount else (-1)*txn_amount end ) as amount
		from cloud_bank.customer_transactions
		group by customer_id, MONTH(txn_date)	)
select cm.customer_id,cm.months,ca.amount,
sum(ca.amount)over(partition by cm.customer_id order by cm.months) as month_closing
from cm left join ca on cm.customer_id=ca.customer_id and cm.months=ca.months;
		
-- What percentage of customers increased their closing balance by more than 5% month-over-month?

with cte as(
	select customer_id , MONTH(txn_date) as months 
	      ,sum( case when txn_type ='deposit' then txn_amount else (-1)*txn_amount end ) as amount
	from cloud_bank.customer_transactions ct
	where exists (select 1 from cloud_bank.customer_transactions c where c.customer_id=ct.customer_id
                  group by c.customer_id having count(distinct month(c.txn_date))>3)
	group by customer_id, MONTH(txn_date) 
		--order by customer_id,months;
	)
,cte1 as(
		select *,
		sum(amount)over(partition by customer_id order by months) as  closing_balance -- closing balance
		from cte 
		--order by customer_id ,months;
		)
,cte2 as (
		select *,
		lag(closing_balance)over (partition by customer_id order by months) as last_closing_balance -- closing balance
		from cte1
		)
--select * from cte2;
,cte3 as(
 select *,
 case
     when last_closing_balance=0 then 
	      case when last_closing_balance<closing_balance then 10 else -10 end
	 else round(try_cast( closing_balance-last_closing_balance as float)/abs(last_closing_balance),4)*100
 end as per_diff
 from cte2 )
 ,cte4 as (
 select customer_id ,count(*) as mCount from cte3
 where per_diff>5
 group by customer_id
 having count(*)>2) 
 select round( try_cast(( select count(distinct c.customer_id) from cte4 c) as float )/count(distinct customer_id),3)*100 as percent_customer  from cloud_bank.customer_transactions;

---*******************************
 

 -- ** ager 1 month me bhi aay atho usko count
 with cte as(
	select customer_id , MONTH(txn_date) as months 
	      ,sum( case when txn_type ='deposit' then txn_amount else (-1)*txn_amount end ) as amount
	from cloud_bank.customer_transactions ct
	group by customer_id,month(txn_date)
		--order by customer_id,months;
	)
,cte1 as(
		select *, 
		sum(amount)over(partition by customer_id order by months) as  closing_balance -- closing balance
		from cte 
		--order by customer_id ,months;
		)
,cte2 as (
		select *,
		lag(closing_balance)over (partition by customer_id order by months) as last_closing_balance -- last closing balance
		from cte1
		)
--select * from cte2;
,cte3 as(
 select *,
 case
     when last_closing_balance=0 then 
	      case when last_closing_balance<closing_balance then 10 else -10 end
	      else round(try_cast( closing_balance-last_closing_balance as float)/abs(last_closing_balance),4)*100
 end as per_diff
 from cte2 )
 ,cte4 as (
 select count(distinct customer_id) as customer_count from cte3
 where per_diff>5) 
 select round( try_cast((select customer_count from cte4 ) as float )
                /count(distinct customer_id),3)*100 as percent_customer  
 from cloud_bank.customer_transactions;



-- C. Cloud Storage Allocation Challenge
-- The Cloud Bank team is experimenting with three storage allocation strategies:

-- Option 1: Storage is provisioned based on the account balance at the end of the previous month
with ctemonth as (
select distinct customer_id,try_cast(value as int) months from cloud_bank.customer_transactions
cross apply string_split('1,2,3,4',',')
)
,cte1 as (
select distinct ctm.customer_id, ctm.months, sum(case when txn_type='deposit' then txn_amount else -1*(txn_amount) end)
                                            over(partition by ctm.customer_id order by ctm.months)as monthly_balance
from cloud_bank.customer_transactions ct
right join ctemonth ctm on ct.customer_id=ctm.customer_id and month(ct.txn_date)=ctm.months )
select *,lag(monthly_balance)over(partition by customer_id order by months) from cte1;

-- Option 2: Storage is based on the average daily balance over the previous 30 days
with ctemonth as (
select distinct customer_id,try_cast(value as int) months from cloud_bank.customer_transactions
cross apply string_split('1,2,3,4',',')
)
select distinct ctm.customer_id, ctm.months, round(sum(case when txn_type='deposit' then txn_amount else -1*(txn_amount) end)
                                            over(partition by ctm.customer_id order by ctm.months)/30.0,2) as avg_daily_balance
from cloud_bank.customer_transactions ct
right join ctemonth ctm on ct.customer_id=ctm.customer_id and month(ct.txn_date)=ctm.months;


-- Option 3: Storage is updated in real-time, reflecting the balance after every transaction
select *,concat(sum(case when txn_type='deposit' then txn_amount else -1*(txn_amount) end)over(partition by customer_id order by txn_date),' GB') as running_Storage_Allocations
from cloud_bank.customer_transactions
--order by customer_id,txn_date;
-- To support this analysis, generate the following:

-- A running balance for each customer that accounts for all transaction activity
select *,sum(case when txn_type='deposit' then txn_amount else -1*(txn_amount) end)over(partition by customer_id order by txn_date) as running_balance 
from cloud_bank.customer_transactions;
--order by customer_id,txn_date;
-- The end-of-month balance for every customer

-- The minimum, average, and maximum running balances per customer
with ctemonth as (
select distinct customer_id,try_cast(value as int) months from cloud_bank.customer_transactions
cross apply string_split('1,2,3,4',',')
)
,cte1 as (
select distinct ctm.customer_id, ctm.months, sum(case when txn_type='deposit' then txn_amount else -1*(txn_amount) end)
                                            over(partition by ctm.customer_id order by ctm.months)as monthly_balance
from cloud_bank.customer_transactions ct
right join ctemonth ctm on ct.customer_id=ctm.customer_id and month(ct.txn_date)=ctm.months )
select customer_id,min(monthly_balance) minimum, avg(monthly_balance) average, max(monthly_balance) maximum from cte1
group by customer_id;

-- Using this data, estimate how much cloud storage would have been required for each allocation option on a monthly basis.


-- D. Advanced Challenge: Interest-Based Data Growth
-- Cloud Bank wants to test a more complex data allocation method: applying an interest-based growth model similar to traditional savings accounts.

-- If the annual interest rate is 6%, how much additional cloud storage would customers receive if:

-- Interest is calculated daily, without compounding?

-- (Optional Bonus) Interest is calculated daily with compounding?

select * from cloud_bank.customer_transactions;

select sum( case when txn_type='deposit' then txn_amount else -txn_amount end )as total_amount from cloud_bank.customer_transactions





