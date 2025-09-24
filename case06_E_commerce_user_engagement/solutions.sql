select * from user_engagement.events
	select * from user_engagement.users;
	select * from user_engagement.event_identifier;
	select * from user_engagement.page_hierarchy;
select * from user_engagement.campaign_identifier;
   select * from user_engagement.campaign_product; -- bnayi huyi tempary table


---
select *from user_engagement.events e
join user_engagement.users u on e.cookie_id=u.cookie_id
join user_engagement.event_identifier ei on e.event_type=ei.event_type
join user_engagement.page_hierarchy p on e.page_id=p.page_id
join user_engagement.campaign_product cp on p.product_id=cp.product_id
join user_engagement.campaign_identifier ci on cp.campaign_id=ci.campaign_id


--
--first data clean camping_identifire me product 1-3 hai 1,2,3 me thodna hai, 
with cte as
    (     select distinct campaign_id,cast(min(value)over(partition by campaign_id) as int) as min,
		                              cast(max(value)over(partition by campaign_id) as int) as max 
		   from user_engagement.campaign_identifier
		   cross apply string_split(products,'-') 
	)
,rec as 
      (     select campaign_id,max,min
            from cte
      
            union all
      
			select campaign_id,max,min+1
			from rec 
			where min<max
      )
select campaign_id,min as product_id 
--into user_engagement.campaign_product
from rec
order by campaign_id,min;


--# SET A

--1. How many distinct users are in the dataset?
select count(distinct user_id) distinct_users from user_engagement.users;

--2. What is the average number of cookie IDs per user?
select  avg(cookie) avg_no_cookie 
	from (select user_id,count( distinct cookie_id)as cookie from user_engagement.users
			group by user_id) as ue;


--3. What is the number of unique site visits by all users per month?
select FORMAT(event_time, 'yyyy-MM') months ,
		count(distinct visit_id) as unique_side_visited
from user_engagement.events e
join user_engagement.users u on e.cookie_id=u.cookie_id
group by FORMAT(event_time, 'yyyy-MM')
order by months;

--4. What is the count of each event type?

select ei.event_name , count(*) as count  from user_engagement.events e
join user_engagement.event_identifier ei on e.event_type=ei.event_type
group by ei.event_name
order by count desc;



select event_type,count(*) as count  from user_engagement.events
group by event_type
order by event_type;






--5. What percentage of visits resulted in a purchase?
--------*********************------------
select round( count(distinct case when event_type=3 then visit_id end)/
       cast(count(distinct visit_id) as float),4)*100 purchase_visit_perent
	   from user_engagement.events;


-------------*******************--------------------
-- use COUNT(DISTINCT visit_id)  nhi tho 1 visit id pr multiple purchase count ho jayenge

with visited as (
select count(distinct visit_id) as count_total from user_engagement.events
),
purchase as (
select count(visit_id) as count from user_engagement.events e
join user_engagement.event_identifier ei on e.event_type=ei.event_type
where event_name='Purchase')
select round(count /cast(count_total as float),4)*100  per from visited,purchase;

---------*************************---------
-- 2nd way

select round( (try_cast(count(distinct visit_id) as float)
			/(select count(distinct visit_id) from user_engagement.events)
		 ),4)*100  per		 
		 from user_engagement.event_identifier ei
join user_engagement.events e on ei.event_type=e.event_type
where ei.event_name='Purchase';
---------*************************---------
--- 3rd way
select  (try_cast
			(count(case when ei.event_name='Purchase' then 1 else null end)
			as float)
		/count(distinct visit_id) )*100 per
		
		from user_engagement.event_identifier ei
join user_engagement.events e on ei.event_type=e.event_type;
---------*************************---------



--6. What percentage of visits reached checkout but not purchase?

-- page_id=12 --> chekout,event_type=3 --> purchase

with cta1 as(select visit_id, count(distinct case when page_id=12 then page_id end ) as count_chek_out
			   ,count(distinct case when event_type=3 then event_type end ) as count_purchase
            from user_engagement.events group by visit_id
          )
select     ROUND( cast(count(*)as float)
         /(select count(distinct visit_id) count_visited from user_engagement.events),4)*100 as per
from cta1
where count_chek_out=1 and count_purchase=0;


