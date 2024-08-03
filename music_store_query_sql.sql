-- Q1. Who is the senior most employee based on the job title?

select *
from employee
order by levels desc 
limit 1 

-- Q2. Which country have the most invoices?
select 
count (*) as c, 
billing_country from invoice
group by billing_country
order by c desc 

-- Q3. What are top 3 values of top invoices?

select total from invoice
order by total desc
limit 1

-- Q4. Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that has the highest sum of 
-- invoice totals. Return both the city name & sum of all invoice totals 

select sum (total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc
limit 1


-- Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money 

-- select * from customer
select 
	customer.customer_id,
	customer.first_name,
	customer.last_name, 
	sum (invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

--Q6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A 

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id in(
	SELECT track_id FROM track
	JOIN genre on track.genre_id = genre.genre_id
	WHERE genre.name like 'Rock'
)
order by email;


-- Q7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns 
-- the Artist name and total track count of the top 10 rock bands.

SELECT artist.artist_id,artist.name,
	COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album on album.album_id = track.album_id
JOIN artist ON album.artist_id = artist.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs Desc
LIMIT 10;


-- Q8. Return all the track names that have a song length longer than the average song length. Return the Name and
-- Milliseconds for each track. Order by the song length with the longest songs listed first.

select name,milliseconds 
from track
WHERE milliseconds > (
	select AVG (milliseconds) AS avg_track_length
	from Track
)
order by milliseconds desc;


-- Q9.Find how much amount spent by each customer on artists? Write a query to return customer name, 
-- artist name and total spent.

WITH best_selling_artists AS(
	SELECT artist.artist_id AS artist_id, artist.name as artist_name,SUM (invoice_line.unit_price * invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track on track.track_id = invoice_line.track_id
	JOIN album ON album.album_id =track.album_id
	JOIN artist ON artist.artist_id =album.artist_id
	GROUP BY 1
	ORDER BY 3 Desc
	LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
	SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i 
JOIN customer c on c.customer_id = i.customer_id
JOIN invoice_line il on il.invoice_id = i.invoice_id
JOIN track t on t.track_id = il.track_id
JOIN album alb on alb. album_id = t.album_id
JOIN best_selling_artists bsa on bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 Desc


-- Q10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the
-- genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres


WITH popular_genre AS 
(
	SELECT COUNT (invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC) AS RowNo
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track on track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC 
)
SELECT * FROM popular_genre WHERE RowNo <= 1


-- Q11.Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;




