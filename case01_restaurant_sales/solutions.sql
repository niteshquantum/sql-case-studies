use restaurant_case_study;
select * from sales;
select * from members;
select * from menu;

---- 
-- Practice Question Case Study 1

-- 1. Total amount spent by each customer

--solutions
-- member table me 2 customers hai only
select c.customer_id ,sum(price) as total_spend
	from members c
	join sales s on c.customer_id=s.customer_id
	join menu m on s.product_id=m.product_id
	group by c.customer_id;

-- but sales table me 3 customers hai
select s.customer_id ,sum(price) as total_spend
	from  sales s 
	join menu m on s.product_id=m.product_id
	group by s.customer_id;

-- 2. Number of distinct visit days per customer

--solutoin
-- hmare pass slaes table me customer ki id hai or orderdate hai 
select s.customer_id,count(distinct s.order_date) as disVisitDay
	from sales s
	group by s.customer_id;

-- 3. First item purchased by each customer
with cus as (
		select s.customer_id,p.product_name,s.order_date,
		ROW_NUMBER()OVER(partition by s.customer_id order by s.order_date) as row_num
		from sales s
		join menu p on s.product_id=p.product_id
		 ) 
	select  customer_id,product_name from cus
	where row_num=1;

with cus as (
		select s.customer_id,p.product_name,s.order_date,
		rank()OVER(partition by s.customer_id order by s.order_date) as rank
		from sales s
		join menu p on s.product_id=p.product_id
		 ) 
	select  customer_id,product_name from cus
	where rank=1;
-- 4. Most purchased item and count

select top 1 p.product_id,p.product_name,count(p.product_id) count
from menu p 
join sales s on p.product_id=s.product_id
group by p.product_id,p.product_name
order by count desc;

-- 5. Most popular item per customer
-- solution
-- 1 but isme 1 hi product ayega
with popular as (
					select s.customer_id,m.product_id,m.product_name ,count(m.product_id) as productcount,
					row_number()over(partition by s.customer_id order by count(m.product_id) desc) as row_n
					from sales s
					join menu m on s.product_id=m.product_id
					group by s.customer_id,m.product_id,m.product_name
				) 
		select customer_id,product_id,product_name,productcount  from popular
		where row_n=1;

-- or isme many hi product ayega
with popular as (
					select s.customer_id,m.product_id,m.product_name ,count(m.product_id) as productcount,
					rank()over(partition by s.customer_id order by count(m.product_id) desc) as rank_n
					from sales s
					join menu m on s.product_id=m.product_id
					group by s.customer_id,m.product_id,m.product_name
				) 
		select customer_id,product_id,product_name,productcount from popular
		where rank_n=1;

-- 6. First item after becoming a member
-- wo order customer ko groupin ,lenge member  date ke baad wale,or row no.de denge 
with first_order as (
				select m.customer_id,p.product_name,s.order_date,
				row_number()over(partition by m.customer_id order by s.order_date) as row_n
				from members m
				join sales s on m.customer_id=s.customer_id
				join menu p on s.product_id=p.product_id
				where s.order_date>=m.join_date
				group by m.customer_id,p.product_name,s.order_date
				)
				select customer_id,product_name,order_date from first_order
				where row_n=1;

-- 7. Last item before becoming a member
with first_order as (
				select m.customer_id,p.product_name,s.order_date,
				row_number()over(partition by m.customer_id order by s.order_date desc) as row_n
				from members m
				join sales s on m.customer_id=s.customer_id
				join menu p on s.product_id=p.product_id
				where s.order_date<m.join_date
				group by m.customer_id,p.product_name,s.order_date
				)
				select customer_id,product_name,order_date from first_order
				where row_n=1;
-- 8. Items and amount before becoming a member

				-----------------
select m.customer_id,p.product_name,p.price, s.order_date
				from members m
				join sales s on m.customer_id=s.customer_id
				join menu p on s.product_id=p.product_id
				where s.order_date<m.join_date
			

-- 9. Loyalty points: 2x for biryani, 1x for others
select s.customer_id,s.order_date,p.product_name,
	case p.product_name
		when 'biryani' then '2X'
		else '1X'
	end as loyalty_point
from  sales s
join menu p on s.product_id=p.product_id

