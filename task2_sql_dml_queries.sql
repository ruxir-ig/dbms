-- Task 2: SQL DML Queries (10+ Queries)
-- Demonstrating: INSERT, SELECT, UPDATE, DELETE with operators, functions, set operators
-- Joins (Inner, Outer, Self), Sub-Queries, Views

-- Setup: Create sample tables and data
CREATE TABLE Employee (
    emp_id NUMBER(6) PRIMARY KEY,
    emp_name VARCHAR2(50) NOT NULL,
    department VARCHAR2(30),
    salary NUMBER(10,2),
    hire_date DATE,
    manager_id NUMBER(6),
    city VARCHAR2(30)
);

CREATE TABLE Project (
    project_id NUMBER(4) PRIMARY KEY,
    project_name VARCHAR2(100),
    budget NUMBER(12,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR2(20)
);

CREATE TABLE Assignment (
    assignment_id NUMBER(8) PRIMARY KEY,
    emp_id NUMBER(6),
    project_id NUMBER(4),
    role VARCHAR2(30),
    hours_allocated NUMBER(5,2),
    FOREIGN KEY (emp_id) REFERENCES Employee(emp_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

-- Insert sample data
INSERT INTO Employee VALUES (101, 'Alice Johnson', 'IT', 75000, TO_DATE('2020-01-15', 'YYYY-MM-DD'), NULL, 'New York');
INSERT INTO Employee VALUES (102, 'Bob Smith', 'IT', 65000, TO_DATE('2021-03-20', 'YYYY-MM-DD'), 101, 'New York');
INSERT INTO Employee VALUES (103, 'Carol White', 'HR', 60000, TO_DATE('2019-07-10', 'YYYY-MM-DD'), NULL, 'Boston');
INSERT INTO Employee VALUES (104, 'David Brown', 'IT', 70000, TO_DATE('2021-11-05', 'YYYY-MM-DD'), 101, 'Chicago');
INSERT INTO Employee VALUES (105, 'Emma Davis', 'Finance', 80000, TO_DATE('2018-05-25', 'YYYY-MM-DD'), NULL, 'New York');
INSERT INTO Employee VALUES (106, 'Frank Wilson', 'Finance', 72000, TO_DATE('2020-09-12', 'YYYY-MM-DD'), 105, 'Boston');
INSERT INTO Employee VALUES (107, 'Grace Lee', 'HR', 55000, TO_DATE('2022-02-18', 'YYYY-MM-DD'), 103, 'Chicago');

INSERT INTO Project VALUES (1001, 'Database Migration', 500000, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2023-06-30', 'YYYY-MM-DD'), 'Completed');
INSERT INTO Project VALUES (1002, 'Mobile App Development', 750000, TO_DATE('2023-03-15', 'YYYY-MM-DD'), TO_DATE('2024-03-15', 'YYYY-MM-DD'), 'In Progress');
INSERT INTO Project VALUES (1003, 'HR System Upgrade', 300000, TO_DATE('2023-05-01', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'), 'In Progress');
INSERT INTO Project VALUES (1004, 'Financial Analytics', 600000, TO_DATE('2023-02-10', 'YYYY-MM-DD'), TO_DATE('2023-11-30', 'YYYY-MM-DD'), 'Completed');

INSERT INTO Assignment VALUES (1, 101, 1001, 'Project Lead', 200);
INSERT INTO Assignment VALUES (2, 102, 1001, 'Developer', 180);
INSERT INTO Assignment VALUES (3, 104, 1002, 'Developer', 150);
INSERT INTO Assignment VALUES (4, 101, 1002, 'Architect', 100);
INSERT INTO Assignment VALUES (5, 103, 1003, 'Project Lead', 160);
INSERT INTO Assignment VALUES (6, 107, 1003, 'Analyst', 140);
INSERT INTO Assignment VALUES (7, 105, 1004, 'Project Lead', 180);
INSERT INTO Assignment VALUES (8, 106, 1004, 'Analyst', 170);

COMMIT;

-- ============================================================================
-- QUERY 1: INNER JOIN - Get employee project assignments with details
-- ============================================================================
SELECT e.emp_id, e.emp_name, e.department,
       p.project_name, a.role, a.hours_allocated
FROM Employee e
INNER JOIN Assignment a ON e.emp_id = a.emp_id
INNER JOIN Project p ON a.project_id = p.project_id
ORDER BY e.emp_name;

-- ============================================================================
-- QUERY 2: LEFT OUTER JOIN - Show all employees and their projects (including those without projects)
-- ============================================================================
SELECT e.emp_id, e.emp_name, e.department, e.salary,
       p.project_name, a.role,
       COALESCE(a.hours_allocated, 0) as hours_allocated
FROM Employee e
LEFT OUTER JOIN Assignment a ON e.emp_id = a.emp_id
LEFT OUTER JOIN Project p ON a.project_id = p.project_id
ORDER BY e.emp_name;

-- ============================================================================
-- QUERY 3: SELF JOIN - Find employees and their managers
-- ============================================================================
SELECT e.emp_id, e.emp_name as employee_name,
       e.salary as employee_salary,
       m.emp_name as manager_name,
       m.salary as manager_salary
FROM Employee e
LEFT JOIN Employee m ON e.manager_id = m.emp_id
ORDER BY e.emp_id;

-- ============================================================================
-- QUERY 4: SUBQUERY (IN) - Find employees working on 'In Progress' projects
-- ============================================================================
SELECT emp_id, emp_name, department, salary
FROM Employee
WHERE emp_id IN (
    SELECT DISTINCT a.emp_id
    FROM Assignment a
    JOIN Project p ON a.project_id = p.project_id
    WHERE p.status = 'In Progress'
)
ORDER BY emp_name;

-- ============================================================================
-- QUERY 5: CORRELATED SUBQUERY - Employees earning more than their department average
-- ============================================================================
SELECT e.emp_id, e.emp_name, e.department, e.salary,
       (SELECT ROUND(AVG(salary), 2)
        FROM Employee
        WHERE department = e.department) as dept_avg_salary
FROM Employee e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM Employee e2
    WHERE e2.department = e.department
)
ORDER BY e.department, e.salary DESC;

-- ============================================================================
-- QUERY 6: AGGREGATE FUNCTIONS with GROUP BY and HAVING
-- ============================================================================
SELECT e.department,
       COUNT(e.emp_id) as total_employees,
       ROUND(AVG(e.salary), 2) as avg_salary,
       MIN(e.salary) as min_salary,
       MAX(e.salary) as max_salary,
       SUM(e.salary) as total_salary
FROM Employee e
GROUP BY e.department
HAVING AVG(e.salary) > 60000
ORDER BY avg_salary DESC;

-- ============================================================================
-- QUERY 7: COMPLEX SUBQUERY - Projects with budget higher than average and their team size
-- ============================================================================
SELECT p.project_id, p.project_name, p.budget, p.status,
       (SELECT COUNT(*)
        FROM Assignment a
        WHERE a.project_id = p.project_id) as team_size,
       (SELECT ROUND(AVG(budget), 2) FROM Project) as avg_project_budget
FROM Project p
WHERE p.budget > (SELECT AVG(budget) FROM Project)
ORDER BY p.budget DESC;

-- ============================================================================
-- QUERY 8: UNION - Combine high salary employees and project leads
-- ============================================================================
SELECT emp_id, emp_name, 'High Earner (>70K)' as category, salary as value
FROM Employee
WHERE salary > 70000
UNION
SELECT e.emp_id, e.emp_name, 'Project Lead' as category, a.hours_allocated as value
FROM Employee e
JOIN Assignment a ON e.emp_id = a.emp_id
WHERE a.role = 'Project Lead'
ORDER BY emp_name;

-- ============================================================================
-- QUERY 9: CREATE VIEW and Query it - Department Project Summary
-- ============================================================================
CREATE OR REPLACE VIEW vw_dept_project_summary AS
SELECT e.department,
       COUNT(DISTINCT e.emp_id) as employee_count,
       COUNT(DISTINCT a.project_id) as project_count,
       SUM(a.hours_allocated) as total_hours,
       ROUND(AVG(e.salary), 2) as avg_salary
FROM Employee e
LEFT JOIN Assignment a ON e.emp_id = a.emp_id
GROUP BY e.department;

-- Query the view
SELECT * FROM vw_dept_project_summary
ORDER BY project_count DESC;

-- ============================================================================
-- QUERY 10: NESTED SUBQUERY with EXISTS - Employees who are managers
-- ============================================================================
SELECT e.emp_id, e.emp_name, e.department, e.salary,
       (SELECT COUNT(*)
        FROM Employee
        WHERE manager_id = e.emp_id) as direct_reports
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Employee e2
    WHERE e2.manager_id = e.emp_id
)
ORDER BY direct_reports DESC;

-- ============================================================================
-- QUERY 11: CASE statement with aggregation - Employee performance category
-- ============================================================================
SELECT e.emp_name, e.department, e.salary,
       COALESCE(SUM(a.hours_allocated), 0) as total_hours,
       CASE
           WHEN COALESCE(SUM(a.hours_allocated), 0) >= 200 THEN 'High Utilization'
           WHEN COALESCE(SUM(a.hours_allocated), 0) >= 100 THEN 'Medium Utilization'
           WHEN COALESCE(SUM(a.hours_allocated), 0) > 0 THEN 'Low Utilization'
           ELSE 'Not Assigned'
       END as utilization_status
FROM Employee e
LEFT JOIN Assignment a ON e.emp_id = a.emp_id
GROUP BY e.emp_id, e.emp_name, e.department, e.salary
ORDER BY total_hours DESC;

-- ============================================================================
-- QUERY 12: DATE functions and BETWEEN operator
-- ============================================================================
SELECT emp_name, hire_date,
       ROUND(MONTHS_BETWEEN(SYSDATE, hire_date) / 12, 1) as years_employed,
       CASE
           WHEN MONTHS_BETWEEN(SYSDATE, hire_date) / 12 >= 5 THEN 'Senior'
           WHEN MONTHS_BETWEEN(SYSDATE, hire_date) / 12 >= 2 THEN 'Mid-Level'
           ELSE 'Junior'
       END as seniority_level
FROM Employee
WHERE hire_date BETWEEN TO_DATE('2019-01-01', 'YYYY-MM-DD') AND TO_DATE('2022-12-31', 'YYYY-MM-DD')
ORDER BY hire_date;

-- ============================================================================
-- QUERY 13: STRING functions with LIKE operator
-- ============================================================================
SELECT emp_id,
       UPPER(emp_name) as name_upper,
       LOWER(emp_name) as name_lower,
       LENGTH(emp_name) as name_length,
       SUBSTR(emp_name, 1, INSTR(emp_name, ' ') - 1) as first_name,
       SUBSTR(emp_name, INSTR(emp_name, ' ') + 1) as last_name
FROM Employee
WHERE emp_name LIKE '%son' OR emp_name LIKE '%Lee%'
ORDER BY emp_name;

-- ============================================================================
-- QUERY 14: UPDATE with subquery
-- ============================================================================
UPDATE Employee
SET salary = salary * 1.10
WHERE emp_id IN (
    SELECT DISTINCT a.emp_id
    FROM Assignment a
    JOIN Project p ON a.project_id = p.project_id
    WHERE p.status = 'Completed'
);

-- Verify the update
SELECT emp_name, department, salary
FROM Employee
ORDER BY salary DESC;

ROLLBACK; -- Rollback the update for demonstration

-- ============================================================================
-- QUERY 15: DELETE with subquery
-- ============================================================================
-- Delete assignments for projects that are completed
DELETE FROM Assignment
WHERE project_id IN (
    SELECT project_id
    FROM Project
    WHERE status = 'Completed'
    AND end_date < ADD_MONTHS(SYSDATE, -6)
);

ROLLBACK; -- Rollback the delete for demonstration
