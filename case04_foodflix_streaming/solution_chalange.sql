
--Challenge � Payments Table for Foodflix (2020)

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
/* make payment_date */ (case 
      when plan_id=3 and lag(plan_id)over(partition by customer_id order by start_date)=2
      then  (case 
	            when day(start_date)>day(lag(start_date)over(partition by customer_id order by start_date))
		     then  dateadd(day,-1*day(start_date)+day(lag(start_date)over(partition by customer_id order by start_date)), dateadd(month,1,start_date))
             else start_date end)
      else start_date end) as payment_date,
 /*make end_date*/ ( case
          when  lead(start_date)over(partition by customer_id order by start_date)<='2020-12-31' then lead(start_date)over(partition by customer_id order by start_date)
        else '2020-12-31' end ) as end_date
		from foodflix.subscriptions
        where year(start_date)=2020 and plan_id !=0  )
/*recurcive cte for date_genrate*/
,rec as (
select customer_id,plan_id,payment_date ,end_date from cte1
where plan_id!=4
union all
select customer_id,plan_id, dateadd(month,1, payment_date),end_date from rec
where dateadd(month,1, payment_date)<end_date and plan_id !=3 ) 
-- make main table with this colums
--("customer_id", "plan_id", "plan_name", "payment_date", "amount", "payment_order")
 -- make table then insert
 --insert into foodflix.payments(customer_id, plan_id, plan_name, payment_date, amount,payment_order)
  select  customer_id,r.plan_id,p.plan_name ,r.payment_date,
/* make amount*/
  case
      when r.plan_id in (2,3) and lag(r.plan_id)over(partition by customer_id order by payment_date)=1 then p.price-((datediff(day,lag(r.payment_date)over(partition by customer_id order by payment_date),payment_date))*(lag(p.price)over(partition by customer_id order by payment_date))/30)
      else p.price
  end as amount ,
/* make payment_order */
  row_number()over(partition by customer_id order by payment_date) as payment_order
/* make new payment table with the help of cta*/
-- into payments_foodflix
  from rec r
  join foodflix.plans p on r.plan_id=p.plan_id
  order by customer_id,payment_date;

/*
  -- create payment table
--drop table payments

 create table foodflix.payments(
  --("customer_id", "plan_id", "plan_name", "payment_date", "amount", "payment_order")
  customer_id int,plan_id int,plan_name varchar(100) ,payment_date date,amount float,payment_order int )
 select * from foodflix.payments;
 */