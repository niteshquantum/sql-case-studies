use funtions
select * from pizza_delivery_india.riders;
select * from pizza_delivery_india.customer_orders;
select * from pizza_delivery_india.rider_orders;
select * from pizza_delivery_india.pizza_names;
select * from pizza_delivery_india.pizza_recipes;
select * from pizza_delivery_india.pizza_toppings;

--*****************************
/*
data cleaning
patindex()
charindex()

*********************
string_split(column,',')
cross apply per row
the cast
try_cast()
string_agg()

*/
--*****************************



--1. How many pizzas were ordered?
select count(pizza_id) as totalpizzaOrdered from pizza_delivery_india.customer_orders;

--2. How many unique customer orders were made?
select count(distinct order_id) as uniq_cuspizzasOrdered from pizza_delivery_india.customer_orders;

--3. How many successful orders were delivered by each rider?
select rider_id,count(*) as successful_orders from pizza_delivery_india.rider_orders
where cancellation is null or cancellation = ''
group by rider_id;

-- select * from pizza_delivery_india.rider_orders

--4. How many of each type of pizza was delivered?
select p.pizza_id,p.pizza_name,count(*)as delivered_pizza from pizza_delivery_india.pizza_names p
join pizza_delivery_india.customer_orders c on p.pizza_id=c.pizza_id
join pizza_delivery_india.rider_orders ro on c.order_id=ro.order_id
where ro.cancellation is null or ro.cancellation=''
group by p.pizza_id,p.pizza_name; 

--5. How many 'Paneer Tikka' and 'Veggie Delight' pizzas were ordered by each customer?
select co.customer_id,p.pizza_name,count(*) total_orders from pizza_delivery_india.customer_orders co
join pizza_delivery_india.pizza_names p on co.pizza_id=p.pizza_id
where p.pizza_name IN ('Paneer Tikka', 'Veggie Delight')
group by co.customer_id,p.pizza_name;


--6. What was the maximum number of pizzas delivered in a single order?
select top 1  count(ro.order_id) max_num_pizza_delivered  from pizza_delivery_india.rider_orders ro
join pizza_delivery_india.customer_orders co on ro.order_id=co.order_id
where ro.cancellation is null	or ro.cancellation = ''
group by ro.order_id
order by max_num_pizza_delivered desc;

--7. For each customer, how many delivered pizzas had at least 1 change (extras or exclusions) and how many had no changes?

with c as (
select co.customer_id,co.order_id,nullif(co.exclusions,'') as exclusions,nullif(co.extras,'') as extras
from pizza_delivery_india.customer_orders co
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id
where cancellation is null or cancellation='')

select c.customer_id ,
count( case    when exclusions is not null or extras is not null then 1 else NULL end ) as atlist1 ,
count(case when exclusions is null and  extras is  null then 1 else NULL end) as no_change
from c
group by c.customer_id;



--8. How many pizzas were delivered that had both exclusions and extras?

with c as (
select co.pizza_id,co.order_id,nullif(co.exclusions,'') as exclusions,nullif(co.extras,'') as extras
from pizza_delivery_india.customer_orders co
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id
where cancellation is null or cancellation='')

select count(*) as n_pizza_divilared from c
where exclusions is not null and extras is not null;

--9. What was the total volume of pizzas ordered for each hour of the day?
select datepart(hour,co.order_time) hours,count(co.pizza_id) as volume_of_pizza from pizza_delivery_india.customer_orders co
group by datepart(hour,co.order_time);


--10. What was the volume of orders for each day of the week?

select datename(WEEKDAY,co.order_time) weekName,count(co.pizza_id) as volume_of_pizza from pizza_delivery_india.customer_orders co
group by datename(WEEKDAY,co.order_time);



select datepart(WEEKDAY,co.order_time) weekName,count(co.pizza_id) as volume_of_pizza from pizza_delivery_india.customer_orders co
group by datepart(WEEKDAY,co.order_time);
-- ye only week no de rha hai apne do day name cahiye


--11. How many riders signed up for each 1-week period starting from 2023-01-01?

select count(*) riders_signed from pizza_delivery_india.riders
where datepart(WEEKDAY,registration_date) =1;

select count(*) riders_signed from pizza_delivery_india.riders
where datepart(WEEKDAY,registration_date) =1 and registration_date > cast('2023-01-01' as date);

--12. What was the average time in minutes it took for each rider to arrive at Pizza Delivery HQ to pick up the order?

