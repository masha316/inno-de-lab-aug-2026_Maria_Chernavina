Task 1
CREATE USER hr_user WITH PASSWORD 'Aa218091';

Task 2
GRANT SELECT ON Employees TO hr_user;

Task4
GRANT INSERT, UPDATE ON Employees TO hr_user;

Task5
INSERT INTO employees (Employeeid, FirstName, LastName, Department, Salary)
VALUES (10, 'Test', 'User', 'HR', 50000.00);

UPDATE Employees
SET Email = LOWER(FirstName) || '.' || LOWER(LastName) || '@company.com'
where employeeid = 10;