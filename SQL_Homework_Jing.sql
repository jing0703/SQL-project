use sakila;
SET SQL_SAFE_UPDATES = 0;
-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name  from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT  CONCAT(first_name, ' ', last_name) AS 'Actor Name' from actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name,last_name from actor where first_name = 'Joe';
-- 2b. Find all actors whose last name contain the letters GEN:
select first_name,last_name
from actor
where last_name like '%GEN%';
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select last_name,first_name
from actor
where last_name like '%LI%';
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');
-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor ADD middle_name VARCHAR( 25 ) after first_name;
-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table actor modify middle_name BLOB;
-- 3c. Now delete the middle_name column.
ALTER TABLE actor DROP COLUMN middle_name;
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(last_name)
from actor
group by last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name,count(last_name)
from actor
group by last_name
having count(last_name) >=2;
-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
select first_name,last_name 
from actor 
where last_name = 'WILLIAMS';
update actor set first_name ='HARPO' where first_name ='GROUCHO';
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
update actor set first_name = 'GROUCHO' 
where actor.id in (
select actor.id where first_name = 'HARPO'
);

update actor set first_name ='GROUCHO' where first_name ='HARPO';
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
describe address;
SHOW CREATE TABLE address;
select *from address;
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name,s.last_name,address
from staff s
join address on s.address_id = address.address_id;
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select sum(p.amount),s.first_name,s.last_name from payment p
join staff s on p.staff_id = s.staff_id
where p.payment_date between '2005-08-01 00:00:00' and '2005-08-31 23:59:00'
group by p.staff_id;
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(fa.actor_id) from film_actor fa
join film f on fa.film_id = f.film_id
group by f.title;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, count(i.film_id) from inventory i
join film f on i.film_id = f.film_id
group by f.title
having f.title = 'Hunchback Impossible';
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
select c.first_name,c.last_name, sum(p.amount) as 'Total amount paid'  from payment p
join customer c on p.customer_id = c.customer_id
group by p.customer_id;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
from film
where (title like 'K%' or title like 'Q%') and language_id = 1;
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select 
CONCAT(a.first_name, ' ', a.last_name) AS 'Actor Name'
from actor a
join film_actor fa
on a.actor_id = fa.actor_id
join film f
on fa.film_id = f.film_id
where f.title = 'Alone Trip';
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select concat(c.first_name,' ',c.last_name) as 'Customer Name', c.email
from customer c
join customer_list cl
on c.customer_id = cl.ID
where cl.country = 'Canada';
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select f.title from film f
join film_list fl on f.title = fl.title
where fl.category = 'Family';
-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) 
FROM rental r
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film_id = f.film_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store, sum(total_sales) from
sales_by_store
group by store;
-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id,city.city,country.country from store s
join address a on s.address_id = a.address_id
join city on a.city_id = city.city_id
join country on city.country_id = country.country_id;
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount)
from category c join film_category fc on c.category_id = fc.category_id
join inventory i on fc.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
join payment p on r.rental_id = p.rental_id
group by fc.category_id
order by sum(p.amount)desc LIMIT 5;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as (
select c.name, sum(p.amount) as 'Total Revenue'
from category c join film_category fc on c.category_id = fc.category_id
join inventory i on fc.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
join payment p on r.rental_id = p.rental_id
group by fc.category_id
order by sum(p.amount)desc LIMIT 5);
select * from top_five_genres;
-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW  top_five_genres;