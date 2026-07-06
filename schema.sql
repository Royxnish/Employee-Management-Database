/*
===============================================================================
Project         : Employee Management Database
Author          : Nishika Roy
Database        : employee_management

Description:
A normalized Employee Management Database designed for SQL analytics,
reporting, and dashboarding.

Skills Demonstrated:
• Database Design
• Relational Modeling
• Third Normal Form (3NF)
• Primary & Foreign Keys
• Composite Keys
• Constraints
• Indexing
• Historical Tracking
• Analytical Query Optimization

===============================================================================
*/

DROP DATABASE IF EXISTS employee_management;

CREATE DATABASE employee_management;

USE employee_management;

-- ============================================================================
-- EMPLOYEES
-- ============================================================================

CREATE TABLE employees (

    emp_id INT PRIMARY KEY,

    first_name VARCHAR(50) NOT NULL,

    last_name VARCHAR(50) NOT NULL,

    gender ENUM ('M','F') NOT NULL,

    birth_date DATE NOT NULL,

    hire_date DATE NOT NULL,

    CHECK (hire_date >= birth_date)

);

-- ============================================================================
-- DEPARTMENTS
-- ============================================================================

CREATE TABLE departments (

    dept_id CHAR(4) PRIMARY KEY,

    department_name VARCHAR(50) NOT NULL UNIQUE

);

-- ============================================================================
-- EMPLOYEE DEPARTMENT HISTORY
-- ============================================================================

CREATE TABLE employee_departments (

    emp_id INT NOT NULL,

    dept_id CHAR(4) NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE,

    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (emp_id, dept_id, start_date),

    FOREIGN KEY (emp_id)
        REFERENCES employees(emp_id)
        ON DELETE CASCADE,

    FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
        ON DELETE CASCADE,

    CHECK (
        end_date IS NULL
        OR end_date >= start_date
    )

);

-- ============================================================================
-- DEPARTMENT MANAGERS
-- ============================================================================

CREATE TABLE department_managers (

    emp_id INT NOT NULL,

    dept_id CHAR(4) NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE,

    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (emp_id, dept_id, start_date),

    FOREIGN KEY (emp_id)
        REFERENCES employees(emp_id)
        ON DELETE CASCADE,

    FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
        ON DELETE CASCADE

);

-- ============================================================================
-- EMPLOYEE SALARY HISTORY
-- ============================================================================

CREATE TABLE salaries (

    emp_id INT NOT NULL,

    salary DECIMAL(10,2) NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE,

    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (emp_id,start_date),

    FOREIGN KEY (emp_id)
        REFERENCES employees(emp_id)
        ON DELETE CASCADE,

    CHECK (salary > 0)

);

-- ============================================================================
-- EMPLOYEE TITLE HISTORY
-- ============================================================================

CREATE TABLE employee_titles (

    emp_id INT NOT NULL,

    title VARCHAR(100) NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE,

    is_current BOOLEAN NOT NULL DEFAULT TRUE,

    PRIMARY KEY (emp_id,title,start_date),

    FOREIGN KEY (emp_id)
        REFERENCES employees(emp_id)
        ON DELETE CASCADE

);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_employee_name
ON employees(last_name, first_name);

CREATE INDEX idx_department_name
ON departments(department_name);

CREATE INDEX idx_current_salary
ON salaries(is_current, salary);

CREATE INDEX idx_salary_employee
ON salaries(emp_id);

CREATE INDEX idx_current_department
ON employee_departments(is_current);

CREATE INDEX idx_department_lookup
ON employee_departments(dept_id);

CREATE INDEX idx_manager_lookup
ON department_managers(dept_id);

CREATE INDEX idx_current_title
ON employee_titles(is_current);

CREATE INDEX idx_title_lookup
ON employee_titles(title);