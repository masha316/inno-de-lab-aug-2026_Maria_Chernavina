Task1
INSERT INTO Employees (FirstName, LastName, Department, Salary)
VALUES
    ('Maria', 'Petrova', 'HR', 52000.00),
    ('Ivan', 'Sidorov', 'Sales', 48000.00);

Task 2
SELECT* 
FROM Employees;

Task3
SELECT
    FirstName,
    LastName
FROM Employees
WHERE Department = 'IT';

Task4
UPDATE Employees
SET Salary = 65000.00
WHERE FirstName = 'Alice'
  AND LastName = 'Smith';

Task5
DELETE FROM Employees
WHERE FirstName = 'Eve'
  AND LastName = 'Davis';

Task6
SELECT
    FirstName,
    LastName
FROM Employees
WHERE Department = 'IT';
