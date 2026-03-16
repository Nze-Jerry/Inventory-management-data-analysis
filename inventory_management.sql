#	Inventory Management Data Analysis (MySQL)

#1. Database Setup
CREATE DATABASE inventory_management;
USE inventory_management;

#2.		Inventory Table
CREATE TABLE inventory_data (
    Product_ID VARCHAR(50),
    Product_Name VARCHAR(255),
    Category VARCHAR(100),
    Supplier_ID VARCHAR(50),
    Supplier_Name VARCHAR(255),
    Stock_Quantity INT,
    Reorder_Level INT,
    Reorder_Quantity INT,
    Unit_Price DECIMAL(10,2),
    Date_Received DATE,
    Last_Order_Date DATE,
    Expiration_Date DATE,
    Warehouse_Location VARCHAR(255),
    Sales_Volume INT,
    Inventory_Turnover_Rate DECIMAL(10,2),
    Status VARCHAR(50),
    Stock_Status VARCHAR(50),
    Inventory_Value DECIMAL(12,2),
    Reorder_Flag VARCHAR(50),
    Days_Since_Last_Order INT,
    Stock_Risk_Level VARCHAR(50));
 
 ## 	3. Data Validation and Import Checks
-- Total rows imported
SELECT COUNT(*) AS total_rows
FROM inventory_data;

-- First records
SELECT * 
FROM inventory_data
LIMIT 10;

-- Missing critical fields
SELECT *
FROM inventory_data
WHERE Product_ID IS NULL
OR Product_Name IS NULL
OR Category IS NULL;

#4. 	Core Business KPIs
-- Total products in inventory
SELECT COUNT(*) AS total_products
FROM inventory_data;

-- Total stock quantity
SELECT SUM(Stock_Quantity) AS total_stock_quantity
FROM inventory_data;

-- Total inventory value
SELECT ROUND(SUM(Inventory_Value),2) AS total_inventory_value
FROM inventory_data;

-- Products below reorder level
SELECT COUNT(*) AS products_below_reorder
FROM inventory_data
WHERE Stock_Quantity < Reorder_Level;

-- Products requiring reorder (flagged)
SELECT COUNT(*) AS reorder_products
FROM inventory_data
WHERE Reorder_Flag = 'Reorder';

-- Products at or below reorder threshold
SELECT COUNT(*) AS reorder_required_items
FROM inventory_data
WHERE Stock_Quantity <= Reorder_Level;

#5.		 Category Performance Analysis
-- Inventory value by category
SELECT 
    Category,
    ROUND(SUM(Inventory_Value),2) AS total_inventory_value
FROM inventory_data
GROUP BY Category
ORDER BY total_inventory_value DESC;

-- Sales volume by category
SELECT 
    Category,
    SUM(Sales_Volume) AS total_sales_volume
FROM inventory_data
GROUP BY Category
ORDER BY total_sales_volume DESC;

-- Average inventory turnover by category
SELECT 
    Category,
    ROUND(AVG(Inventory_Turnover_Rate),2) AS avg_turnover_rate
FROM inventory_data
GROUP BY Category
ORDER BY avg_turnover_rate DESC;

#6. Supplier Performance Analysis
-- Suppliers with the most products
SELECT 
    Supplier_Name,
    COUNT(*) AS product_count
FROM inventory_data
GROUP BY Supplier_Name
ORDER BY product_count DESC
LIMIT 10;

-- Supplier contribution to inventory value
SELECT 
    Supplier_Name,
    ROUND(SUM(Inventory_Value),2) AS supplier_inventory_value
FROM inventory_data
GROUP BY Supplier_Name
ORDER BY supplier_inventory_value DESC
LIMIT 10;

#7. Product-Level Inventory Insights
-- Top products by inventory value
SELECT 
    Product_Name,
    Category,
    SUM(Stock_Quantity) AS total_stock,
    ROUND(SUM(Inventory_Value),2) AS total_inventory_value
FROM inventory_data
GROUP BY Product_Name, Category
ORDER BY total_inventory_value DESC
LIMIT 10;

-- Critical products with largest reorder gaps
SELECT 
    Product_Name,
    Category,
    Stock_Quantity,
    Reorder_Level,
    (Reorder_Level - Stock_Quantity) AS reorder_gap,
    Supplier_Name
FROM inventory_data
WHERE Stock_Quantity < Reorder_Level
ORDER BY reorder_gap DESC
LIMIT 15;

-- Slow moving high value inventory
SELECT 
    Product_Name,
    Category,
    Sales_Volume,
    Inventory_Turnover_Rate,
    Inventory_Value
FROM inventory_data
ORDER BY Inventory_Turnover_Rate ASC, Inventory_Value DESC
LIMIT 15;

#8. Risk and Status Monitoring
-- Product status distribution
SELECT 
    Status,
    COUNT(*) AS product_count
FROM inventory_data
GROUP BY Status;

-- Inventory risk distribution
SELECT 
    Stock_Risk_Level,
    COUNT(*) AS product_count
FROM inventory_data
GROUP BY Stock_Risk_Level;

#9. Expiry Risk Analysis
SELECT 
    Product_Name,
    Category,
    Expiration_Date,
    DATEDIFF(Expiration_Date,'2025-01-01') AS days_to_expiry
FROM inventory_data
WHERE Expiration_Date BETWEEN '2025-01-01'
AND DATE_ADD('2025-01-01', INTERVAL 30 DAY)
ORDER BY Expiration_Date;

#10. Inventory Turnover Performance
SELECT 
    Category,
    ROUND(AVG(Inventory_Turnover_Rate),2) AS avg_turnover
FROM inventory_data
GROUP BY Category
ORDER BY avg_turnover DESC;

#11. Power BI Data Model View
CREATE VIEW inventory_dashboard_view AS
SELECT
    Product_ID,
    Product_Name,
    Category,
    Supplier_Name,
    Stock_Quantity,
    Reorder_Level,
    Reorder_Quantity,
    (Reorder_Level - Stock_Quantity) AS Reorder_Gap,
    Unit_Price,
    Inventory_Value,
    Sales_Volume,
    Inventory_Turnover_Rate,
    Status,
    Stock_Status,
    Reorder_Flag,
    Days_Since_Last_Order,
    Stock_Risk_Level,
    Warehouse_Location,
    Date_Received,
    Last_Order_Date,
    Expiration_Date
FROM inventory_data;