SELECT
    item,
    COUNT(*) AS count,
    ROUND(AVG(amount), 2) AS avg_amount
FROM Orders
GROUP BY item
ORDER BY item;