select ro.rider_id,avg(datediff(MINUTE,co.order_time,ro.pickup_time)) as avg_time from pizza_delivery_india.rider_orders ro
join pizza_delivery_india.customer_orders co on ro.order_id=co.order_id
group by ro.rider_id;


--13. Is there any relationship between the number of pizzas in an order and how long it takes to prepare?

select co.order_id,count(co.pizza_id) number_piza,datediff(MINUTE,co.order_time,ro.pickup_time) time_minute
from pizza_delivery_india.customer_orders co
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id
where pickup_time is not null
group by co.order_id,co.order_time,ro.pickup_time;


--14. What was the average distance traveled for each customer?

select co.customer_id,avg(cast(replace(ro.distance,'km','') as float)) as avg_distance from pizza_delivery_india.customer_orders co
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id
group by co.customer_id;

--15. What was the difference between the longest and shortest delivery durations across all orders?
select max(o.distance) as logestdis,
		min(o.distance) as shortdis,
		max(o.distance)- min(o.distance) as diffrence
from(
select (cast(replace(distance,'km','') as float)) as distance from pizza_delivery_india.rider_orders)
as o;




--16. What was the average speed (in km/h) for each rider per delivery? Do you notice any trends?
with rider_order_clean as (
select rider_id ,
       try_cast(REPLACE(distance,'km','') as float) as distance, -- distance me se km remove kr ke float me convert

                   try_cast( case when PATINDEX('%[a-zA-Z]%',duration)>0 then       -- if string then substring 1 se pat-1   else string
                              substring(duration,1, PATINDEX('%[a-zA-Z]%',duration)-1)
                              else duration end
                     as float) duration_min  --- duration me se minutes remove kr ke float me convert
from pizza_delivery_india.rider_orders
where distance is not null and duration is not null
) select rider_id,avg(distance/(duration_min/60.0 )) from rider_order_clean
group by rider_id;




--17. What is the successful delivery percentage for each rider?
with total as (
select rider_id ,count(*) as total_order from pizza_delivery_india.rider_orders
group by rider_id), susscess as (
select rider_id ,count(*) as susscess_order from pizza_delivery_india.rider_orders
where  nullif(cancellation,null) is null
group by rider_id)
select t.rider_id,t.total_order,s.susscess_order,round(s.susscess_order*100.0,2)/t.total_order as successful_percent from total as t
join  susscess as s on t.rider_id=s.rider_id;

--18. What are the standard ingredients for each pizza?
select pizza_id,STRING_AGG(pt.topping_name,',') as indigrent from pizza_delivery_india.pizza_recipes
cross apply string_split(toppings,',') v join pizza_delivery_india.pizza_toppings pt on try_cast(trim(v.value) as int)=pt.topping_id
group by pizza_id;

--19. What was the most commonly added extra (e.g., Mint Mayo, Corn)?
 select topping_id,topping_name from pizza_delivery_india.pizza_toppings
 where topping_id = (   select max(value) from pizza_delivery_india.customer_orders
						cross apply string_split(extras,',') );

--20. What was the most common exclusion (e.g., Cheese, Onions)?
 select topping_id,topping_name from pizza_delivery_india.pizza_toppings
 where topping_id = (   select max(value) from pizza_delivery_india.customer_orders
						cross apply string_split(exclusions,',') );

--21. Generate an order item for each record in the `customer_orders` table in the format:

--    * Paneer Tikka
--    * Paneer Tikka - Exclude Corn
--    * Paneer Tikka - Extra Cheese
--    * Veggie Delight - Exclude Onions, Cheese - Extra	 Corn, Mushrooms

with cte1 as (
               select order_id,pn.pizza_name, exclusions,extras ,
               ROW_NUMBER()over(order by order_time) as rn
               from pizza_delivery_india.customer_orders co
               join pizza_delivery_india.pizza_names pn on co.pizza_id=pn.pizza_id
),cte2 as (
            select rn, STRING_AGG(pt.topping_name,',') as exclu  from cte1
            cross apply string_split(exclusions,',') e
            join pizza_delivery_india.pizza_toppings pt on try_cast(trim(e.value) as int)=pt.topping_id
            group by rn 
), cte3 as (
			select rn, STRING_AGG(pt1.topping_name,',') as extr  from cte1
			cross apply string_split(extras,',') x
			join pizza_delivery_india.pizza_toppings pt1 on try_cast(trim(x.value) as int)=pt1.topping_id
			group by rn)

select order_id,
       -- pizaa name      - Exclude                                - Extra
