use sakila;
drop table mmrsl_tab;
create table mmrsl_tab (
   fullname varchar(50)
   );
# Future Imporvements: copy the original table and add to it
# select * into actor_mmcopy from actor;
select * from mmrsl_tab; # did create work? Yes
# select * from mmrsl_tab;
# select first_name,last_name from actor;
INSERT INTO mmrsl_tab (fullname) select concat(first_name," ",last_name) from actor;
select * from mmrsl_tab;
select fullname as "Actor Name" from mmrsl_tab; # Better? rename teh column?
select * from mmrsl_tab; # this shows the orignal col is not renamed
select * from actor where first_name like '%Joe%';
select * from actor where last_name like '%GEN%';
select last_name,first_name from actor where last_name like '%LI%' order by last_name, first_name;
# NEXT: 2D
select country_id,country from country where country in ("Afghanistan","Bangladesh","China");
# NEXT: 3a...
# CREATE TABLE IF NOT EXISTS actor_copy_tab LIKE actor;
#
DROP TABLE IF EXISTS actor_copy_tab;
CREATE TABLE actor_copy_tab SELECT * FROM actor;
select * from actor_copy_tab;
alter table actor_copy_tab 
add column description blob(1024) after last_name;
select * from actor_copy_tab;
alter table actor_copy_tab drop column description;
select * from actor_copy_tab;
#
# 4a - list last names of actors and #  actors with thtat last name 
# 
select last_name, count(last_name) AS 'last_name_frequency' from actor_copy_tab
group by last_name
having 'last_name_frequency' >= 1;
#
select sum(last_name) from actor_copy_tab; # <--- this is broken???
# 
#
# UNDERSTAND WHY both of the lines below "work" but shoudl they?
SELECT last_name, COUNT(last_name) AS counts FROM actor_copy_tab GROUP BY last_name;
select last_name, count(last_name) from actor_copy_tab as count group by last_name;

