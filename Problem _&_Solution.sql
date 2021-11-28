# QUESTION 1
# Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.

# SOLUTION
select  film_title, 
        category_name,
		Rental_count 
		from 
		(
	select (f.title) as film_title,
			(ca.name) as category_name,
	count(r.rental_date) over(partition by date_trunc('day',r.rental_date) order by r.rental_date) as rental_count from inventory i
join rental r on i.film_id=r.inventory_id
join film f on i.film_id=f.film_id
join film_category fc on i.film_id=fc.category_id
join category ca on fc.category_id = ca.category_id	
order by ca.name ) kt

# QESTION 2
# Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for.

# SOLUTION
select 
title,
name,
rental_duration,
standard_quartile,
first_quartile,
second_quartile,
third_quartile from
(select f.title as title,ca.name as name,f.rental_duration as rental_duration,
 ntile(4) over(order by f.rental_duration) as standard_quartile,
 ntile(25) over(order by f.rental_duration) as first_quartile,
 ntile(50) over(order by f.rental_duration) as second_quartile,
 ntile(75) over(order by f.rental_duration) as third_quartile
 from film f
join film_category fc on f.film_id=fc.category_id
join category ca on fc.category_id=ca.category_id) pk


# QUESTION 3
# provide a table with the family-friendly film category, each of the quartiles, 
# and the corresponding count of movies within each combination of film category 
# for each corresponding rental duration category.

#Category
#Rental length category
#Count

# SOLUTION
select   
       name,
	   standard_quartile,
	   count 
	   from
( select ca.name as name, 
 ntile(4) over(order by f.rental_duration) as standard_quartile,
count(f.rental_duration) over(partition by ca.name order by ca.name) as count
from film f
 join category ca on f.film_id=ca.category_id
join rental r on ca.category_id=r.inventory_id
order by ca.category_id, f.rental_duration) ca

# QUESTION 4
# We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for. 

# SOLUTION
SELECT 
      rental_month,
      rental_year,
      store_id,
      count_rentals
from 
(select EXTRACT(YEAR FROM r.rental_date) as rental_year ,
EXTRACT(month FROM r.rental_date) as rental_month, 
 i.store_id as store_id,
 count(r.rental_date) over(partition by i.store_id order by i.store_id ) as count_rentals
 from inventory i
join rental r on i.inventory_id=r.inventory_id
group by store_id,r.rental_date ) pet
