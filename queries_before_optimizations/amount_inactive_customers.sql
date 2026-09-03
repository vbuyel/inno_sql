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
