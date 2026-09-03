SELECT
    a.first_name,
    a.last_name,
    COUNT(r.rental_id) AS total_rentals
FROM actor AS a

JOIN film_actor AS fa
    ON fa.actor_id = a.actor_id
JOIN inventory AS i
    ON i.film_id = fa.film_id
JOIN rental AS r
    ON r.inventory_id = i.inventory_id

GROUP BY
    a.actor_id,
    a.first_name,
    a.last_name
ORDER BY
    total_rentals DESC
LIMIT 10
