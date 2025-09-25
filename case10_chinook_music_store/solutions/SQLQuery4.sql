--CTEs and Recursive Queries
--1.	List employees and their managers using recursive CTE.
select * from Employee;
--
WITH t AS (
    -- Anchor member (top level employees, i.e., no manager)
    SELECT 
        e.EmployeeId,
        e.FirstName AS employee_name,
        e.ReportsTo AS manager_id,
        CAST('' AS VARCHAR(100)) AS manager_name
    FROM Employee e 
    WHERE e.ReportsTo IS NULL

    UNION ALL

    -- Recursive member (employees who report to someone)
    SELECT 
        e.EmployeeId,
        e.FirstName AS employee_name,
        e.ReportsTo AS manager_id,
        CAST(t.employee_name AS VARCHAR(100)) AS manager_name
    FROM Employee e 
    INNER JOIN t ON e.ReportsTo = t.EmployeeId
)
SELECT * FROM t;

-- NORMAL JOIN se

select e.EmployeeId,e.FirstName employee_name, m.EmployeeId as manager_id ,m.FirstName as manager_name 
from Employee e left join Employee m on e.ReportsTo=m.EmployeeId;
 
--2.	Use CTE to get top 3 customers by total spending.
 
with t as (
select CustomerId,sum(Total) total_spending,DENSE_RANK()over(order by sum(Total) desc) rn from  Invoice group by CustomerId
)select c.CustomerId,c.FirstName,t.total_spending from t join Customer c on t.CustomerId=c.CustomerId
where rn<4;

--3.	Create a CTE to list all invoice lines for albums by 'Metallica'.

with t as (
select i.* from Artist a join Album al on a.ArtistId=al.ArtistId
join Track t on al.AlbumId=t.AlbumId join InvoiceLine i on t.TrackId=i.TrackId
where a.Name='Metallica')
select * from t;

--4.	Use a CTE to show all tracks that appear in more than one playlist.
with t as (
select TrackId from PlaylistTrack
group by TrackId
having count(distinct PlaylistId)>1
) select tt.* from Track tt join t on tt.TrackId=t.TrackId;

-- or 

with t as (
select * from Track t 
where exists (select 1 from PlaylistTrack p
				where p.TrackId=t.TrackId
				having count(distinct PlaylistId)>1) )
				select * from t;

--5.	Recursive CTE to list employee hierarchy (if > 2 levels).
select * from Employee;

with t as (
select e.EmployeeId,LastName,ReportsTo,1 as level  from Employee e
where e.ReportsTo is null

union all

select e.EmployeeId,e.LastName,e.ReportsTo,t.level+1 from Employee e join t on e.ReportsTo=t.EmployeeId
)
select * from t where level>2;

--6.	CTE to get all albums with total track time > 30 minutes.
with t as (
select * from Album a
where exists(select 1 from Track t  where t.AlbumId=a.AlbumId having sum(t.Milliseconds/60000.0)>30))
select * from t;


--7.	Get top 5 albums by total revenue using CTE and window functions.
with t as (
select a.AlbumId,a.Title,sum(Total) as revenue ,ROW_NUMBER()over(order by sum(Total) desc) as rn from Track t join InvoiceLine il on t.TrackId=il.TrackId join Invoice i on il.InvoiceId=i.InvoiceId
join Album a on t.AlbumId=a.AlbumId
group by a.AlbumId,a.Title
)select * from t where rn<6;

--8.	Use CTE to find average track price per genre and filter only those above global average.
with t as (
select g.GenreId,g.Name,avg(UnitPrice)as average,avg(avg(UnitPrice))over() as global_avg from Genre g join Track t on g.GenreId=t.GenreId
group by g.GenreId,g.Name)
select * from t
where average>global_avg;


--9.	CTE to find customers with the longest names.
with t as (
select CustomerId,c.FirstName+' '+c.LastName as Fullname,LEN(c.FirstName+' '+c.LastName) as length,avg(LEN(c.FirstName+' '+c.LastName))over() as average from Customer c
)select * from t where length>average;


--10.	Create a CTE to rank all albums by number of tracks.
with t as(
select a.AlbumId,a.Title,count(TrackId) as number_of_track,rank()over(order by count(TrackId) desc) ranking from Album a join Track t on a.AlbumId=t.AlbumId
group by a.AlbumId,a.Title
) select * from t
order by ranking;

--Advanced Analytics

--1.	Get month-over-month revenue change.
--2.	Calculate customer lifetime value.
--3.	Get retention: how many customers returned for a second purchase?
--4.	Identify top selling track in each country.
--5.	Show invoice trends by quarter.
--6.	Count customers acquired per year.
--7.	Find churned customers (no purchases in last 12 months).
--8.	Show most played tracks per user (using playlist track if usage data is simulated).
--9.	Simulate cohort analysis by signup month.
--10.	Calculate total revenue per artist using joins and group by.
