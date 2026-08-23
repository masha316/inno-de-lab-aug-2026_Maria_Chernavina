SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.country,
    COUNT(o.order_id) AS total_orders,
    SUM(o.amount) AS total_amount
FROM Customers AS c
JOIN Orders AS o
    ON o.customer_id = c.customer_id
WHERE EXISTS (
    SELECT 1
    FROM Shippings AS s
    WHERE s.customer = c.customer_id
      AND s.status = 'Delivered'
)
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
HAVING COUNT(o.order_id) >= 2;