-- 2nd way with join --
with cta1 as(select visit_id, count(distinct case when page_name='Checkout' then page_name end ) as count_chek_out
			,count(distinct case when event_type=3 then event_type end ) as count_purchase
from user_engagement.events e
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
group by visit_id)
select ROUND( count(*)
         /cast((select count(distinct visit_id) count_visited from user_engagement.events) as float),4)*100
		 as per
		 from cta1
where count_chek_out=1 and count_purchase=0;

--- ****************** steps *****************-----

--step 1******** chekout mtlb ander aaya but purchase ni kRA
select visit_id,event_type,page_name from user_engagement.events e
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
where page_name='Checkout' or event_type=3
order by page_name;
--------------*******************-----------------
---step 2 ********** dono ke count nikal liye 
select visit_id, count(distinct case when page_name='Checkout' then page_name end ) as count_chek_out
			,count(distinct case when event_type=3 then event_type end ) as count_purchase
from user_engagement.events e
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
group by visit_id;


---**step 3******* ab valid visit_id

with cta1 as(select visit_id, count(distinct case when page_name='Checkout' then page_name end ) as count_chek_out
			,count(distinct case when event_type=3 then event_type end ) as count_purchase
from user_engagement.events e
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
group by visit_id)
select * from cta1
where count_chek_out=1 and count_purchase=0;
--- step 4******** aab count nikal lenge
with cta1 as(select visit_id, count(distinct case when page_name='Checkout' then page_name end ) as count_chek_out
			,count(distinct case when event_type=3 then event_type end ) as count_purchase
from user_engagement.events e
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
group by visit_id)
select count(*) from cta1
where count_chek_out=1 and count_purchase=0;
----
---step 5  ******** total visited se divide

with cta1 as(select visit_id, count(distinct case when page_name='Checkout' then page_name end ) as count_chek_out
			,count(distinct case when event_type=3 then event_type end ) as count_purchase
from user_engagement.events e
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
group by visit_id)
select ROUND( count(*)
         /cast((select count(distinct visit_id) count_visited from user_engagement.events) as float),4)*100
		 as per
		 from cta1
where count_chek_out=1 and count_purchase=0;

-----------************************************--------------------------------


--- next way visited count only jo chekout kiy or purchase na kiya
select round( cast(count(distinct visit_id)as float)/
       (select count(distinct  visit_id) from user_engagement.events),4)*100 per_count
from user_engagement.events e
where page_id=12 and e.visit_id not in ( select distinct visit_id from user_engagement.events where event_type=3)
-- step 1 jine chek out kiya but purchase kiya tho usko hta denge
select count(distinct visit_id) from user_engagement.events e
where page_id=12 and e.visit_id not in ( select distinct visit_id from user_engagement.events where event_type=3)
-- step 2 total nikal ke percnet
select round( cast(count(distinct visit_id)as float)/
       (select count(distinct  visit_id) from user_engagement.events),4)*100 per_count
from user_engagement.events e
where page_id=12 and e.visit_id not in ( select distinct visit_id from user_engagement.events where event_type=3)



--7. What are the top 3 most viewed pages?

-- page view --mtlb event_type=1 ,page_view

select top 3 page_id,count(page_id) as page_count from user_engagement.events
where event_type=1
group by page_id
order by page_count desc;
-------------******************************--------------------
select page_id from
(
select page_id,count(page_id) as page_count,
ROW_NUMBER()over(order by count(page_id) desc) rn
from user_engagement.events
where event_type=1
group by page_id
) p_counts
where rn<4;
----------------************************----------------------

--8. What are the views and add-to-cart counts per product category?
--- event_type=1 -> View
-- event_type=2 -> add-to-cart
select product_category, count(case when event_type=1 then 1  end) as views,
						count(case when event_type=2 then 1  end) as add_to_cart 
from user_engagement.events e
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
where product_category is not null
group by product_category;


--9. What are the top 3 products by purchases?
-- event_type=3 --> event_name=purchase

with cta as
	(
	 select visit_id,e.page_id,e.event_type,ei.event_name,ph.product_id from user_engagement.events e 
	join user_engagement.event_identifier ei on e.event_type=ei.event_type
	join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
	where e.event_type=2 and exists (select 1 from user_engagement.events where event_type=3 and e.visit_id=visit_id)
		--order by visit_id,event_time;
    )
select top 3 product_id,count(product_id) as product_sale  from cta
group by product_id
order by product_sale desc;

