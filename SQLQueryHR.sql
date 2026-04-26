Create Database HR_Attrition;
USE HR_Attrition;

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
BULK INSERT Employees
FROM 'C:\Users\Dell\Downloads\WA_Fn-UseC_-HR-Employee-Attrition.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
select* from Employees;

SELECT *
INTO employees_clean
FROM employees;

select* from employees_clean;

ALTER TABLE employees_clean
DROP COLUMN EmployeeCount, Education, Over18, StandardHours,JobInvolvement,JobLevel,PercentSalaryHike,PerformanceRating,StockOptionLevel;

CREATE TABLE department_dim (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(50)
);

CREATE TABLE jobrole_dim (
    JobRoleID INT IDENTITY(1,1) PRIMARY KEY,
    JobRoleName VARCHAR(100)
);

CREATE TABLE satisfaction_dim (
    SatisfactionID INT IDENTITY(1,1) PRIMARY KEY,
    Satisfactiontype VARCHAR(50)
);

DROP TABLE satisfaction_dim;

CREATE TABLE satisfaction_dim (
    SatisfactionID INT PRIMARY KEY,
    SatisfactionLevel VARCHAR(50)
);



INSERT INTO department_dim (DepartmentName)
SELECT DISTINCT Department
FROM employees_clean;

INSERT INTO jobrole_dim (JobRoleName)
SELECT DISTINCT JobRole
FROM employees_clean;

INSERT INTO satisfaction_dim (SatisfactionID, SatisfactionLevel)
VALUES 
(1, 'Low'),
(2, 'Medium'),
(3, 'High'),
(4, 'Very High');

ALTER TABLE employees_clean
ADD DepartmentID INT;

UPDATE e
SET DepartmentID = d.DepartmentID
FROM employees_clean e
JOIN department_dim d
ON e.Department = d.DepartmentName;

SELECT Department, DepartmentID
FROM employees_clean;

ALTER TABLE employees_clean
ADD JobRoleID INT;

UPDATE e
SET JobRoleID = j.JobRoleID
FROM employees_clean e
JOIN jobrole_dim j
ON e.JobRole = j.JobRoleName;

SELECT JobRole, JobRoleID
FROM employees_clean;

ALTER TABLE employees_clean
ADD SatisfactionID INT;

UPDATE employees_clean
SET SatisfactionID = JobSatisfaction;

select* from employees_clean

ALTER TABLE employees_clean
DROP COLUMN Department, JobRole, JobSatisfaction;

ALTER TABLE employees_clean
ADD CONSTRAINT fk_department
FOREIGN KEY (DepartmentID)
REFERENCES department_dim(DepartmentID);

ALTER TABLE employees_clean
ADD CONSTRAINT fk_jobrole
FOREIGN KEY (JobRoleID)
REFERENCES jobrole_dim(JobRoleID);

ALTER TABLE employees_clean
ADD CONSTRAINT fk_satisfaction
FOREIGN KEY (SatisfactionID)
REFERENCES satisfaction_dim(SatisfactionID);

select* from employees_clean
