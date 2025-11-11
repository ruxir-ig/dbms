-- Task 2: SQL DML Queries (10+ Queries)
-- Demonstrating: INSERT, SELECT, UPDATE, DELETE with operators, functions, set operators
-- Joins (Inner, Outer, Self), Sub-Queries, Views

-- ==================== SAMPLE TABLES ====================
-- Creating sample tables for demonstration
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10,2)
);
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
-- ==================== JOINS ====================
-- INNER JOIN: Returns records with matching values in both tables
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- LEFT JOIN: Returns all records from left table and matched records
from right
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- RIGHT JOIN: Returns all records from right table and matched
records from left
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
-- FULL OUTER JOIN: Returns all records when there's a match in

either table
SELECT e.emp_name, d.dept_name
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;
-- CROSS JOIN: Returns Cartesian product of both tables
SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;
-- SELF JOIN: Join table with itself
SELECT e1.emp_name AS Employee, e2.emp_name AS Colleague
FROM employees e1, employees e2
WHERE e1.dept_id = e2.dept_id AND e1.emp_id <> e2.emp_id;
-- ==================== SUB-QUERIES ====================
-- Sub-query in WHERE clause: Find employees with salary above
average
SELECT emp_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
-- Sub-query in FROM clause: Derived table
SELECT dept_id, avg_salary
FROM (SELECT dept_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id) AS dept_avg;
-- Correlated Sub-query: Depends on outer query
SELECT e.emp_name, e.salary
FROM employees e
WHERE e.salary > (SELECT AVG(salary)
FROM employees
WHERE dept_id = e.dept_id);
-- ==================== VIEWS ====================
-- Create a view: Virtual table based on query result
CREATE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000;
-- Query the view like a regular table
SELECT * FROM high_earners;
-- Drop a view
DROP VIEW high_earners;