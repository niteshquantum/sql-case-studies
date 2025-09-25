--Aggregations and Group By
--1.	Count the number of customers in each country.
select Country,count(CustomerId) as n_of_customers from Customer
group by Country;

--2.	Total invoice amount by each customer.

select c.CustomerId,FirstName ,LastName,sum(i.Total) as invoice_amount from Customer c join Invoice i on c.CustomerId=i.CustomerId
group by c.CustomerId,FirstName ,LastName;

--3.	Average track duration per album.


select a.AlbumId,a.Title, avg(milliseconds) as avg_durations_milliseconds from Album a join Track t on a.AlbumId=t.AlbumId
group by a.AlbumId,a.Title;

--4.	Total number of tracks per genre.

select g.GenreId,g.Name ,count(TrackId) as no_of_track from Genre g left join Track t on g.GenreId=t.GenreId
group by g.GenreId,g.Name;

--5.	Revenue generated per country.

select * from Invoice;

select BillingCountry as Country,sum(Total) as revenue from Invoice group by BillingCountry order by revenue desc;

--6.	Average invoice total per billing city.

select BillingCountry as Country,avg(Total) as average_invoice from Invoice group by BillingCountry ;

--7.	Number of employees per title.
select * from Employee;

select Title,count(employeeId) as n_of_employee from Employee group by Title;

--8.	Find the top 5 selling artists.

select top 10 a.ArtistId,a.Name ,sum(i.total) selling
from Artist a join Album al on a.ArtistId=al.ArtistId
join Track t on al.AlbumId=t.AlbumId
join InvoiceLine il on t.TrackId=il.TrackId
join Invoice i on il.InvoiceId=i.InvoiceId
group by a.ArtistId,a.Name
order by selling desc;

--9.	Number of playlists containing more than 10 tracks.

select count(*) as n_of_playlist from (
select PlaylistId AS n_of_playlsit FROM PlaylistTrack
group by PlaylistId HAVING COUNT(*)>10 ) t
 
--10.	Top 3 customers by invoice total.

select top 3 c.CustomerId,c.FirstName,sum(i.Total) as invoice_total from Invoice i join Customer c on i.CustomerId=c.CustomerId 
group by c.CustomerId,c.FirstName
order by invoice_total desc;
--Subqueries (Scalar, Correlated, IN, EXISTS)

--1.	Get customers who have spent more than the average.


select c.CustomerId,c.FirstName  from Invoice i join Customer c on i.CustomerId=c.CustomerId
group by c.CustomerId,c.FirstName
having sum(Total)> (select avg(total) as avg_invoice from Invoice);

--2.	List tracks that are more expensive than the average price.
select TrackId,Name from Track
where UnitPrice>(select avg(UnitPrice) from Track);

--3.	Get albums that have more than 10 tracks.

-- with in subquery
select a.AlbumId ,a.Title 
from Album a
where a.AlbumId in ( select AlbumId from Track 
					group by AlbumId
					having count(TrackId)>10)
-- with exists
select a.AlbumId ,a.Title 
from Album a
where exists (select AlbumId from Track aa
              where aa.AlbumId=a.AlbumId
			  group by aa.AlbumId
			  having count(aa.TrackId)>10)

--with agrigate
select a.AlbumId ,a.Title 
from Album a join Track t on a.AlbumId=t.AlbumId
group by a.AlbumId ,a.Title 
having count(distinct t.TrackId)>10;


--4.	Find artists with more than 1 album.

select a.ArtistId,A.Name from Artist a join Album al on a.ArtistId=al.ArtistId
group by a.ArtistId,A.Name
HAVING COUNT(AlbumId)>1;

--5.	Get invoices that contain more than 5 line items.

select InvoiceId  from InvoiceLine
group by InvoiceId
having count(InvoiceLineId)>5;

--6.	Find tracks that do not belong to any playlist.

select t.TrackId,Name from Track t left join PlaylistTrack p on t.TrackId=p.TrackId
where p.TrackId is null;

--7.	List customers with invoices over $15.
with c1 as ( select distinct CustomerId from Invoice where Total>15 )
select c.CustomerId,c.FirstName from Customer c join c1 on c.CustomerId=c1.CustomerId;

--8.	Show customers who have purchased all genres.

select c.CustomerId,FirstName from Customer c join Invoice i on c.CustomerId=i.CustomerId
join InvoiceLine il on i.InvoiceId=il.InvoiceId
join Track t on il.TrackId=t.TrackId
group by c.CustomerId,FirstName
having count(distinct GenreId)=(SELECT COUNT(DISTINCT  GenreId ) as total_genre FROM Genre);

 
--9.	Find customers who haven’t bought from the 'Rock' genre.

with rock as (
select distinct c.CustomerId from Customer c join Invoice i on c.CustomerId=i.CustomerId
join InvoiceLine il on i.InvoiceId=il.InvoiceId
join Track t on il.TrackId=t.TrackId 
join Genre g on t.GenreId=g.GenreId
where g.Name like 'Rock')
select CustomerId,FirstName from Customer c 
where not exists  ( select 1 from rock where rock.CustomerId=c.CustomerId);

--10.	List tracks where unit price is greater than the average unit price of its media type.

select * from Track t
where UnitPrice>(select avg(UnitPrice) from Track m where m.MediaTypeId=t.MediaTypeId)



