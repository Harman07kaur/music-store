/*1.	Display a list of clients that spent more than the average spent by client in the past month.*/

-- Query1: Display a list of clients that spent more than the average spent by clients in the past month.
USE music_store_online;
select cc.Customer_id, CONCAT(cc.First_name, ' ', cc.Last_name) AS Customer_fullName, ((oii.No_of_samples * aa.Price) * ((100- oo.Discount_percentage)/100) * ((100- oo.Tax_amount)/100)) 
			as money_spent
from order_items oii
JOIN orders as oo
	on oii.Orders_idOrders = oo.Order_id
JOIN customers as cc
	on cc.Customer_id = oo.Customer_idcustomer
JOIN albums as aa
	on aa.Album_id = oii.Albums_Album_id
group by cc.Customer_id, Customer_fullName, aa.Price
having money_spent > (select AVG((oi.No_of_samples * a.Price) * ((100- o.Discount_percentage)/100) * ((100- o.Tax_amount)/100)) 
						from order_items oi 
						JOIN orders as o 
							on oi.Orders_idOrders = o.Order_id
						JOIN customers as c
							on c.Customer_id = o.Customer_idcustomer
						JOIN albums as a
							on a.Album_id = oi.Albums_Album_id
						WHERE o.Order_date > ( DATE_SUB(NOW(), INTERVAL 1 MONTH) ));
                        
                        
-- Query2: The top sold products and least sold products over a week.
-- top 5 sold
USE music_store_online;
SELECT a.Name, sum(a.Album_id) AS Total_Count
FROM order_items oi 
JOIN albums AS a 
	ON oi.Albums_Album_id = a.Album_id
JOIN orders AS o
	ON oi.Orders_idOrders = o.Order_id
GROUP BY a.Album_id
ORDER BY SUM(a.Album_id) DESC
LIMIT 5;
-- least 5 sold
USE music_store_online;
SELECT a.Name, sum(a.Album_id) AS Total_Count
FROM order_items oi 
JOIN albums AS a 
	ON oi.Albums_Album_id = a.Album_id
JOIN orders AS o
	ON oi.Orders_idOrders = o.Order_id
GROUP BY a.Album_id
ORDER BY SUM(a.Album_id) ASC
LIMIT 5;



-- Query3: The maximum price of products in the same genre (for example, rock, pop, country, hip-hop). Use GROUP BY to list all the genres and their maximum price.
USE music_store_online;
SELECT MAX(a.Price) AS Maximum_price, g.Genre_name
from albums a join genre as g
ON a.Genre_Genre_id = g.Genre_id
GROUP BY g.Genre_name;

-- .create event where discount is 50% on new year day
-- event
USE music_store_online;
DROP EVENT IF EXISTS offer_new_year;
DELIMITER //
CREATE EVENT IF NOT EXISTS offer_new_year
ON SCHEDULE AT "2022-01-01"
DO BEGIN
UPDATE orders
  SET Discount_percentage = 50;
END//


-- Q4-List how many customers the system has by location (Country, Province, and City), and then sort them.

Select a.Country, a.Province, a.City, count(Customers_Customer_id) as 'Number of customers' from address a
join customers c on c.Customer_id = a.Customers_Customer_id
group by a.Country;


-- Q5.	List how many products the store has sold for a particular month. 
select sum(oi.No_of_samples) as 'Number of Sample Sold' from order_items oi
join orders o on o.Order_id = oi.Orders_idOrders
where o.Order_date between cast('2021-07-01' as date) and cast('2021-07-31' as date);


-- Q 6.	List how many distinct albums each singer has.  
select distinct Name as "Artist Name",No_of_albums from artist a 
join artist_has_albums aha on aha.Artist_idartist = a.Artist_id
group by Name asc;



/*7-List how many copies of an album are available of a particular singer.*/
select  Name,SUM(No_of_albums-No_of_samples) aS available from artist join artist_has_albums
on artist.Artist_id=artist_has_albums.Artist_idartist
join order_items 
on artist_has_albums.Albums_Album_id=order_items.Albums_Album_id
group by Name;

/*specific scenario*/
/*1-Filter albums according to instruments used in the album.*/
select Name,Instrument_Name from albums a
join instrument_has_albums ia on a.Album_id=ia.Albums_Album_id
join instrument on ia.Instrument_idInstrument=instrument.Instrument_id
group by Name,Instrument_Name;

/*2-most popular instrument.*/
/*-function*/
select Instrument_Name as popular_instrument from instrument 
where Instrument_Name IN(select MAX(Instrument_Name)  from instrument);
