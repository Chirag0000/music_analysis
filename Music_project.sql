-- Q1) Who is the senior most employee based on job title?
SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2) Which countries have most invoices?
SELECT COUNT(*) AS total_invoice,billing_country
FROM invoice
GROUP BY billing_country
ORDER BY total_invoice DESC;

-- Q3) What are top3 values of total invoice?
SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4) Which city has the best customers? We would like
--     to throw a promotional music festival in the city
--     we made the most money. Write a query that returns one city 
--     that has highest sum of invoice totals. Return both
--     the city name and sum of all invoice totals.

SELECT billing_city, SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;


-- Q5) Who is the best customer? The customer who has spent the most
--     money will be declared the best customer. Write a  query that 
--     returns the person who has spend the most money.

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total_money
FROM customer
INNER JOIN invoice
ON customer.customer_id=invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_money DESC
LIMIT 1;


-- Q6)  Write a query to return the email, first name, last name, & Genre
--      of all rock music listeners. Return your list ordered alphabetically 
--      by email starting with A.

SELECT DISTINCT email, first_name, last_name
FROM customer
INNER JOIN Invoice ON customer.customer_id=invoice.customer_id
INNER JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	INNER JOIN genre ON track.genre_id=Genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;



-- Q7) Let's invite  the arists who have written most rock music in our
--     dataset. Write a query that returns the artist name and total track count
--     of top 10 rock bands.

SELECT artist.name, artist.artist_id, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album2 ON album2.album_id=track.album_id
JOIN artist ON artist.artist_id=album2.artist_id
JOIN genre ON genre.genre_id=track.genre_id
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


-- Q8) Return all track names that have a song length longer than the average song
--     length. Return the Name and milliseconds for each track. Order by the song length
--     with the longest songs listed first.

SELECT track.name, track.milliseconds AS song_length
FROM track
WHERE track.milliseconds>(SELECT AVG(track.milliseconds) FROM track)
ORDER BY song_length DESC;


-- Q9) Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent.
WITH best_selling_artist AS(
	SELECT artist.artist_id , artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_spent
	FROM invoice_line
	INNER JOIN track ON invoice_line.track_id=track.track_id
	INNER JOIN album2 ON track.album_id=album2.album_id
	INNER JOIN artist ON artist.artist_id=album2.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT customer.first_name, customer.last_name, best_selling_artist.artist_name,
 SUM(invoice_line.unit_price*invoice_line.quantity) AS amount_spent
FROM invoice 
JOIN customer ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
JOIN track ON invoice_line.track_id=track.track_id
JOIN album2 ON album2.album_id=track.album_id
JOIN best_selling_artist ON best_selling_artist.artist_id=album2.artist_id
GROUP BY 1,2,3
ORDER BY 4 DESC;


-- Q10) We want to find out most popular music. Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query that
-- returns each country with top genre. For countries where maximum number of purchases is 
-- shared return all genres.

WITH popular_genre AS(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS rowno
	FROM invoice_line
	INNER JOIN invoice ON invoice.invoice_id=invoice_line.invoice_id
	INNER JOIN customer ON customer.customer_id=invoice.customer_id
	INNER JOIN track ON track.track_id=invoice_line.track_id
	INNER JOIN genre ON genre.genre_id=track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)

SELECT country, name 
FROM popular_genre
WHERE rowno=1;




-- Q11) Write a query that determines the customer that has spent most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent. For
-- countries where the top amount spent is shared, provide all customers who spent his amount.


WITH customer_with_country AS (
	SELECT customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country, SUM(total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY SUM(total) DESC ) AS rownum
	FROM invoice
	JOIN customer ON customer.customer_id=invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC
)

SELECT * FROM customer_with_country WHERE rownum=1;











