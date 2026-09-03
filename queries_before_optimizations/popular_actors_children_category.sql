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