concat( pizza_name,  case  when exclu is null then ''
                     else concat(' - ','Exclude ',exclu) end
																,case  when extr is null then ''
																 else  concat(' - ','Extra ',extr) end) pizaa_ditials
from cte1
left join cte2 on cte1.rn=cte2.rn
left join cte3 on cte1.rn= cte3.rn;

with cte1 as (
               select order_id,pn.pizza_name,
			   NULLif(exclusions,'') as exclusions,
               nullif(extras,'') as extras ,
               ROW_NUMBER()over(order by order_time) as rn
               from pizza_delivery_india.customer_orders co
               join pizza_delivery_india.pizza_names pn on co.pizza_id=pn.pizza_id
),cte2 as (
            select rn, STRING_AGG(pt.topping_name,',') as exclu  from cte1
            cross apply string_split(exclusions,',') e
            join pizza_delivery_india.pizza_toppings pt on try_cast(trim(e.value) as int)=pt.topping_id
            group by rn 
), cte3 as (
			select rn, STRING_AGG(pt1.topping_name,',') as extr  from cte1
			cross apply string_split(extras,',') x
			join pizza_delivery_india.pizza_toppings pt1 on try_cast(trim(x.value) as int)=pt1.topping_id
			group by rn)

select order_id,
       -- pizaa name      - Exclude                                - Extra
concat( pizza_name,  case  when exclu is null then ''
                     else concat(' - ','Exclude ',exclu) end
																,case  when extr is null then ''
																 else  concat(' - ','Extra ',extr) end) pizaa_ditials
from cte1
left join cte2 on cte1.rn=cte2.rn
left join cte3 on cte1.rn= cte3.rn;




--22. Generate an alphabetically ordered, comma-separated ingredient list for each pizza order, using "2x" for duplicates.
with cte1 as ( -- basic info
select order_id,co.pizza_id,pn.pizza_name,pr.toppings,exclusions,extras,ROW_NUMBER()over(order by order_time) rn
from pizza_delivery_india.customer_orders co
join pizza_delivery_india.pizza_recipes pr on co.pizza_id=pr.pizza_id
join pizza_delivery_india.pizza_names pn on co.pizza_id=pn.pizza_id
)
,cte2 as ( -- toping with extra
select rn,try_cast(value as int) value from cte1
cross apply string_split(toppings,',')
union all
select rn,try_cast(value as int) value from cte1
cross apply string_split(extras,',')
where extras is not null and extras <> ''
),cte3 as ( --  indi+extra-  exclusion 
select rn,value,ROW_NUMBER()over( partition by rn,value order by value) rn2 from cte2
EXCEPT
select rn, try_cast(value as int) value, ROW_NUMBER()over( partition by rn,value order by value) rn2  from cte1
cross apply string_split(exclusions,',')
where exclusions is not null and extras <> ''
),
cte4 as (
select rn,value,count(value) as counts from cte3
group by rn,value
), --using "2x" for duplicates
cte5 as (
select rn,string_agg(
case when counts>1 then concat(try_cast(counts as varchar),'X ',pt.topping_name)
else pt.topping_name
end
,',') within group(order by pt.topping_name) all_ingridiants from cte4
join pizza_delivery_india.pizza_toppings pt on cte4.value=pt.topping_id
group by rn)
select order_id,cte1.pizza_name,all_ingridiants from cte1
join cte5 on cte1.rn=cte5.rn;
--    * Example: "Paneer Tikka: 2xCheese, Corn, Mushrooms, Schezwan Sauce"


--23. What is the total quantity of each topping used in all successfully delivered pizzas, sorted by most used first?

--- topings exclusion, extra
with cte1 as(
select co.pizza_id,toppings,exclusions,extras from pizza_delivery_india.customer_orders co
join pizza_delivery_india.pizza_recipes pr on co.pizza_id=pr.pizza_id
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id
where ro.cancellation is null or cancellation=''
),
cte2 as( -- exclution or count
select try_cast(value as int) value,count(*) exclusion_count from cte1
cross apply
string_split(exclusions,',')
where exclusions<>''
group by try_cast(value as int)
),
cte3 as( select try_cast(value as int) value,count(*) extra_count from cte1 -- extra count
cross apply
string_split(extras,',')
where extras<>''
group by try_cast(value as int) 
)
,cte4 as (
select try_cast(value as int) value , count(*) all_count from cte1
cross apply
string_split(toppings,',')
group by try_cast(value as int)
)
--select *, all_count+ nullif(extra_count,0)-nullif(exclusion_count,0) as no_of_pizza from pizza_delivery_india.pizza_toppings pt
select topping_id, topping_name,all_count+isnull(extra_count,0)-isnull(exclusion_count,0) as total_quantity from pizza_delivery_india.pizza_toppings pt
left join cte4 on pt.topping_id=cte4.value
left join cte3 on pt.topping_id=cte3.value
left join cte2 on pt.topping_id=cte2.value
order by total_quantity desc;


