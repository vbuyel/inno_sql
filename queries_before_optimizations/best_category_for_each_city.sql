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
