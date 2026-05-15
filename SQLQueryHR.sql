-- ========================================
-- HR Attrition Database Setup
-- ========================================

-- 1. Create and Select Database
CREATE DATABASE HR_Attrition;
USE HR_Attrition;

-- ----------------------------------------

-- 2. Create Raw Employees Table (Original Schema)
-- This table holds all raw columns from the CSV before any cleaning
CREATE TABLE Employees (
    Age INT,
    Attrition VARCHAR(10),
    BusinessTravel VARCHAR(50),
    DailyRate INT,
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EmployeeCount INT,
    EmployeeNumber INT,
    EnvironmentSatisfaction INT,
    Gender VARCHAR(10),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(50),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(20),
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 VARCHAR(5),
    OverTime VARCHAR(10),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

-- ----------------------------------------

-- 3. Import CSV Data into Raw Table
-- Loads data from local CSV file, skipping the header row
BULK INSERT Employees
FROM 'C:\Users\Dell\Downloads\WA_Fn-UseC_-HR-Employee-Attrition.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT * FROM Employees;

-- ----------------------------------------

-- 4. Create Working Copy for Cleaning
-- employees_clean will be used for all transformations,
-- keeping the original Employees table untouched as a backup
SELECT *
INTO employees_clean
FROM Employees;

SELECT * FROM employees_clean;

-- ----------------------------------------

-- 5. Drop Irrelevant or Redundant Columns
-- Removing columns that add no analytical value:
-- EmployeeCount and StandardHours are constant values
-- Over18 has no variation (all employees are over 18)
-- Education, JobInvolvement, JobLevel, PercentSalaryHike,
-- PerformanceRating, StockOptionLevel will be replaced by dimension tables
ALTER TABLE employees_clean
DROP COLUMN EmployeeCount, Education, Over18, StandardHours,
            JobInvolvement, JobLevel, PercentSalaryHike,
            PerformanceRating, StockOptionLevel;

-- ========================================
-- Data Modeling: Create Dimension Tables
-- ========================================

-- 6. Department Dimension Table
-- Stores unique department names with auto-generated IDs
CREATE TABLE department_dim (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(50)
);

-- 7. Job Role Dimension Table
-- Stores unique job roles with auto-generated IDs
CREATE TABLE jobrole_dim (
    JobRoleID INT IDENTITY(1,1) PRIMARY KEY,
    JobRoleName VARCHAR(100)
);

-- 8. Satisfaction Dimension Table
-- First attempt dropped due to schema correction (used IDENTITY instead of manual IDs)
DROP TABLE satisfaction_dim;

-- Final version uses manual IDs to match satisfaction score values (1-4) from source data
CREATE TABLE satisfaction_dim (
    SatisfactionID INT PRIMARY KEY,
    SatisfactionLevel VARCHAR(50)
);

-- ========================================
-- Populate Dimension Tables
-- ========================================

-- 9. Insert Distinct Departments from Source Data
INSERT INTO department_dim (DepartmentName)
SELECT DISTINCT Department
FROM employees_clean;

-- 10. Insert Distinct Job Roles from Source Data
INSERT INTO jobrole_dim (JobRoleName)
SELECT DISTINCT JobRole
FROM employees_clean;

-- 11. Insert Satisfaction Levels (Fixed Scale 1 to 4)
INSERT INTO satisfaction_dim (SatisfactionID, SatisfactionLevel)
VALUES 
(1, 'Low'),
(2, 'Medium'),
(3, 'High'),
(4, 'Very High');

-- ========================================
-- Link employees_clean to Dimension Tables
-- ========================================

-- 12. Add and Populate DepartmentID Foreign Key
ALTER TABLE employees_clean ADD DepartmentID INT;

UPDATE e
SET DepartmentID = d.DepartmentID
FROM employees_clean e
JOIN department_dim d ON e.Department = d.DepartmentName;

SELECT Department, DepartmentID FROM employees_clean;

-- ----------------------------------------

-- 13. Add and Populate JobRoleID Foreign Key
ALTER TABLE employees_clean ADD JobRoleID INT;

UPDATE e
SET JobRoleID = j.JobRoleID
FROM employees_clean e
JOIN jobrole_dim j ON e.JobRole = j.JobRoleName;

SELECT JobRole, JobRoleID FROM employees_clean;

-- ----------------------------------------

-- 14. Add and Populate SatisfactionID Foreign Key
-- Maps existing JobSatisfaction integer values directly to satisfaction_dim
ALTER TABLE employees_clean ADD SatisfactionID INT;

UPDATE employees_clean
SET SatisfactionID = JobSatisfaction;

SELECT * FROM employees_clean;

-- ----------------------------------------

-- 15. Drop Original Text Columns After Normalization
-- Department, JobRole, and JobSatisfaction replaced by their FK equivalents
ALTER TABLE employees_clean
DROP COLUMN Department, JobRole, JobSatisfaction;

-- ========================================
-- Apply Foreign Key Constraints
-- ========================================

-- 16. Enforce Referential Integrity Between employees_clean and Dimension Tables
ALTER TABLE employees_clean
ADD CONSTRAINT fk_department
FOREIGN KEY (DepartmentID) REFERENCES department_dim(DepartmentID);

ALTER TABLE employees_clean
ADD CONSTRAINT fk_jobrole
FOREIGN KEY (JobRoleID) REFERENCES jobrole_dim(JobRoleID);

ALTER TABLE employees_clean
ADD CONSTRAINT fk_satisfaction
FOREIGN KEY (SatisfactionID) REFERENCES satisfaction_dim(SatisfactionID);

-- ----------------------------------------

-- Final Check: 
SELECT * FROM employees_clean;
