/*          DATABASE CREATION           */
    -- IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'US_eCommerce')
    -- CREATE DATABASE US_eCommerce
--
/*          TABLE CREATION              */
    -- SELECT * FROM eCommerce

--
/*          HIGH LEVEL ANALYSIS         */
    -- Stored Procedure
        -- CREATE OR ALTER PROCEDURE sp_Segment @segment NVARCHAR(50)
        -- AS
        -- BEGIN
        --     DECLARE @sql NVARCHAR(MAX)
        --     SET @sql = 'SELECT COALESCE(' + @segment + ' ,' + QUOTENAME('Total','''') + ' ) Segment, 
        --                 COUNT(DISTINCT Order_ID) Orders, COUNT(DISTINCT Customer_ID) Customers,
        --                 CONCAT( ' + QUOTENAME('$','''') + ', CAST(SUM(Sales) AS DEC(10,2))) Revenue,
        --                 CONCAT( ' + QUOTENAME('$','''') + ', CAST(SUM(Profit) AS DEC(10,2))) Profit 
        --                 FROM eCommerce 
        --                 GROUP BY ' + @segment +
        --                 ' WITH ROLLUP ORDER BY SUM(Profit) DESC'
        --     EXEC sp_executesql @sql
        -- END
        -- GO
    -- Running Procedures
        -- EXEC sp_Segment 'DATENAME(MM, Order_Date)'
        -- EXEC sp_Segment 'Category'
        -- EXEC sp_Segment 'Region'
        -- EXEC sp_Segment 'Segment'
        -- EXEC sp_Segment 'Ship_Mode'
        -- EXEC sp_Segment 'State'
        -- EXEC sp_Segment 'Sub_Category'

        -- SELECT * FROM eCommerce
        -- WHERE Product_Name LIKE 'Logitech%'
--
/*          COHORT ANALYSIS             */
    -- Helper Views
        -- First Transaction and Month difference
            -- CREATE OR ALTER VIEW vw_FirstTxn AS
            -- SELECT *, CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0,MIN(Order_Date) OVER(PARTITION BY Customer_ID)),0) AS DATE) [1st_Transaction], -- Find first day of month
            -- DATEDIFF(M,(MIN(Order_Date) OVER(PARTITION BY Customer_ID)),Order_Date) MonthDiff -- Month difference between first transaction and currenet transaction
            -- FROM eCommerce;
        
        -- Customer Retention 1
            -- CREATE OR ALTER VIEW vw_CxRetention AS                                                                      
            -- SELECT *
            -- FROM
            --     (SELECT DATEPART(MM,[1st_Transaction]) MonthNum, DATENAME(MM,[1st_Transaction]) TxnMonth ,
            --             MonthDiff, COUNT(DISTINCT Customer_ID) Customers
            --     FROM vw_FirstTxn
            --     GROUP BY DATEPART(MM,[1st_Transaction]), DATENAME(MM,[1st_Transaction]), MonthDiff) Q
            
            -- PIVOT(
            --     SUM(Customers)
            --     FOR MonthDiff IN ("0","1","2","3","4","5","6","7","8","9","10","11") 
            -- ) AS p    
            -- -- ORDER BY MonthNum

        -- Percentage Customer Retention
            -- CREATE OR ALTER VIEW vw_PercRetention AS  
            -- SELECT MonthNum,TxnMonth, 
            -- CAST([0]*100.0/[0] AS DEC(10,2)) [0],
            -- CAST([1]*100.0/[0] AS DEC(10,2)) [1],
            -- CAST([2]*100.0/[0] AS DEC(10,2)) [2],
            -- CAST([3]*100.0/[0] AS DEC(10,2)) [3],
            -- CAST([4]*100.0/[0] AS DEC(10,2)) [4],
            -- CAST([5]*100.0/[0] AS DEC(10,2)) [5],
            -- CAST([6]*100.0/[0] AS DEC(10,2)) [6],
            -- CAST([7]*100.0/[0] AS DEC(10,2)) [7],
            -- CAST([8]*100.0/[0] AS DEC(10,2)) [8],
            -- CAST([9]*100.0/[0] AS DEC(10,2)) [9],
            -- CAST([10]*100.0/[0] AS DEC(10,2)) [10],
            -- CAST([11]*100.0/[0] AS DEC(10,2)) [11]
            -- FROM vw_CxRetention
            -- -- ORDER BY MonthNum
        
        -- Customer Retention 2
            -- CREATE OR ALTER VIEW vw_CxRetention2 AS
            -- SELECT *
            -- FROM
            --     (SELECT DATEPART(MM,[1st_Transaction]) MonthNum,DATENAME(MM,[1st_Transaction]) TxnMonth ,
            --             (MonthDiff + DATEPART(MM,[1st_Transaction])) [Month], COUNT(DISTINCT Customer_ID) Customers
            --     FROM vw_FirstTxn
            --     GROUP BY DATEPART(MM,[1st_Transaction]), DATENAME(MM,[1st_Transaction]), MonthDiff) Q
            
            -- PIVOT(
            --     SUM(Customers)
            --     FOR Month IN ("1","2","3","4","5","6","7","8","9","10","11","12") 
            -- ) AS p    
            -- -- ORDER BY MonthNum    
    -- Cohort Analysis
        SELECT *
        FROM vw_CxRetention
        ORDER BY MonthNum

        SELECT *
        FROM vw_CxRetention2
        ORDER BY MonthNum

        SELECT *
        FROM vw_PercRetention
        ORDER BY MonthNum
--
