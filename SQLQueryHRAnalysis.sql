-- ========================================
-- HR Attrition Analysis
-- ========================================

-- 1. Overall Attrition Rate

SELECT 
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS AttritionRate
FROM employees_clean;

-- Attrition Rate = 16.12%
-- Insight: The attrition level is relatively high and needs deeper investigation.

-- ----------------------------------------

-- 2. Attrition by Department

SELECT 
    d.DepartmentName,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount,
    ROUND(
        100.0 * SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS AttritionRate
FROM employees_clean e
JOIN department_dim d 
    ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName
ORDER BY AttritionRate DESC;

-- The Sales department shows the highest attrition rate,
-- indicating potential issues related to workload or job conditions.
-- ----------------------------------------

-- 3. Attrition by Job Role
SELECT 
    j.JobRoleName,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount,
    ROUND(
        100.0 * SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS AttritionRate
FROM employees_clean e
JOIN jobrole_dim j 
    ON e.JobRoleID = j.JobRoleID
GROUP BY j.JobRoleName
ORDER BY AttritionRate DESC;

-- Certain job roles like Sales Representatives or Laboratory Technicians
-- tend to have higher attrition rates compared to managerial roles.
              -- ----------------------------------------

--4. Attrition by gender
SELECT 
    Gender,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS AttritionRate
FROM employees_clean
GROUP BY Gender
ORDER BY AttritionRate DESC;

-- Male employees show a slightly higher attrition rate compared to females,
-- which may indicate differences in job roles, workload, or external factors.
                   -- ----------------------------------------

-- 5. Attrition vs Overtime

SELECT 
    OverTime,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS AttritionRate
FROM employees_clean
GROUP BY OverTime
ORDER BY AttritionRate DESC;

-- Employees who work overtime have a significantly higher attrition rate
-- compared to those who do not, suggesting that workload and work-life balance
-- are key drivers of employee turnover.
                         -- ----------------------------------------

-- 6.Attrition by salary ranges

SELECT 
    CASE 
        WHEN MonthlyIncome < 3000 THEN 'Low Salary'
        WHEN MonthlyIncome BETWEEN 3000 AND 7000 THEN 'Medium Salary'
        ELSE 'High Salary'
    END AS SalaryCategory,
    
    COUNT(*) AS TotalEmployees,
    
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount,
    
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS AttritionRate

FROM employees_clean
GROUP BY 
    CASE 
        WHEN MonthlyIncome < 3000 THEN 'Low Salary'
        WHEN MonthlyIncome BETWEEN 3000 AND 7000 THEN 'Medium Salary'
        ELSE 'High Salary'
    END
ORDER BY AttritionRate DESC;

-- Employees with lower salaries tend to have a higher attrition rate,
-- indicating that compensation plays a significant role in employee retention.
                -------------------------------------------
-- 7.Attrition vs years at company

SELECT 
    CASE 
        WHEN YearsAtCompany <= 2 THEN '0-2 Years'
        WHEN YearsAtCompany BETWEEN 3 AND 5 THEN '3-5 Years'
        WHEN YearsAtCompany BETWEEN 6 AND 10 THEN '6-10 Years'
        ELSE '10+ Years'
    END AS ExperienceGroup,

    COUNT(*) AS TotalEmployees,

    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount,

    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS AttritionRate

FROM employees_clean
GROUP BY 
    CASE 
        WHEN YearsAtCompany <= 2 THEN '0-2 Years'
        WHEN YearsAtCompany BETWEEN 3 AND 5 THEN '3-5 Years'
        WHEN YearsAtCompany BETWEEN 6 AND 10 THEN '6-10 Years'
        ELSE '10+ Years'
    END
ORDER BY AttritionRate DESC;

-- Employees with fewer years at the company (0-2 years) show the highest attrition rate,
-- indicating that early-stage employees are more likely to leave (maybe there is recriuting inaccuracy).


