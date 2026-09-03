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
