--Advanced Joins and Set Operations
--1.	Get tracks in both 'Rock' and 'Jazz' playlists.

with common_playlist as (
select distinct PlaylistId  from Track t join Genre g on t.GenreId=g.GenreId
join PlaylistTrack p on t.TrackId=p.TrackId
where g.Name ='Rock'
intersect
select distinct PlaylistId  from Track t join Genre g on t.GenreId=g.GenreId
join PlaylistTrack p on t.TrackId=p.TrackId
where g.Name ='Jazz')
select distinct t.TrackId,t.Name from common_playlist cp join PlaylistTrack p 
on cp.PlaylistId=p.PlaylistId join Track t on p.TrackId=t.TrackId;

-- only join

with r as (
select distinct PlaylistId,g.Name  from Track t join Genre g on t.GenreId=g.GenreId
join PlaylistTrack p on t.TrackId=p.TrackId
where g.Name ='Rock'
), j as (
select distinct PlaylistId,g.Name  from Track t join Genre g on t.GenreId=g.GenreId
join PlaylistTrack p on t.TrackId=p.TrackId
where g.Name ='Jazz')
select distinct t.TrackId,t.Name from r join j on r.PlaylistId=j.PlaylistId join PlaylistTrack p 
on r.PlaylistId=p.PlaylistId join Track t on p.TrackId=t.TrackId;


--2.	List all tracks that are in 'Pop' but not in 'Rock' playlists.
with common_playlist as (
select distinct PlaylistId  from Track t join Genre g on t.GenreId=g.GenreId
join PlaylistTrack p on t.TrackId=p.TrackId
where g.Name ='Pop'
except
select distinct PlaylistId  from Track t join Genre g on t.GenreId=g.GenreId
join PlaylistTrack p on t.TrackId=p.TrackId
where g.Name ='Rock')
select distinct t.TrackId,t.Name from common_playlist cp join PlaylistTrack p 
on cp.PlaylistId=p.PlaylistId join Track t on p.TrackId=t.TrackId;

--3.	Union customers from USA and Canada.
select CustomerId,FirstName,Country from Customer
where Country='USA'
union 
select  CustomerId,FirstName,Country from Customer
where Country='Canada'

--4.	Intersect customers from Canada and those who bought ‘AC/DC’ albums.
select * from Customer
where Country='Canada'

intersect

select a.* from Customer as a
inner join Invoice as b
on a.CustomerId = b.CustomerId
inner join InvoiceLine as c
on b.InvoiceId = c.InvoiceId
inner join Track as d
on c.TrackId = d.TrackId
inner join Album as e
on d.AlbumId = e.AlbumId
inner join Artist as f
on e.ArtistId = f.ArtistId
Where f.Name = 'AC/DC';

--5.	Get artists that have albums but no tracks.

select a.ArtistId,a.Name from Artist a join Album al on a.ArtistId=al.ArtistId
left join Track t on al.AlbumId=t.TrackId
where t.TrackId is null;


--6.	Find employees who are not assigned any customers.

select e.EmployeeId,e.FirstName  from Employee e
left join Customer c on e.EmployeeId=c.SupportRepId
where c.SupportRepId is null;

--7.	List invoices where total is greater than the sum of any other invoice.

select InvoiceId,Total from Invoice
where Total>( select min(sum)  from(select Invoiceid,sum(Total) as sum from Invoice
              group by Invoiceid) t);
 
--8.	Get customers who have made more than 5 purchases using a correlated subquery.
select InvoiceId,Total from Invoice i
where Total>(select min(ii.Total) from Invoice ii
			where ii.InvoiceId<>i.InvoiceId);

-- other

select CustomerId,FirstName from Customer c 
where exists ( select 1 from Invoice i
				where i.CustomerId=c.CustomerId
				having count(i.InvoiceId)>5);

--9.	List tracks that appear in more than 2 playlists.

select TrackId,Name from Track t
where exists ( select 1 from PlaylistTrack p
				where p.TrackId=t.TrackId
				having count(distinct playlistid)>2);

--10.	Show albums where all tracks are longer than 3 minutes.
select * from Album a
where exists( select 1 from Track t where t.AlbumId=a.AlbumId having min((Milliseconds/cast(1000 as float))/60)>3);

select * from Album a
where exists( select 1 from Track t where t.AlbumId=a.AlbumId having min(Milliseconds/cast(60000 as float))>3);

--Window Functions


--1.	Rank customers by total spending.
select c.CustomerId,FirstName,RANK()over(order by sum(total) desc) as rank
from Customer c join Invoice i on c.CustomerId=i.CustomerId
group by c.CustomerId,FirstName
order by rank;

--2.	Show top 3 selling genres per country.

with t as (
select BillingCountry,GenreId ,rank()over(partition by billingcountry order by sum(Total) desc) as ranking
from Invoice i join InvoiceLine il on i.InvoiceId=il.InvoiceId join Track t on il.TrackId=t.TrackId
group by BillingCountry,GenreId
)
select t.*, g.Name from t join Genre g on t.GenreId=g.GenreId
where ranking<4;

--3.	Get running total of invoice amounts by customer.
 select c.CustomerId,FirstName,InvoiceDate,Total,
 sum(Total)over(partition by c.customerid order by invoicedate) as running_total
 from Customer c join Invoice i on c.CustomerId=i.CustomerId;

--4.	Find the invoice with the highest amount per customer.
select c.CustomerId,FirstName,InvoiceId,Total from Customer c join Invoice i on c.CustomerId=i.CustomerId
where Total=(select max(total) from Invoice ii where ii.CustomerId=i.CustomerId)
order by CustomerId;

--5.	Get the dense rank of employees by hire date.
select EmployeeId,FirstName,HireDate ,DENSE_RANK()over(order by hireDate) as denseRank from Employee;

--6.	List tracks along with their rank based on unit price within each genre.

select g.GenreId,g.Name as genre_name, Trackid,t.Name as track_name,UnitPrice,RANK()over(partition by g.genreid order by unitprice desc) as ranking
from Track t join Genre g on t.GenreId=g.GenreId;

 
--7.	Compute average invoice total by country using window functions.
select distinct avg(sum(total))over() as average_invoice_total from Invoice group by BillingCountry;

--8.	Show lag/lead of invoice totals per customer.

select c.CustomerId,FirstName,i.InvoiceId,Total,lag(total)over(partition by c.customerid order by invoicedate) as previous_total,
lead(total)over(partition by c.customerid order by invoicedate) as next_total
from Customer c join Invoice i on c.CustomerId=i.CustomerId;

--9.	List customers and their second highest invoice.

with t as (
select InvoiceId,CustomerId,Total,DENSE_RANK()over(partition by customerid order by total desc) as rn from Invoice
)
select c.CustomerId,c.FirstName,t.InvoiceId,t.Total as second_higest from t join Customer c on t.CustomerId=c.CustomerId
where rn=2;

--10.	Get the difference in invoice total from previous invoice for each customer.

select c.CustomerId,FirstName,i.InvoiceId,
Total,lag(total)over(partition by c.customerid order by invoicedate) previous,
Total-lag(total)over(partition by c.customerid order by invoicedate) as difference
from Customer c join Invoice i on c.CustomerId=i.CustomerId;