--24. If a 'Paneer Tikka' pizza costs ₹300 and a 'Veggie Delight' costs ₹250 (no extra charges), how much revenue has Pizza Delivery India generated (excluding cancellations)?
select  sum( case pn.pizza_name when 'Paneer Tikka' then 300 when 'Veggie Delight' then 250 end) as Revenue
from pizza_delivery_india.pizza_names pn
join pizza_delivery_india.customer_orders co on pn.pizza_id=co.pizza_id
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id
where ro.cancellation is null or ro.cancellation=''

-- 1 or way more

with pizza_price as (
select pn.pizza_id,pn.pizza_name ,
case pn.pizza_name when 'Paneer Tikka' then 300 when  'Veggie Delight' then 250 end as price
from pizza_delivery_india.pizza_names pn
join pizza_delivery_india.customer_orders co on pn.pizza_id=co.pizza_id
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id
where ro.cancellation is null or ro.cancellation=''
) select sum(price) as  total_revenue  from pizza_price;


--25. What if there’s an additional ₹20 charge for each extra topping?

 with cte as (
select co.order_id, pn.pizza_id,pn.pizza_name ,
case pn.pizza_name when 'Paneer Tikka' then 300 when  'Veggie Delight' then 250 end as price
,isnull( case
		when extras is not null and extras<>'' then ( select count(value) from string_split(extras,',') where extras<>'')
		end,0) as extras_topping
from pizza_delivery_india.pizza_names pn
join pizza_delivery_india.customer_orders co on pn.pizza_id=co.pizza_id
)
select order_id,pizza_id,pizza_name, price+(extras_topping*20) as price  from cte
order by order_id;

-- both exclude and extra
 with cte as (
select co.order_id, pn.pizza_id,pn.pizza_name ,
case pn.pizza_name when 'Paneer Tikka' then 300 when  'Veggie Delight' then 250 end as price
,
isnull( case
            when exclusions is not null and exclusions<>'' then ( select count(value) from string_split(exclusions,',') where exclusions<>'')
       end,0) as exclusion_topping,

isnull( case
		when extras is not null and extras<>'' then ( select count(value) from string_split(extras,',') where extras<>'')
		end,0) as extras_topping
from pizza_delivery_india.pizza_names pn
join pizza_delivery_india.customer_orders co on pn.pizza_id=co.pizza_id
)
select order_id,pizza_id,pizza_name, price-(exclusion_topping*20)+(extras_topping*20) as price  from cte
order by order_id;



  

--26. Cheese costs ₹20 extra — apply this specifically where Cheese is added as an extra.
 with cte as (
select co.order_id, pn.pizza_id,pn.pizza_name ,
case pn.pizza_name when 'Paneer Tikka' then 300 when  'Veggie Delight' then 250 end as price
,isnull( case
		when extras is not null and extras<>'' then ( select count(value) from string_split(extras,',')v 
		join pizza_delivery_india.pizza_toppings pt on TRY_CAST(v.value as int)=pt.topping_id where extras<>'' and pt.topping_name='Cheese'
		)
		end,0) as extras_topping
from pizza_delivery_india.pizza_names pn
join pizza_delivery_india.customer_orders co on pn.pizza_id=co.pizza_id
)
select order_id,pizza_id,pizza_name, price+(extras_topping*20) as price  from cte;


--27. Design a new table for customer ratings of riders. Include:

--    * rating_id, order_id, customer_id, rider_id, rating (1-5), comments (optional), rated_on (DATETIME)

--    Example schema:

--    ```sql
--    CREATE TABLE pizza_delivery_india.rider_ratings (
--      rating_id INT IDENTITY PRIMARY KEY,
--      order_id INT,
--      customer_id INT,
--      rider_id INT,
--      rating INT CHECK (rating BETWEEN 1 AND 5),
--      comments NVARCHAR(255),
--      rated_on DATETIME
--    );
--    ```

/*
    CREATE TABLE pizza_delivery_india.rider_ratings (
      rating_id INT IDENTITY PRIMARY KEY,
      order_id INT,
      customer_id INT,
      rider_id INT,
      rating INT CHECK (rating BETWEEN 1 AND 5),
      comments NVARCHAR(255),
      rated_on DATETIME
    );

	*/