-- 10. Points during first 7 days after joining
select distinct s.customer_id,s.order_date,m.join_date,p.product_name,
												case p.product_name
													when 'biryani' then '2X'
													else '1X'
												end as loyalty_point
	from  sales s
	join menu p on s.product_id=p.product_id
	join members m on s.customer_id=m.customer_id
	where s.order_date between m.join_date and  dateadd(day,7,m.join_date);

-- 11. Total spent on biryani
select p.product_name,SUM(p.price) as total_spend
	from menu p 
	join sales s on s.product_id=p.product_id
	where p.product_name='biryani'
	group by p.product_name;

-- 12. Customer with most dosai orders
with customer_dosa_count as (
select s.customer_id,p.product_name,count(*) as dosaordercount
from sales s
join menu p on s.product_id=p.product_id
where p.product_name='dosai'
group by s.customer_id,p.product_name
)
select * from customer_dosa_count as c
where c.dosaordercount=(select max(c1.dosaordercount) from customer_dosa_count c1);

with customer_dosa_count as (
select s.customer_id,p.product_name,count(*) as dosaordercount
,rank()over(order by count(*) desc) ranking
from sales s
join menu p on s.product_id=p.product_id
where p.product_name='dosai'
group by s.customer_id,p.product_name
)
select * from customer_dosa_count as c
where c.ranking=1;
 
-- 13. Average spend per visit


-- visit mtlb customer me ktni bar visit kiya or order kiya usko 

select s.customer_id ,count(s.order_date) as no_visit,
		sum(p.price) as total_price
	from menu p
	join sales s on p.product_id=s.product_id
	group by s.customer_id;

select s.customer_id ,
		sum(p.price),count(s.order_date) as avgspend
	from menu p
	join sales s on p.product_id=s.product_id
	group by s.customer_id;

select s.customer_id ,avg(p.price) as avg_visit
	from menu p
	join sales s on p.product_id=s.product_id
	group by s.customer_id;

-- 14. Day with most orders in Jan 2025
with orders2025 as (
select s.order_date,count(s.product_id) as order_count
	,rank()over(order by count(s.product_id) desc) ranking
	from sales s
	where YEAR(s.order_date)=2025 and month(s.order_date)=1
	group by s.order_date
	)
	select o.order_date,day(o.order_date)as day,o.order_count as toatal_order  from orders2025 as o
	where ranking=1;

-- only whi customer jo jo date ke ho phir cte bna kr kr ranking
select s.customer_id,s.order_date,s.product_id
	from sales s
	where YEAR(s.order_date)=2025 and month(s.order_date)=1



-- 15. Customer who spent the least
with t_spend as (
select s.customer_id,sum(p.price) as total_spend,
			rank()over(order by sum(p.price)) as ranking
			from sales s
		join menu p on s.product_id=p.product_id
		group by s.customer_id
		)
		select customer_id,total_spend from t_spend
		where ranking=1;
-- 16. Date with most money spent
with spend_by_date as (
	select s.order_date,sum(p.price) as total_spend
		,rank()over(order by sum(p.price) desc) as ranking
	from sales s
	join menu p  on s.product_id=p.product_id
	group by s.order_date
)
select order_date,total_spend from spend_by_date 
where ranking=1;

-- same ko from me select q se krenge
select order_date,total_spend from 
		(select s.order_date,sum(p.price) as total_spend
		,rank()over(order by sum(p.price) desc) as ranking
	from sales s
	join menu p  on s.product_id=p.product_id
	group by s.order_date) as spend_by_date 
where ranking=1;


-- 17. Customers with multiple orders on same day
select s.customer_id, s.order_date, count(s.product_id) as total_order
from sales s
group by s.customer_id,s.order_date
having count(s.product_id)>1;

-- 18. Visits after membership

select count(*) as total_visit
	from members m
	join sales s on m.customer_id=s.customer_id
	where s.order_date>m.join_date

select m.customer_id,m.join_date,s.order_date
	from members m
	join sales s on m.customer_id=s.customer_id
	where s.order_date>m.join_date
-- 19. Items never ordered

select p.product_id,p.product_name
from menu p 
where not exists( select 1 from sales as s
					where s.product_id=p.product_id);

-- 20. Customers who ordered but never joined
select distinct s.customer_id
	from sales s
	where not exists ( select 1 from members m
						where m.customer_id=s.customer_id);


