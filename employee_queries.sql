/*
===============================================================================
Employee Management Database
File: employee_queries.sql
Author: Nishika Roy

Description:
Interview-ready SQL queries demonstrating analytical SQL skills.

Topics:
1. Basic Retrieval
2. Filtering & Sorting
3. Joins
4. Aggregations
5. GROUP BY / HAVING
6. Subqueries
7. CTEs
8. Window Functions
9. Business Reports
===============================================================================
*/

USE employee_management;

-- ============================================================================
-- BASIC RETRIEVAL
-- ============================================================================

-- 1. View all employees
SELECT * FROM employees;

-- 2. View all departments
SELECT * FROM departments;

-- 3. Employees hired after 2020
SELECT emp_no, first_name, last_name, hire_date
FROM employees
WHERE hire_date >= '2020-01-01';

-- 4. Current employees by hire date
SELECT emp_no, first_name, last_name, hire_date
FROM employees
ORDER BY hire_date DESC;

-- ============================================================================
-- JOINS
-- ============================================================================

-- 5. Employees with their current department
SELECT
    e.emp_no,
    CONCAT(e.first_name,' ',e.last_name) AS employee_name,
    d.department_name
FROM employees e
JOIN employee_departments ed
ON e.emp_no = ed.emp_no
JOIN departments d
ON ed.dept_no = d.dept_no
WHERE ed.is_current = TRUE
ORDER BY employee_name;

-- 6. Current department managers
SELECT
    d.department_name,
    CONCAT(e.first_name,' ',e.last_name) AS manager_name
FROM department_managers dm
JOIN employees e
ON dm.emp_no = e.emp_no
JOIN departments d
ON dm.dept_no = d.dept_no
WHERE dm.is_current = TRUE;

-- 7. Employees with current salary
SELECT
    e.emp_no,
    CONCAT(e.first_name,' ',e.last_name) AS employee_name,
    s.salary
FROM employees e
JOIN salaries s
ON e.emp_no = s.emp_no
WHERE s.is_current = TRUE
ORDER BY s.salary DESC;

-- ============================================================================
-- AGGREGATIONS
-- ============================================================================

-- 8. Average salary
SELECT ROUND(AVG(salary),2) AS average_salary
FROM salaries
WHERE is_current = TRUE;

-- 9. Maximum salary
SELECT MAX(salary) AS highest_salary
FROM salaries
WHERE is_current = TRUE;

-- 10. Minimum salary
SELECT MIN(salary) AS lowest_salary
FROM salaries
WHERE is_current = TRUE;

-- 11. Employee count by department
SELECT
    d.department_name,
    COUNT(*) AS total_employees
FROM employee_departments ed
JOIN departments d
ON ed.dept_no=d.dept_no
WHERE ed.is_current=TRUE
GROUP BY d.department_name
ORDER BY total_employees DESC;

-- 12. Average salary by department
SELECT
    d.department_name,
    ROUND(AVG(s.salary),2) AS average_salary
FROM salaries s
JOIN employee_departments ed
ON s.emp_no=ed.emp_no
JOIN departments d
ON ed.dept_no=d.dept_no
WHERE s.is_current=TRUE
AND ed.is_current=TRUE
GROUP BY d.department_name
ORDER BY average_salary DESC;

-- ============================================================================
-- HAVING
-- ============================================================================

-- 13. Departments with average salary above 70000
SELECT
    d.department_name,
    AVG(s.salary) avg_salary
FROM salaries s
JOIN employee_departments ed
ON s.emp_no=ed.emp_no
JOIN departments d
ON ed.dept_no=d.dept_no
WHERE s.is_current=TRUE
AND ed.is_current=TRUE
GROUP BY d.department_name
HAVING AVG(s.salary) > 70000;

-- ============================================================================
-- SUBQUERIES
-- ============================================================================

-- 14. Employees earning above company average
SELECT
    emp_no,
    salary
FROM salaries
WHERE is_current=TRUE
AND salary >
(
SELECT AVG(salary)
FROM salaries
WHERE is_current=TRUE
);

-- 15. Highest paid employee(s)
SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    s.salary
FROM employees e
JOIN salaries s
ON e.emp_no=s.emp_no
WHERE s.salary=
(
SELECT MAX(salary)
FROM salaries
WHERE is_current=TRUE
);