#
# Next 4b -- only show if last_name count is > 1 occurence...
#
select last_name, count(last_name) from actor_copy_tab as count group by last_name having count(*) >1;
# This next one worked but I don't know whatthe (*) does in either "count" context???
SELECT last_name, COUNT(*) AS counts FROM actor_copy_tab GROUP BY last_name having count(*) >1;
# NEXT: 4c -- change groucho to harpo...
# Verufiy groucho is there...
select * from actor_copy_tab where last_name="Williams";
# He is so change it
update actor_copy_tab set first_name = "Harpo" where first_name = "Groucho";
select * from actor_copy_tab where last_name="Williams";
update actor_copy_tab set first_name = "Harpo" where first_name = "Groucho";
# The ABOVE works now that I disabled safe updates in preferences.
# There is also a way to do this inline...
# SET SQL_SAFE_UPDATES = 0;
select * from actor_copy_tab where last_name="Williams";
# THIS DID NOT WORK ALTER TABLE actor_copy_tab ADD PRIMARY KEY(id);
alter table actor_copy_tab add column ID int not null AUTO_INCREMENT PRIMARY KEY;
SELECT * FROM actor_copy_tab;
select * from actor_copy_tab where last_name="Williams";
# He is so change it
update actor_copy_tab set first_name = "Harpo" where first_name = "Groucho" AND ID = 172;
select * from actor_copy_tab where last_name="Williams";
update actor_copy_tab set first_name = "Groucho" where first_name = "Harpo" AND ID = 172;
select * from actor_copy_tab where last_name="Williams";
#
# HW #5a - 5a. You cannot locate the schema of the address table. 
# Which query would you use to re-create it?
# Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
show create table address;
#
# HW # 6a. Use JOIN to display the first and last names, 
# # as well as the address, of each staff member. 
# # Use the tables staff and address:
use sakila;
SELECT * FROM staff; 
select * from address;
#
SELECT first_name,last_name,address.address,address.district
FROM staff
INNER JOIN address
ON staff.address_id = address.address_id;
#
# 6B -- SUCCESS
# HW # 6b. Use JOIN to display the total amount rung up by each
# staff member in August of 2005. Use tables staff and payment.
#
#  FAILURE BELOW on line --> SELECT first_name,last_name, sum(payment.amount) AS "Total Rung ($)" 
#  Error Code: 1054. Unknown column 'payment.amount' in 'field list'
#  SOLUTION: Inconssitent appplication of alaises: once you define an alias, you MUST use it!!!
SELECT * FROM staff;
SELECT * FROM payment;
SELECT first_name,last_name, sum(payment.amount) AS "Total Rung ($)" 
from staff
inner join payment
on staff.staff_id = payment.staff_id
where month(payment.payment_date) = 08 and year(payment.payment_date) = 2005
group by staff.staff_id;
#
#6c. List each film and the number of actors who are listed for that film. 
#Use tables film_actor and film. Use inner join.
USE sakila;
SELECT * FROM film_actor;
SELECT * FROM film;
# join on film_id
SELECT f.title, count(fa.actor_id) as 'actors'  #(count unique actor_id occurences by film_id)
FROM film_actor as fa
inner join film as f
on f.film_id = fa.film_id
group by f.title
order by actors desc;
#
#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(inventory_id) as 'number of copies'
from film
inner join inventory
using (film_id)
where title = 'Hunchback Impossible'
group by title;
#
#6e. Using the tables payment and customer and the JOIN command, 
#list the total paid by each customer. List the customers alphabetically by last name:
# ERROR on payment.amount
select customer.first_name, customer.last_name, sum(payment.amount) as 'Total Paid'
from payment
inner join customer
on payment.customer_id = customer.customer_id
group by customer.customer_id
order by customer.last_name;
#
#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have 
#also soared in popularity. Use subqueries to display the titles of movies 
#starting with the letters K and Q whose language is English.
select title
from film
where title like 'K%'
or title like 'Q%'
and language_id in
(select language_id
from language
where name = 'English'
);
#
# 7B. Use subqueries to display all actors who appear in the film Alone Trip.
# 7B. SUCCESS
select first_name, last_name
from actor
where actor_id in 
(
  select actor_id
  from film_actor
  where film_id =
  (
    select film_id
    from film
    where title = 'Alone Trip'
  )
);
#
# 7C -- SUCCESS
#7c. You want to run an email marketing campaign in Canada, 
#for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.
SELECT first_name,last_name,email,country
FROM customer cu
INNER JOIN address ad
ON (cu.address_id = ad.address_id)
INNER JOIN city cit
ON (ad.city_id = cit.city_id)
INNER JOIN country ctr
ON (cit.country_id = ctr.country_id)
WHERE ctr.country = 'canada';
#
# 7d. SUCCESS
#7d. Sales have been lagging among young families, 
#and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.
SELECT * FROM film;
SELECT * FROM film_category;
SELECT title, c.name
FROM film f
INNER JOIN film_category fc
ON (f.film_id = fc.film_id)
INNER JOIN category c
ON (c.category_id = fc.category_id)
WHERE name = 'family';
#
#  IN PROCESS...
#7e. Display the most frequently rented movies in descending order.
SELECT * FROM film;
SELECT * FROM rental;
SELECT title, COUNT(title) as 'Rentals'
FROM film
INNER JOIN inventory
ON (film.film_id = inventory.film_id)
INNER JOIN rental
ON (inventory.inventory_id = rental.inventory_id)
GROUP BY title
ORDER BY rentals desc; # 'desc' means descending ???
#
# 7f SUCCESS
#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM store;
SELECT * FROM payment;
SELECT * FROM rental;
SELECT store.store_id, SUM(amount) AS Gross
FROM payment
INNER JOIN rental
ON (payment.rental_id = rental.rental_id)
INNER JOIN inventory
ON (inventory.inventory_id = rental.inventory_id)
INNER JOIN store
ON (store.store_id = inventory.store_id)
GROUP BY store.store_id;
#
#  7g - SUCCESS
#7g. Write a query to display for each store its store ID, city, and country.
SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;
SELECT store_id, city, country
FROM store
INNER JOIN address
ON (store.address_id = address.address_id)
INNER JOIN city
ON (city.city_id = address.address_id)
INNER JOIN country
ON (city.country_id = country.country_id);

#
#  SUCCESS
#
#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: 
#category, film_category, inventory, payment, and rental.)
select sum(amount) as 'Total Sales', c.name as 'Genre'
FROM payment p
INNER JOIN rental r
ON (p.rental_id = r.rental_id)
INNER JOIN inventory i
ON (r.inventory_id = i.inventory_id)
INNER JOIN film_category fc
ON (i.film_id = fc.film_id)
INNER JOIN category c
ON (fc.category_id = c.category_id)
GROUP BY c.name
ORDER BY SUM(amount) desc;
#
#  SUCCESS
#
#8a. In your new role as an executive, you would like to have an easy way of viewing 
#the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.
drop view if exists top_five_genres;
create view top_five_genres AS
select sum(amount) as 'Total Sales', c.name as 'Genre'
from payment p
inner join rental r
ON (p.rental_id = r.rental_id)
inner join inventory i
on (r.inventory_id = i.inventory_id)
inner join film_category fc
on (i.film_id = fc.film_id)
inner join category c
ON (fc.category_id = c.category_id)
group by c.name
order by sum(amount) desc
limit 5;
#
# SUCCESS
#8b. How would you display the view that you created in 8a?
SELECT * from top_five_genres;
#
#
#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view if exists top_five_genres;