--******************--
-- step 1 event le aao or sath me purchase hua hai ki ni,or sath me products
select * from user_engagement.events e 
join user_engagement.event_identifier ei on e.event_type=ei.event_type
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
where e.event_type=2 or e.event_type=3
order by visit_id,event_time;

-- step 2 only  prchase wale
select * from user_engagement.events e 
join user_engagement.event_identifier ei on e.event_type=ei.event_type
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
where e.event_type=2
	and visit_id in (select  distinct visit_id from user_engagement.events where event_type=3)
order by visit_id,event_time;
-- step 3 aab count nikal lenge products ka or count
with cta as
	(
	 select visit_id,e.page_id,e.event_type,ei.event_name,ph.product_id,page_name from user_engagement.events e 
	join user_engagement.event_identifier ei on e.event_type=ei.event_type
	join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
	where e.event_type=2
	and visit_id in (select  distinct visit_id from user_engagement.events where event_type=3)
		--order by visit_id,event_time;
    )
select top 3  product_id,page_name,count(product_id) as product_sale  from cta
group by product_id,page_name
order by product_sale desc;


--# SET B

--10. Create a product-level funnel table with views, cart adds, abandoned carts, and purchases.

with cta1 as (
	select product_id,
		count( case when event_name = 'Page View' and e.page_id not in (1,2) then 1 end )as views,
		count(case when event_name = 'Add to Cart'  then 1 end )as card_adds
	from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	join user_engagement.event_identifier ei on e.event_type=ei.event_type
	group by product_id),
cta2 as (
	select product_id,count(*) abandoned_carts from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	where event_type=2 and not exists( select 1 from user_engagement.events ev where e.visit_id=ev.visit_id and ev.event_type=3)
	group by product_id)
,cta3 as(
	select product_id,count(*) purchase from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	where event_type=2 and exists( select 1 from user_engagement.events ev where e.visit_id=ev.visit_id and ev.event_type=3)
	group by product_id)
select cta3.product_id,views,card_adds,abandoned_carts,purchase  from cta3
join cta1 on cta1.product_id=cta3.product_id
join cta2 on cta2.product_id=cta3.product_id
order by product_id;

--11. Create a category-level funnel table with the same metrics as above.
with cta1 as (
	select product_id,
		count( case when event_name = 'Page View' and e.page_id not in (1,2) then 1 end )as views,
		count(case when event_name = 'Add to Cart'  then 1 end )as card_adds
	from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	join user_engagement.event_identifier ei on e.event_type=ei.event_type
	group by product_id),
cta2 as (
	select product_id,count(*) abandoned_carts from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	where event_type=2 and not exists( select 1 from user_engagement.events ev where e.visit_id=ev.visit_id and ev.event_type=3)
	group by product_id)
,cta3 as(
	select product_id,count(*) purchase from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	where event_type=2 and exists( select 1 from user_engagement.events ev where e.visit_id=ev.visit_id and ev.event_type=3)
	group by product_id)
select ph.product_category , sum(views) as views ,sum(card_adds) card_adds,sum(abandoned_carts) abandoned_carts, sum(purchase) purchase  from cta3
join user_engagement.page_hierarchy ph on cta3.product_id=ph.product_id
join cta1 on cta1.product_id=cta3.product_id
join cta2 on cta2.product_id=cta3.product_id
group by ph.product_category;


--12. Which product had the most views, cart adds, and purchases?

with most_view as (
				
select top 1 product_id,
		count( case when event_name = 'Page View' and e.page_id not in (1,2) then 1 end )as views
	from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	join user_engagement.event_identifier ei on e.event_type=ei.event_type
	where product_id is not null
	group by product_id
	ORDER BY views desc
				   ),
most_cards_add as (

select top 1 product_id,
		count(case when event_name = 'Add to Cart'  then 1 end )as card_adds
	from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	join user_engagement.event_identifier ei on e.event_type=ei.event_type
	where product_id is not null
	group by product_id
	order by card_adds desc
				 ),
most_purchase as (
		select top 1 ph.product_id,count(*) purchase_count from user_engagement.events e 
		join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
		where e.event_type=2 and exists ( select 1 from user_engagement.events ev
		                                   where e.visit_id=ev.visit_id and ev.event_type=3  )
		group by product_id
		order by purchase_count desc
					)
--12. Which product had the most views, cart adds, and purchases?
select most_view.product_id as most_views,
	 most_cards_add.product_id as most_cards_add
	 ,most_purchase.product_id as most_purchase
