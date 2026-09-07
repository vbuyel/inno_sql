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
    s.films_amount DESC;


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
-- 1. shrinks payment before the inventory/category fan-out

WITH pay AS (
    SELECT
        rental_id,
        SUM(amount) AS amount
    FROM payment
    GROUP BY
        rental_id
)
SELECT
    c.name AS category,
    SUM(pay.amount) AS total_spent
FROM pay
JOIN rental AS r
    ON r.rental_id = pay.rental_id
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
LIMIT 1;


-- Solution for task 4 (from file 'films_not_in_inventory.sql') --
-- No optimizations needed, just another way to solve the task

SELECT
    f.title
FROM film f
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory i
    WHERE
        i.film_id = f.film_id
);


-- Solution for task 5 (from file 'popular_actors_children_category.sql') --
-- Optimizations:
-- 1. less expensive dense rank

SELECT
    first_name,
    last_name,
    films_amount
FROM (
    SELECT
        a.first_name,
        a.last_name,
        COUNT(*) AS films_amount,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS actor_rank
    FROM actor a
    JOIN film_actor fa
        ON fa.actor_id = a.actor_id
    JOIN film_category fc
        ON fc.film_id = fa.film_id
    JOIN category c
        ON c.category_id = fc.category_id
    WHERE
        c.name = 'Children'
    GROUP BY
        a.actor_id,
        a.first_name,
        a.last_name
) ranked
WHERE
    actor_rank <= 3
ORDER BY
    films_amount DESC,
    last_name,
    first_name;


-- Solution for task 6 (from file 'amount_inactive_customers.sql') --
-- No optimizations needed

SELECT
	city.city,
	COUNT(*) FILTER (WHERE cus.active = 1) AS active_amount,
	COUNT(*) FILTER (WHERE cus.active = 0) AS inctive_amount
FROM address AS addr
JOIN customer AS cus
	ON cus.address_id = addr.address_id
JOIN city
	ON city.city_id = addr.city_id
GROUP BY
    city.city
ORDER BY
    inctive_amount DESC;


-- Solution for task 7 (from file 'best_category_for_each_city.sql') --
-- Optimizations:
-- 1. first of all filter out cities and only then do join with cities table
-- 2. one less join (JOIN film)

WITH cities_starts_with_a AS (
    SELECT
        city_id,
        city
    FROM city
    WHERE
        city ILIKE 'a%'
),
cities_with_hyphens AS (
    SELECT
        city_id,
        city
    FROM city
    WHERE
        city LIKE '%-%'
),
rental_hours AS (
    SELECT
        a_ci.city AS city_starts_with_a,
        h_ci.city AS city_with_hyphens,
        cat.name AS category,
        SUM(EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600) AS hours_in_rental
    FROM cities_starts_with_a a_ci
    LEFT JOIN cities_with_hyphens h_ci
        ON h_ci.city_id = a_ci.city_id
    JOIN address AS addr
        ON addr.city_id = a_ci.city_id
    JOIN customer AS cus
        ON cus.address_id = addr.address_id
    JOIN rental AS r
        ON r.customer_id = cus.customer_id
    JOIN inventory AS i
        ON i.inventory_id = r.inventory_id
    JOIN film_category AS fc
        ON fc.film_id = i.film_id
    JOIN category AS cat
        ON cat.category_id = fc.category_id
    WHERE
        r.return_date IS NOT NULL
    GROUP BY
        city_starts_with_a,
        city_with_hyphens,
        cat.name
)
SELECT DISTINCT ON (city_starts_with_a, city_with_hyphens)
    city_starts_with_a,
    city_with_hyphens,
    category,
    hours_in_rental
FROM rental_hours
ORDER BY
    city_starts_with_a,
    city_with_hyphens,
    hours_in_rental DESC,
    category;