-- ============================================================================
-- CTEs
-- ============================================================================

-- 16. Department salary summary
WITH dept_salary AS (
SELECT
d.department_name,
AVG(s.salary) avg_salary
FROM salaries s
JOIN employee_departments ed
ON s.emp_no=ed.emp_no
JOIN departments d
ON ed.dept_no=d.dept_no
WHERE s.is_current=TRUE
AND ed.is_current=TRUE
GROUP BY d.department_name
)
SELECT *
FROM dept_salary
ORDER BY avg_salary DESC;

-- 17. Employees above department average
WITH dept_avg AS(
SELECT
ed.dept_no,
AVG(s.salary) avg_salary
FROM employee_departments ed
JOIN salaries s
ON ed.emp_no=s.emp_no
WHERE ed.is_current=TRUE
AND s.is_current=TRUE
GROUP BY ed.dept_no
)
SELECT
e.emp_no,
CONCAT(e.first_name,' ',e.last_name) employee_name,
s.salary,
d.department_name
FROM employees e
JOIN salaries s ON e.emp_no=s.emp_no
JOIN employee_departments ed ON e.emp_no=ed.emp_no
JOIN departments d ON ed.dept_no=d.dept_no
JOIN dept_avg da ON ed.dept_no=da.dept_no
WHERE s.salary>da.avg_salary
AND s.is_current=TRUE
AND ed.is_current=TRUE;

-- ============================================================================
-- WINDOW FUNCTIONS
-- ============================================================================

-- 18. Salary Rank
SELECT
emp_no,
salary,
RANK() OVER(ORDER BY salary DESC) salary_rank
FROM salaries
WHERE is_current=TRUE;

-- 19. Dense Rank
SELECT
emp_no,
salary,
DENSE_RANK() OVER(ORDER BY salary DESC) salary_rank
FROM salaries
WHERE is_current=TRUE;

-- 20. Row Number
SELECT
emp_no,
salary,
ROW_NUMBER() OVER(ORDER BY salary DESC) row_num
FROM salaries
WHERE is_current=TRUE;

-- 21. Top 3 earners in each department
WITH ranked AS(
SELECT
d.department_name,
e.emp_no,
CONCAT(e.first_name,' ',e.last_name) employee_name,
s.salary,
ROW_NUMBER() OVER(PARTITION BY d.department_name ORDER BY s.salary DESC) rn
FROM employees e
JOIN salaries s ON e.emp_no=s.emp_no
JOIN employee_departments ed ON e.emp_no=ed.emp_no
JOIN departments d ON ed.dept_no=d.dept_no
WHERE s.is_current=TRUE
AND ed.is_current=TRUE
)
SELECT *
FROM ranked
WHERE rn<=3;

-- ============================================================================
-- BUSINESS REPORTS
-- ============================================================================

-- 22. Current payroll by department
SELECT
d.department_name,
SUM(s.salary) total_payroll
FROM salaries s
JOIN employee_departments ed ON s.emp_no=ed.emp_no
JOIN departments d ON ed.dept_no=d.dept_no
WHERE s.is_current=TRUE
AND ed.is_current=TRUE
GROUP BY d.department_name
ORDER BY total_payroll DESC;

-- 23. Employees with promotion history
SELECT emp_no,
COUNT(*) AS title_changes
FROM employee_titles
GROUP BY emp_no
HAVING COUNT(*)>1;

-- 24. Employees with department transfers
SELECT emp_no,
COUNT(*) AS department_changes
FROM employee_departments
GROUP BY emp_no
HAVING COUNT(*)>1;

-- 25. Executive HR Dashboard
SELECT
e.emp_no,
CONCAT(e.first_name,' ',e.last_name) employee_name,
d.department_name,
t.title,
s.salary
FROM employees e
JOIN employee_departments ed ON e.emp_no=ed.emp_no
JOIN departments d ON ed.dept_no=d.dept_no
JOIN employee_titles t ON e.emp_no=t.emp_no
JOIN salaries s ON e.emp_no=s.emp_no
WHERE ed.is_current=TRUE
AND t.is_current=TRUE
AND s.is_current=TRUE
ORDER BY d.department_name, s.salary DESC;