from most_view,most_cards_add,most_purchase;

--13. Which product was most likely to be abandoned?
with aband as (
	select top 1 ph.product_id,count(*) abandoned from user_engagement.events e 
	join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
	where e.event_type=2 and not exists ( select 1 from user_engagement.events ev
	                                   where e.visit_id=ev.visit_id and ev.event_type=3  )
	group by product_id
	order by abandoned desc
	)
	select product_id as most_likely_abandoned from aband;

--14. Which product had the highest view-to-purchase conversion rate?

with cta1 as (
	select product_id,
		count(* )as views
	from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	join user_engagement.event_identifier ei on e.event_type=ei.event_type
	where event_name = 'Page View' and e.page_id not in (1,2) 
	group by product_id)
,cta2 as(
	select product_id,count(*) purchase from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	where event_type=2 and exists( select 1 from user_engagement.events ev where e.visit_id=ev.visit_id and ev.event_type=3)
	group by product_id)

select top 1 cta2.product_id,views,purchase,round(cast(purchase as float)/views,5)*100 max_diff  from cta2
join cta1 on cta1.product_id=cta2.product_id
order by max_diff desc;	

--**************** SECOND WAY
with cta1 as (
	select product_id,
		count( case when event_name = 'Page View' and e.page_id not in (1,2) then 1 end )as views
	from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	join user_engagement.event_identifier ei on e.event_type=ei.event_type
	group by product_id)
,cta3 as(
	select product_id,count(*) purchase from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	where event_type=2 and exists( select 1 from user_engagement.events ev where e.visit_id=ev.visit_id and ev.event_type=3)
	group by product_id)

select top 1 cta3.product_id,views,purchase,round(cast(purchase as float)/views,5)*100 max_diff  from cta3
join cta1 on cta1.product_id=cta3.product_id
order by max_diff desc;


--15. What is the average conversion rate from view to cart add?
with cta as (
	select product_id,
		count( case when event_name = 'Page View' and e.page_id not in (1,2) then 1 end )as views,
		count(case when event_name = 'Add to Cart'  then 1 end )as card_adds
	from user_engagement.page_hierarchy ph
	join user_engagement.events e on ph.page_id=e.page_id
	join user_engagement.event_identifier ei on e.event_type=ei.event_type
	where product_id is not null
	group by product_id )
select round( avg( (cast( card_adds as float)/views)*100),3) as avg_conversion_rate from cta;


--16. What is the average conversion rate from cart add to purchase?

with count_cards as(
	select product_id,count(*) add_cards
		from user_engagement.page_hierarchy ph
		join user_engagement.events e on ph.page_id=e.page_id
		join user_engagement.event_identifier ei on e.event_type=ei.event_type
		where event_name = 'Add to Cart'
		group by product_id ),
count_purchase as (
	select product_id,count(*) purchase from user_engagement.page_hierarchy ph
		join user_engagement.events e on ph.page_id=e.page_id
		where event_type=2 and exists( select 1 from user_engagement.events ev where e.visit_id=ev.visit_id and ev.event_type=3)
		group by product_id
	 ) --  What is the average conversion rate from cart add to purchase?
select round(avg( (cast(purchase as float)/
          add_cards )*100  ),3) as Con_rate
from count_cards c
join count_purchase p on c.product_id=p.product_id;

--# SET C.

--17. Create a visit-level summary table with user_id, visit_id, visit start time, event counts, and campaign name.
with camping_names as(
	select distinct visit_id,user_id,ci.campaign_name from user_engagement.events e
	join  user_engagement.users u on e.cookie_id=u.cookie_id
	join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
	join user_engagement.campaign_product cp on ph.product_id=cp.product_id
	join user_engagement.campaign_identifier ci on cp.campaign_id=ci.campaign_id
	where e.event_time between ci.start_date and ci.end_date
)
,camping_names_join as(
		select visit_id,user_id,STRING_AGG( campaign_name,' , ') as campaign_name from camping_names
		GROUP BY visit_id,user_id)
,start_time_event_c as (
select visit_id,user_id,min(event_time) start_time,count(event_type) as event_count from user_engagement.events e
join  user_engagement.users u on e.cookie_id=u.cookie_id
group by visit_id,user_id
)--user_id, visit_id, visit start time, event counts, and campaign name
select se.user_id, se.visit_id,start_time,event_count,campaign_name from start_time_event_c se
left join camping_names_join cn on se.visit_id=cn.visit_id and se.user_id=cn.user_id
order by user_id,visit_id;

