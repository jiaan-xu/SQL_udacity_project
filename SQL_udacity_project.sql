-- Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies
-- within each combination of film category for each corresponding rental duration category.

   SELECT name, quartile, COUNT(*)
   FROM(
     SELECT DISTINCT f.title, cat.name, NTILE(4) OVER (ORDER BY rental_duration) quartile
     FROM film f
     JOIN film_category fcat
     ON f.film_id=fcat.film_id
     JOIN category cat
     ON cat.category_id=fcat.category_id
     WHERE cat.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
   )tab1
   GROUP BY 1, 2
   ORDER BY 1, 2

-- Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month.
-- Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.

  SELECT sff.store_id, TO_CHAR(ren.rental_date, 'mm/yyyy'),
  COUNT(ren.staff_id)
  FROM rental ren
  JOIN staff sff
  ON ren.staff_id=sff.staff_id
  GROUP BY 1, 2
  ORDER BY 2;

-- We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007,
-- and what was the amount of the monthly payments. Can you write a query to capture the customer name, month and year of payment,
-- and total payment amount for each month by these top 10 paying customers?

  SELECT CONCAT(c.first_name, c.last_name) AS full_name,
          TO_CHAR(p.payment_date, 'mm/yyyy') AS paymon,
          COUNT(p.payment_date)  AS pay_count,
          SUM(p.amount) pay_tot
  FROM
  (
      SELECT c.customer_id, SUM(p.amount) tot_amount
      FROM customer c
      JOIN payment p
      ON p.customer_id=c.customer_id
      GROUP BY c.customer_id
      ORDER BY 2 DESC
      LIMIT 10
  ) tab1
  JOIN customer c
  ON tab1.customer_id=c.customer_id
  JOIN payment p
  ON tab1.customer_id=p.customer_id
  GROUP BY c.customer_id, 2
  ORDER BY 1, 2

-- Please go ahead and write a query to compare the payment amounts in each successive month. Repeat this for each of these 10 paying customers.

WITH t1 AS(
     SELECT c.customer_id, SUM(p.amount) AS tot_amount
     FROM customer c
     JOIN payment p
     ON p.customer_id=c.customer_id
     GROUP BY c.customer_id
     ORDER BY 2 DESC
     LIMIT 10),
   t2 AS(
     SELECT
     CONCAT(c.first_name,' ', c.last_name) AS full_name,
     TO_CHAR(p.payment_date, 'mm/yyyy') AS paymon,
     COUNT(p.payment_date)  AS pay_count,
     SUM(p.amount) pay_tot
     FROM t1
     JOIN customer c
     ON t1.customer_id=c.customer_id
     JOIN payment p
     ON t1.customer_id=p.customer_id
     GROUP BY c.customer_id, 2
     ORDER BY 1, 2)

SELECT *, pay_tot - LAG(pay_tot) OVER (PARTITION BY full_name ORDER BY paymon) AS pay_difference
FROM t2
