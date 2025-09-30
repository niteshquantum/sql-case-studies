-- question 1: count bikes by category, only show categories with more than 2 bikes
select category, count(id) as number_of_bikes
from bike
group by category
having count(id) > 2;

-- question 2: list customer names with total membership count, even if zero, sorted by count descending
select c.name, count(m.id) as membership_count
from customer c
left join membership m on c.id = m.customer_id
group by c.name
order by membership_count desc;

-- question 3: calculate discounted rental prices for bikes based on category discounts
select id, category, price_per_hour as old_price_per_hour, price_per_day as old_price_per_day,
price_per_hour - round(price_per_hour * 
case 
when category = 'electric' then 0.10
when category = 'mountain bike' then 0.20
else 0.50
end, 2) as new_price_per_hour,
price_per_day - round(price_per_day * 
case 
when category = 'electric' then 0.20
else 0.50
end, 2) as new_price_per_day
from bike;

-- question 4: count available and rented bikes by category
select category,
count(case when status = 'available' then 1 end) as available_bikes_count,
count(case when status = 'rented' then 1 end) as rented_bikes_count
from bike
group by category;

-- question 5: calculate total rental revenue by month, year, and all-time, sorted chronologically
select 
    year(start_timestamp) as year,
    month(start_timestamp) as month,
    sum(total_paid) as revenue
from rental
group by rollup (year(start_timestamp), month(start_timestamp))
order by 
    case when year(start_timestamp) is null then 1 else 0 end,
    year(start_timestamp),
    case when month(start_timestamp) is null then 1 else 0 end,
    month(start_timestamp);

-- question 6: calculate total membership revenue by year, month, and membership type, sorted by year, month, and type
select year(m.start_date) as year, month(m.start_date) as month, mt.name as membership_type_name, sum(m.total_paid) as total_revenue
from membership m
join membership_type mt on m.membership_type_id = mt.id
group by year(m.start_date), month(m.start_date), mt.name
order by year, month, membership_type_name;

-- question 7: calculate total membership revenue for 2023 by month and membership type, with subtotals and grand totals
select mt.name as membership_type_name, month(m.start_date) as month, sum(m.total_paid) as total_revenue
from membership m
join membership_type mt on m.membership_type_id = mt.id
where year(m.start_date) = 2023
group by mt.name, month(m.start_date) with rollup;

-- question 8: segment customers by rental count into categories and count customers in each
select 
    t.rental_category as rental_count_category,
    count(t.customer_id) as number_of_customers 
from (
    select r.customer_id,count(*) as rental_count,
        case 
            when count(*) > 10 then 'more than 10' 
            when count(*) >= 5 then 'between 5 and 10'
            else 'fewer than 5'
        end as rental_category  
    from rental r 
    group by r.customer_id
) t
group by t.rental_category;