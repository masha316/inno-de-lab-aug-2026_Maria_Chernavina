SELECT
    s.status,
    c.first_name,
    c.last_name
FROM Shippings AS s
JOIN Customers AS c
    ON c.customer_id = s.customer
ORDER BY s.shipping_id;