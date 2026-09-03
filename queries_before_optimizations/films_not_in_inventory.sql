SELECT
    f.title
FROM film AS f

LEFT JOIN inventory AS i
    ON i.film_id = f.film_id
WHERE
    i.film_id IS NULL;
