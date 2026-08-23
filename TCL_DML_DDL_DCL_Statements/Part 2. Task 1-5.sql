Task1
CREATE TABLE Departments (
    DepartmentID   SERIAL PRIMARY KEY,
    DepartmentName VARCHAR(50) UNIQUE NOT NULL,
    Location       VARCHAR(50)
);

Task2
ALTER TABLE Employees
ADD COLUMN Email VARCHAR(100);

Task3
UPDATE Employees
SET Email = LOWER(FirstName) || '.'|| LOWER(LastName) || '@company.com';

Task4
ALTER TABLE Employees
ADD CONSTRAINT employees_email_unique UNIQUE (Email);

Task5
ALTER TABLE Departments
RENAME COLUMN Location TO OfficeLocation;