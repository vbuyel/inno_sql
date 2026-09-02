SELECT
	category.name,
	COUNT(fc.film_id) AS films_amount
FROM film_category fc

JOIN category
	ON fc.category_id = category.category_id

GROUP BY
	category.name
ORDER BY
	category.name DESC
