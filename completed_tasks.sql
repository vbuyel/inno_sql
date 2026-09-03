-- Solution for task 1 (from file 'film_category.sql') --
-- Optimizations:
-- 1. aggregate a narrow table (category_id only)

SELECT
    c.name,
    s.films_amount
FROM (
    SELECT
        category_id,
        COUNT(*) AS films_amount
    FROM film_category

    GROUP BY
        category_id
) s

JOIN category c
    ON c.category_id = s.category_id

ORDER BY
    c.name DESC;


-- Solution for task 2 (from file 'actor_rental.sql') --
-- Optimizations:
-- 1. scale from (films x rentals x actors) to (films x actors)

WITH film_rentals AS (
    SELECT
        i.film_id,
        COUNT(*) AS rental_count
    FROM inventory i

    JOIN rental r
        ON r.inventory_id = i.inventory_id
    GROUP BY
        i.film_id
)

SELECT
    a.first_name,
    a.last_name,
    SUM(fr.rental_count) AS total_rentals
FROM actor AS a

JOIN film_actor AS fa
    ON fa.actor_id = a.actor_id
JOIN film_rentals AS fr
    ON fr.film_id = fa.film_id

GROUP BY
    a.actor_id,
    a.first_name,
    a.last_name
ORDER BY
    total_rentals DESC
LIMIT 10;


-- Solution for task 3 (from file 'spend_on_category.sql') --
-- Optimizations:
-- 1. 

SELECT
    c.name AS category,
    SUM(p.amount) AS total_spent
FROM payment AS p

JOIN rental AS r
    ON r.rental_id = p.rental_id
JOIN inventory AS i
    ON i.inventory_id = r.inventory_id
JOIN film_category AS fc
    ON fc.film_id = i.film_id
JOIN category AS c
    ON c.category_id = fc.category_id

GROUP BY
    c.category_id,
    c.name
ORDER BY
    total_spent DESC


-- Solution for task 4 --

SELECT
    f.title
FROM film AS f

LEFT JOIN inventory AS i
    ON i.film_id = f.film_id
WHERE
    i.film_id IS NULL;


-- Solution for task 5 --

WITH actor_films AS (
    SELECT
        a.actor_id,
        a.first_name,
        a.last_name,
        fa.film_id
    FROM film_actor AS fa
	
    JOIN actor AS a
        ON fa.actor_id = a.actor_id
),
film_children AS (
    SELECT
        fc.film_id
    FROM film_category AS fc
	
    JOIN category AS c
        ON fc.category_id = c.category_id

    WHERE
        c.name = 'Children'
),
actor_counts AS (
    SELECT
        af.actor_id,
        af.first_name,
        af.last_name,
        COUNT(af.film_id) AS films_amount
    FROM actor_films AS af
	
    JOIN film_children AS fc
        ON fc.film_id = af.film_id
	
    GROUP BY
        af.actor_id,
        af.first_name,
        af.last_name
),
ranked_actors AS (
    SELECT
        first_name,
        last_name,
        films_amount,
        DENSE_RANK() OVER (ORDER BY films_amount DESC) AS actor_rank
    FROM actor_counts
)

SELECT
    first_name,
    last_name,
    films_amount
FROM ranked_actors

WHERE
    actor_rank <= 3

ORDER BY
    films_amount DESC,
    last_name,
    first_name


-- Solution for task 6 --

SELECT
	city.city,
	COUNT(*) FILTER (WHERE cus.active = 1) AS active_amount,
	COUNT(*) FILTER (WHERE cus.active = 0) AS inctive_amount
FROM address AS addr

JOIN customer AS cus
	ON cus.address_id = addr.address_id
JOIN city
	ON city.city_id = addr.city_id

GROUP BY city.city

ORDER BY inctive_amount DESC


-- Solution for task 7 --

WITH rental_hours AS (
    SELECT
        city.city,
        cat.name AS category,
        SUM(
            EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600
        ) AS hours_in_rental
    FROM rental AS r
	
    JOIN customer AS cus
        ON cus.customer_id = r.customer_id
    JOIN address AS addr
        ON addr.address_id = cus.address_id
    JOIN city
        ON city.city_id = addr.city_id
	
    JOIN inventory AS i
        ON i.inventory_id = r.inventory_id
    JOIN film AS f
        ON f.film_id = i.film_id
    JOIN film_category AS fc
        ON fc.film_id = f.film_id
    JOIN category AS cat
        ON cat.category_id = fc.category_id
    
	WHERE
        r.return_date IS NOT NULL
        AND (
            city.city ILIKE 'a%'
            OR city.city LIKE '%-%'
        )

    GROUP BY
        city.city,
        cat.name
),
ranked_categories AS (
    SELECT
        city,
        category,
        hours_in_rental,
        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY hours_in_rental DESC
        ) AS category_rank
    FROM rental_hours
)

SELECT
    city,
    category,
    hours_in_rental
FROM ranked_categories

WHERE
    category_rank = 1

ORDER BY
    city,
    category

