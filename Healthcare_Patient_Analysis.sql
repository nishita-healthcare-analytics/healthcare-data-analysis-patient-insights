
/*
PROJECT: Healthcare Data Analysis & Patient Insights
DATABASE: Healthcare_Analytics_DB
SOURCE TABLE: dbo.Patient_Data
CLEANED VIEW: dbo.vw_Patient_Data_Clean

PURPOSE:
Data profiling, quality assessment, cleaning,
and healthcare analytics using SQL Server.

NOTE: Dataset contains 500 synthetic consultation records.
*/

USE Healthcare_Analytics_DB;
GO


/* 1. DATASET OVERVIEW */

SELECT
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients,
    COUNT(DISTINCT Department) AS Departments,
    COUNT(DISTINCT Payment_Status) AS Payment_Categories
FROM dbo.Patient_Data;
GO


/* 2. MISSING VALUE ANALYSIS */

SELECT
    SUM(CASE WHEN Patient_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Patient_ID,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Missing_Age,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(Gender)), '') IS NULL THEN 1 ELSE 0 END) AS Missing_Gender,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(Department)), '') IS NULL THEN 1 ELSE 0 END) AS Missing_Department,
    SUM(CASE WHEN Consultation_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Consultation_Date,
    SUM(CASE WHEN Consultation_Fee_INR IS NULL THEN 1 ELSE 0 END) AS Missing_Consultation_Fee,
    SUM(CASE WHEN Length_of_Stay_Days IS NULL THEN 1 ELSE 0 END) AS Missing_Length_of_Stay,
    SUM(CASE WHEN NULLIF(LTRIM(RTRIM(Payment_Status)), '') IS NULL THEN 1 ELSE 0 END) AS Missing_Payment_Status
FROM dbo.Patient_Data;
GO


/* 3. IDENTIFY REPEATED PATIENT IDs */

SELECT
    Patient_ID,
    COUNT(*) AS Number_of_Records
FROM dbo.Patient_Data
GROUP BY Patient_ID
HAVING COUNT(*) > 1;
GO


/* 4. DEPARTMENT DISTRIBUTION IN RAW DATA */

SELECT
    Department,
    COUNT(*) AS Record_Count
FROM dbo.Patient_Data
GROUP BY Department
ORDER BY Record_Count DESC;
GO


/* 5. CLEANED ANALYTICAL VIEW */

CREATE OR ALTER VIEW dbo.vw_Patient_Data_Clean AS
SELECT
    Patient_ID,
    Age,
    NULLIF(LTRIM(RTRIM(Gender)), '') AS Gender,
    UPPER(LTRIM(RTRIM(Department))) AS Department,
    Diagnosis,
    Consultation_Date,
    Consultation_Fee_INR,
    Length_of_Stay_Days,
    CASE
        WHEN LOWER(LTRIM(RTRIM(Payment_Status))) = 'paid' THEN 'Paid'
        WHEN LOWER(LTRIM(RTRIM(Payment_Status))) = 'pending' THEN 'Pending'
        WHEN LOWER(LTRIM(RTRIM(Payment_Status))) = 'partially paid' THEN 'Partially Paid'
        ELSE Payment_Status
    END AS Payment_Status
FROM dbo.Patient_Data;
GO


/* 6. VERIFY CLEANED PAYMENT CATEGORIES */

SELECT
    Payment_Status,
    COUNT(*) AS Record_Count
FROM dbo.vw_Patient_Data_Clean
GROUP BY Payment_Status
ORDER BY Record_Count DESC;
GO


/* 7. VERIFY RAW AND CLEANED RECORD COUNTS */

SELECT
    'Raw Data' AS Dataset,
    COUNT(*) AS Total_Records
FROM dbo.Patient_Data

UNION ALL

SELECT
    'Cleaned Data',
    COUNT(*)
FROM dbo.vw_Patient_Data_Clean;
GO


/* 8. DEPARTMENT-WISE CONSULTATION ANALYSIS */

SELECT
    Department,
    COUNT(*) AS Total_Records
FROM dbo.vw_Patient_Data_Clean
GROUP BY Department
ORDER BY Total_Records DESC;
GO


/* 9. PATIENT AGE ANALYSIS */

SELECT
    AVG(CAST(Age AS DECIMAL(10,2))) AS Average_Age,
    MIN(Age) AS Youngest_Age,
    MAX(Age) AS Oldest_Age
FROM dbo.vw_Patient_Data_Clean;
GO


/* 10. DEPARTMENT-WISE CONSULTATION FEE ANALYSIS */

SELECT
    Department,
    AVG(CAST(Consultation_Fee_INR AS DECIMAL(10,2))) AS Average_Fee,
    MAX(Consultation_Fee_INR) AS Highest_Fee
FROM dbo.vw_Patient_Data_Clean
GROUP BY Department
ORDER BY Average_Fee DESC;
GO


/* 11. PAYMENT STATUS DISTRIBUTION */

SELECT
    Payment_Status,
    COUNT(*) AS Total_Records,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()
        AS DECIMAL(5,2)
    ) AS Percentage
