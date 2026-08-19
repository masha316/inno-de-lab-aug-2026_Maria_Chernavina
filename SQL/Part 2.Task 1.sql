SELECT
    c.first_name,
    c.last_name,
    o.item,
    o.amount
FROM Orders AS o
JOIN Customers AS c
    ON c.customer_id = o.customer_id
ORDER BY o.order_id;