---------------------------------------------------------
--28. Insert sample data into the ratings table for each successful delivery.

set identity_insert pizza_delivery_india.rider_ratings on;

with t1 as (
select ROW_NUMBER() over(order by co.order_id) as rating_id,
co.order_id,co.customer_id,ro.rider_id ,
cast(rand()*co.order_id as int)%5+1 as rating,
DATEADD(hour,1,ro.pickup_time) as ratingtime
from pizza_delivery_india.customer_orders co
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id
where ro.cancellation is null or ro.cancellation=''
group by co.order_id,co.customer_id,ro.rider_id,DATEADD(hour,1,ro.pickup_time)
) , dummydata as (select t1.rating_id,order_id,customer_id,rider_id,rating,case when rating>3 then 'behaviours was good'
					when rating >1 then 'he mess my pizza'
					else 'not good'
end as comments,ratingtime
from t1 )

insert into pizza_delivery_india.rider_ratings
(rating_id,order_id,customer_id,rider_id,rating,comments,rated_on)
select rating_id,order_id,customer_id,rider_id,rating,comments,ratingtime from dummydata;

select * from pizza_delivery_india.rider_ratings;



--29. Join data to show the following info for successful deliveries:

--    * customer_id
--    * order_id
--    * rider_id
--    * rating
--    * order_time
--    * pickup_time
--    * Time difference between order and pickup (in minutes)
--    * Delivery duration
--    * Average speed (km/h)
--    * Number of pizzas in the order
with cte as (
select distinct customer_id,co.order_id,rider_id,order_time,pickup_time,DATEDIFF(MINUTE,order_time,pickup_time) Time_diff
---duration*******
,try_cast(
case
 when PATINDEX('%[a-zA-Z ]%',duration)>0 then
      SUBSTRING(duration, 1,PATINDEX('%[a-zA-Z ]%',duration)-1)
	  else duration
end as int) as duration ,
-- duration
----disatnce
try_cast(replace(ro.distance,'km','') as float) as distance
--- distance
,count(pizza_id)over(partition by customer_id,co.order_id) as Number_pizaa
from pizza_delivery_india.customer_orders co
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id )
select cte.customer_id,cte.order_id,cte.rider_id,r.rating,cte.order_time,cte.pickup_time,cte.Time_diff,cte.duration,
round(cte.distance/(cte.duration/60.0),2) as avg_speed
,cte.Number_pizaa
from cte join pizza_delivery_india.rider_ratings r on cte.order_id=r.order_id;

--30. If Paneer Tikka is ₹300, Veggie Delight ₹250, and each rider is paid ₹2.50/km, what is Pizza Delivery India's profit after paying riders?
with cte as(
select co.order_id,pn.pizza_name
--********* disatace data clean******************
,try_cast(replace(distance,'km','') as float) as distance
--------*********************----------
from pizza_delivery_india.customer_orders co
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id
join pizza_delivery_india.pizza_names pn on co.pizza_id=pn.pizza_id
where ro.cancellation=''or ro.cancellation is null
)
select sum(case when pizza_name='Paneer Tikka' then 1 end)*300
+ sum(case when pizza_name='veggie Delight' then 1 end)*250
- sum(distance)*2.50 as profit from cte;

with cte as(
select co.order_id,pn.pizza_name
--********* disatace data clean******************
,try_cast(replace(distance,'km','') as float) as distance
--------*********************----------
from pizza_delivery_india.customer_orders co
join pizza_delivery_india.rider_orders ro on co.order_id=ro.order_id
join pizza_delivery_india.pizza_names pn on co.pizza_id=pn.pizza_id
where ro.cancellation=''or ro.cancellation is null
)
select sum(case when pizza_name='Paneer Tikka' then 300
               when pizza_name='veggie Delight' then 250 end)
- sum(distance)*2.50 as profit from cte;



--31. If the owner wants to add a new “Supreme Indian Pizza” with all available toppings, how would the existing design support that? Provide an example `INSERT`:

select * from pizza_delivery_india.pizza_names;
select * from pizza_delivery_india.pizza_recipes;

/*

insert into pizza_delivery_india.pizza_names
values(3,'Supreme Indian Pizza');

select * from pizza_delivery_india.pizza_names;

insert into pizza_delivery_india.pizza_recipes
values(3,(select STRING_AGG(topping_id,',') 
from pizza_delivery_india.pizza_toppings));

*/
---