FROM dbo.vw_Patient_Data_Clean
GROUP BY Payment_Status
ORDER BY Total_Records DESC;
GO


/* 12. AGE GROUP ANALYSIS */

SELECT
    CASE
        WHEN Age IS NULL THEN 'Unknown'
        WHEN Age <= 18 THEN '0-18'
        WHEN Age <= 30 THEN '19-30'
        WHEN Age <= 45 THEN '31-45'
        WHEN Age <= 60 THEN '46-60'
        ELSE 'Above 60'
    END AS Age_Group,
    COUNT(*) AS Total_Records
FROM dbo.vw_Patient_Data_Clean
GROUP BY
    CASE
        WHEN Age IS NULL THEN 'Unknown'
        WHEN Age <= 18 THEN '0-18'
        WHEN Age <= 30 THEN '19-30'
        WHEN Age <= 45 THEN '31-45'
        WHEN Age <= 60 THEN '46-60'
        ELSE 'Above 60'
    END
ORDER BY MIN(Age);
GO


/* 13. MONTHLY CONSULTATION TRENDS */

SELECT
    DATENAME(MONTH, Consultation_Date) AS Month_Name,
    MONTH(Consultation_Date) AS Month_Number,
    COUNT(*) AS Total_Records
FROM dbo.vw_Patient_Data_Clean
WHERE Consultation_Date IS NOT NULL
GROUP BY
    MONTH(Consultation_Date),
    DATENAME(MONTH, Consultation_Date)
ORDER BY Month_Number;
GO


/* 14. LENGTH OF STAY ANALYSIS */

SELECT
    Length_of_Stay_Days,
    COUNT(*) AS Total_Records,
    CAST(AVG(Consultation_Fee_INR) AS DECIMAL(10,2)) AS Average_Fee
FROM dbo.vw_Patient_Data_Clean
GROUP BY Length_of_Stay_Days
ORDER BY Length_of_Stay_Days;
GO


/* END OF PROJECT SQL ANALYSIS */

-- PROJECT VALIDATION: KPI CHECK

SELECT
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients,
    CAST(AVG(CAST(Age AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS Average_Age
FROM dbo.vw_Patient_Data_Clean;

-- VALIDATION: PAYMENT STATUS

SELECT
    Payment_Status,
    COUNT(*) AS Total_Records
FROM dbo.vw_Patient_Data_Clean
GROUP BY Payment_Status
ORDER BY Total_Records DESC;
-- VALIDATION: DEPARTMENT-WISE RECORDS

SELECT
    Department,
    COUNT(*) AS Total_Records
FROM dbo.vw_Patient_Data_Clean
GROUP BY Department
ORDER BY Total_Records DESC;

