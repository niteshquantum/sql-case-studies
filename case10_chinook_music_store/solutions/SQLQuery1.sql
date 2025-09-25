--Basic SQL (SELECT, WHERE, ORDER BY, LIMIT)

--1.	List all customers.
select CustomerId,FirstName,LastName from dbo.Customer;

--2.	Show all tracks with their names and unit prices.
select TrackId,Name,UnitPrice from dbo.Track;

--3.	List all employees in the sales department.
select EmployeeId,FirstName+' '+LastName as name,Title from Employee
where Title like 'Sales%';

--4.	Retrieve all invoices from the year 2011.
select * from Invoice
where year(InvoiceDate)>2010;

--5.	Show all albums by "AC/DC".
select a.*,AlbumId,Title from Artist a join Album al on a.ArtistId=al.ArtistId
where a.Name like 'AC/DC';

--6.	List tracks with a duration longer than 5 minutes.
select TrackId,Name,Milliseconds,(Milliseconds/ cast(1000 as float))/60 as minutes from Track
where (Milliseconds/ cast(1000 as float))/60>5;

--7.	Get the list of customers from Canada.
select CustomerId,FirstName,LastName,Country from Customer
where Country like 'Canada';

--8.	List 10 most expensive tracks.
select top 10 TrackId,Name,UnitPrice from Track
order by UnitPrice desc;

--9.	List employees who report to another employee.
select   EmployeeId,FirstName,LastName from Employee
where ReportsTo is not null;

--10.	Show the invoice date and total for invoice ID 5.
select InvoiceId,InvoiceDate,Total from Invoice
where InvoiceId=5;
 

-- SQL Joins (INNER, LEFT, RIGHT, FULL)

--1.	List all customers with their respective support representative's name.
select c.CustomerId,c.FirstName+' '+c.LastName CustomerName,c.SupportRepId,r.FirstName+' '+r.LastName 'support representative name' from Customer c join Customer r on c.SupportRepId=r.CustomerId;

--2.	Get a list of all invoices along with the customer name.
select i.InvoiceId,c.FirstName+' '+c.LastName as customer_Name from Invoice i left join 
Customer c on i.CustomerId=c.CustomerId;

--3.	Show all tracks along with their album title and artist name.
select t.TrackId,t.Name as tract_Name,a.AlbumId ,a.Title,a.ArtistId ,ar.Name as artist_name
from Track t left join Album a on t.AlbumId=a.AlbumId join Artist ar on a.ArtistId=ar.ArtistId;

--4.	List all playlists and the number of tracks in each.
select p.PlaylistId,p.Name  ,count(distinct trackid ) as number_of_track from Playlist p left join PlaylistTrack pt on p.PlaylistId=pt.PlaylistId
group by p.PlaylistId,p.Name;

--5.	Get the name of all employees and their managers (self-join).

select e.EmployeeId,e.FirstName+' ' +e.LastName as Employee_name ,isnull(m.FirstName+' ' +m.LastName,'') as Manager_name
from Employee e left join Employee m on e.ReportsTo=m.EmployeeId;



--6.	Show all invoices with customer name and billing country.

select i.InvoiceId,c.FirstName as customer_name,i.BillingCountry 
from Invoice i left join Customer c on i.CustomerId=c.CustomerId;

--7.	List tracks along with their genre and media type.

select t.TrackId,t.Name track_name,g.Name genre_name ,m.Name media_name
from Track t left join Genre g on t.GenreId=g.GenreId left join MediaType m on t.MediaTypeId=m.MediaTypeId;

--8.	Get a list of albums and the number of tracks in each.

select a.AlbumId,a.Title,count(distinct t.TrackId) as number_of_track  
from Album a left join Track t on a.AlbumId=t.AlbumId
group by a.AlbumId,a.Title;

--9.	List all artists with no albums.
 select * from Album;
 select * from Artist;

 select ar.ArtistId,ar.Name from Artist ar  left join Album a on ar.ArtistId=a.ArtistId
 where a.AlbumId is null;

-- or ager if 1 artist ke multiple album or usme null album bhi then
  select ar.ArtistId,ar.Name from Artist ar  left join Album a on ar.ArtistId=a.ArtistId
  group by ar.ArtistId,ar.Name
  having count(a.AlbumId)=0;

--10.	Find all customers who have never purchased anything.

select * from Invoice

-- jisne purchase kiya unki nikal kr anti joion
select * from Customer;
select distinct CustomerId from Invoice;

select c.CustomerId,FirstName,LastName from Customer c left join 
(select distinct CustomerId from Invoice) i on c.CustomerId=i.CustomerId where i.CustomerId is null;

-- with join 

select c.CustomerId,FirstName,LastName 
from Customer c left join Invoice i on c.CustomerId=i.InvoiceId
group by c.CustomerId,FirstName,LastName 
having count (i.InvoiceId)=0;