--18. (Optional) Add a column for comma-separated cart products sorted by order of addition.

with camping_names as(
	select distinct visit_id,user_id,ci.=campaign_name from user_engagement.events e
	join  user_engagement.users u on e.cookie_id=u.cookie_id
	join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
	join user_engagement.campaign_product cp on ph.product_id=cp.campaign_id
	join user_engagement.campaign_identifier ci on cp.campaign_id=ci.campaign_id
	where e.event_time between ci.start_date and ci.end_date
)
,camping_names_join as(
		select visit_id,user_id,STRING_AGG( campaign_name,' , ') as campaign_name from camping_names
		GROUP BY visit_id,user_id)
,start_time_event_c as (
select visit_id,user_id,min(event_time) start_time,count(event_type) as event_count from user_engagement.events e
join  user_engagement.users u on e.cookie_id=u.cookie_id
group by visit_id,user_id
),
product_list as (
	select user_id,visit_id, STRING_AGG( ph.page_name ,' , ' )within group(order by e.event_time) cart_products  from user_engagement.events e
	join user_engagement.users u on e.cookie_id=u.cookie_id
	join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
	where product_id is not null and e.event_type=2
	group by user_id,visit_id
)

--user_id, visit_id, visit start time, event counts, and campaign name
select se.user_id, se.visit_id,start_time,event_count,campaign_name,cart_products from start_time_event_c se
left join camping_names_join cn on se.visit_id=cn.visit_id and se.user_id=cn.user_id
left join product_list pl on se.visit_id=pl.visit_id and se.user_id=pl.user_id
order by user_id,visit_id;

--# Further Investigations

--19. Identify users exposed to campaign impressions and compare metrics with those who were not.

with exposed_users_visit as (
	select distinct visit_id,user_id from user_engagement.users u
		join user_engagement.events e on u.cookie_id=e.cookie_id
		join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
		join user_engagement.campaign_product cp on ph.product_id=cp.product_id 
		join user_engagement.campaign_identifier ci on cp.campaign_id=ci.campaign_id
	where event_time between ci.start_date and ci.end_date
	), main as (
select user_id,e.cookie_id,visit_id,e.page_id,e.event_type,ph.product_id from user_engagement.users u
join user_engagement.events e on u.cookie_id=e.cookie_id
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
),
expode as (
select 'Expode' as status, count(distinct m.user_id) as users,
		count(distinct m.visit_id) as visitid,
		count(product_id) product_id,
		count(event_type) as event_type,
		count(case when event_type =3 then 1 end) as add_card
from main as m 
join exposed_users_visit ex on m.visit_id=ex.visit_id and m.user_id=ex.user_id
)
select 'UN Expode' as status, count(distinct m.user_id) as users,
		count(distinct m.visit_id) as visitid,
		count(product_id) product_id,
		count(event_type) as event_type,
		count(case when event_type =3 then 1 end) as add_card
from main as m 
left join exposed_users_visit ex on m.visit_id=ex.visit_id and m.user_id=ex.user_id
where ex.visit_id is null and ex.user_id is null
union all
select * from expode;


--20. Does clicking on an impression lead to higher purchase rates?
with clicking as(
	select distinct visit_id,cookie_id from user_engagement.events e
	join user_engagement.page_hierarchy ph on ph.page_id=e.page_id
	where event_type = 5
	 )
, purchase_items as (
select e.visit_id,e.cookie_id , count(product_id) as purchase from user_engagement.events e
join user_engagement.page_hierarchy ph on e.page_id=ph.page_id
where e.event_type=2 and exists (select * from user_engagement.events
               where visit_id=e.visit_id and event_type=3)
			   group by visit_id,cookie_id
)
select sum(purchase) from purchase_items p join clicking c on c.visit_id=p.visit_id and c.cookie_id=p.cookie_id

union all 

select sum(purchase) from purchase_items p left join clicking c on c.visit_id=p.visit_id and c.cookie_id=p.cookie_id
where c.visit_id is null and c.cookie_id is null;

--21. What is the uplift in purchase rate for users who clicked an impression vs. those who didn’t?

--22. What metrics can be used to evaluate the success of each campaign?


---------********************---------



