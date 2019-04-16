SELECT first_name, last_name
FROM actor;

SELECT concat(first_name, ' ', last_name) as ACTOR_NAME
FROM actor;

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%li%';

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor 
ADD description BLOB NOT NULL;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(actor_id) AS count
FROM actor
GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(actor_id) AS count
FROM actor
GROUP BY last_name
HAVING count >= 2;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT * FROM actor
WHERE last_name = 'WILLIAMS'
UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172;

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address, address.address2, address.postal_code
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(amount) 
FROM staff 
LEFT JOIN payment ON staff.staff_id = payment.staff_id GROUP BY staff.staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(actor_id) 
FROM film_actor INNER JOIN film ON  film_actor.film_id = film.film_id 
GROUP BY title;
#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*) 
FROM film RIGHTJOIN inventory ON film.film_id = inventory.film_id 
WHERE film.title = 'Hunchback Impossible';

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount) `Total Amount Paid` 
FROM customer RIGHT JOIN payment ON customer.customer_id = payment.customer_id 
GROUP BY customer.customer_id 
ORDER BY last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE language_id IN
	(SELECT language_id 
	FROM language
	WHERE name = 'English'
	)
	AND title LIKE 'K%' 
     OR title LIKE 'Q%';

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM actor WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id IN (SELECT film_id FROM film WHERE title = 'ALONE TRIP'));

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email FROM customer WHERE address_id IN (SELECT address_id FROM address WHERE city_id IN (SELECT city_id FROM city WHERE country_id IN (SELECT country_id FROM country WHERE country = 'CANADA')));

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM film WHERE film_id IN ( SELECT film_id FROM film_category WHERE category_id IN ( SELECT category_id FROM category WHERE NAME = 'Family'));

#7e. Display the most frequently rented movies in descending order.
SELECT f.title, count(r.rental_id) AS count
FROM film AS f
JOIN inventory AS i ON f.film_id = i.film_id
JOIN rental AS r ON i.inventory_id = r.inventory_id
GROUP BY f.title
HAVING count >= 30  -- CHANGE LIMIT TO YOUR PREFERENCE
ORDER BY count DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM(amount) 
FROM payment 
JOIN staff 
WHERE payment.staff_id = staff.staff_id 
GROUP BY store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id,city,country FROM store JOIN (SELECT address_id, city,country FROM  address a  JOIN (SELECT city, country, city_id FROM city c JOIN country n ON n.country_id = c.country_id) j  ON j.city_id = a.city_id) j2 ON j2.address_id = store.address_id;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS category, sum(p.amount) AS revenue
FROM category AS c
JOIN film_category ON c.category_id = film_category.category_id
JOIN inventory ON film_category.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment AS p ON rental.rental_id = p.rental_id
GROUP BY c.name
ORDER BY revenue DESC LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_5_genre as
SELECT NAME, SUM(amount) FROM category c JOIN (SELECT category_id, amount FROM film_category JOIN (SELECT film_id, amount FROM inventory JOIN( SELECT inventory_id, amount FROM rental r JOIN payment p ON r.rental_id = p.rental_id ) j ON j.inventory_id  = inventory.inventory_id) j2 ON j2.film_id = film_category.film_id) j3 ON j3.category_id = c.category_id GROUP BY NAME ORDER BY SUM(amount) DESC LIMIT 5;

#8b. How would you display the view that you created in 8a?
SELECT * FROM Top_5_genre;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_5_genre; 