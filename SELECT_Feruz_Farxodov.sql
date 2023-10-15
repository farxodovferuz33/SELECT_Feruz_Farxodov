-- 1st task query
-- Which staff members made the highest revenue for each store and deserve a bonus for the year 2017?

WITH highestRevenue AS (
  SELECT
    s.store_id,
    s.staff_id,
    s.first_name,
    s.last_name,
    SUM(p.amount) AS total_revenue,
    ROW_NUMBER() OVER (PARTITION BY s.store_id ORDER BY SUM(p.amount) DESC) AS rank
  FROM
    staff s
    JOIN payment p ON s.staff_id = p.staff_id
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN store st ON i.store_id = st.store_id
  WHERE
    EXTRACT(YEAR FROM p.payment_date) = 2017
  GROUP BY
    s.store_id,
    s.staff_id
)

SELECT
  store_id,
  staff_id,
  first_name,
  last_name,
  total_revenue
FROM
  highestRevenue
WHERE
  rank = 1;



-- 2nd task query
-- Which five movies were rented more than the others, and what is the expected age of the audience for these movies?

WITH TopMovies AS (
  SELECT
    f.film_id,
    f.title AS movie_title,
    COUNT(*) AS rental_count
  FROM
    film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
  GROUP BY
    f.film_id
  ORDER BY
    rental_count DESC
  LIMIT 5
)
SELECT
  topMv.movie_title,
  CASE
    WHEN f.rating = 'G' THEN 'Child'
    WHEN f.rating = 'PG' THEN 'Family'
    WHEN f.rating = 'PG-13' THEN 'Teen'
    WHEN f.rating = 'R' THEN 'Adult'
    ELSE 'N/A'
  END AS expected_age
FROM
  TopMovies topMv
  JOIN film f ON topMv.film_id = f.film_id
ORDER BY
  topMv.rental_count DESC;



-- 3rd task query
-- Which actors/actresses didn't act for a longer period of time than the others?

WITH actorLongerPeriod AS (
    SELECT
        actor_id,
        first_name,
        last_name,
        last_update,
        LAG(last_update) OVER (PARTITION BY actor_id ORDER BY last_update) AS previous_update_date
    FROM
        actor
)
SELECT
    actor_id,
    first_name,
	last_name,
    MAX(last_update - previous_update_date) AS longest_gap
FROM
    actorLongerPeriod
GROUP BY
    actor_id, first_name, last_name
ORDER BY
    longest_gap DESC
