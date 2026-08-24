CREATE DATABASE brightcart_sales;

USE brightcart_sales;
CREATE TABLE sales_Transactions (
	Order_Id VARCHAR(20),
    Order_Date DATE,
    Customer_ID VARCHAR(20),
    Customer_Type VARCHAR(50),
    LEAD_ID VARCHAR(50),
    Region VARCHAR(50),
    City VARCHAR(50),
    Salesperson VARCHAR(100)
);
-- SQL 01 QUERIES
-- What is total sales?
-- What is total profit?
-- How many orders?
-- How many customers?
-- Which region has highest sales?
-- Which product sells the most?


-- SQL -02 QUERIES
-- Sales by region
-- Sales by city
-- Profit by product
-- Channel performance
-- Customer segment performance
-- New vs returning customers
-- Return analysis
-- Lead conversion
-- Lost lead reasons
USE brightcart_sales;
SHOW TABLES;

SELECT *
FROM product_master_no_bom
LIMIT 10;

SELECT COUNT(*) FROM product_master_no_bom;
SELECT
	ROUND(SUM(Realized_sales_INR),2) AS total_sales,
    ROUND(SUM(Profit_INR),2) AS total_profits,
    COUNT(DISTINCT Order_ID) AS total_orders,
    COUNT(DISTINCT Customer_ID) AS total_customers,
    SUM(Units) AS unit_sold,
    
    ROUND(
		SUM(Realized_Sales_INR)/
        COUNT(DISTINCT ORDER_ID),
        2
	) AS average_order_value,
    ROUND(
		SUM(Profit_INR)/
        NULLIF(SUM(Realized_Sales_INR),0) *100,
        2
	) AS profit_margins_pct,
    ROUND(
		SUM(CASE WHEN Return_Flag='Yes' THEN 1 ELSE 0 END )/
        COUNT(*)*100,
        2
	) AS return_rate_pct
    FROM sales_transactions_no_bom;
 
 
 SELECT *
 FROM monthly_targets_no_bom;
-- Are sales increasing or decreasing?
USE brightcart_sales;




USE brightcart_sales;

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(Order_Date, '%Y-%m') AS month,
        SUM(Realized_Sales_INR) AS sales
    FROM sales_transactions_no_bom
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
)

SELECT
    month,
    ROUND(sales, 2) AS sales,

    ROUND(
        LAG(sales) OVER (ORDER BY month),
        2
    ) AS previous_month_sales,

    ROUND(
        (
            sales - LAG(sales) OVER (ORDER BY month)
        )
        /
        NULLIF(LAG(sales) OVER (ORDER BY month), 0)
        * 100,
        2
    ) AS growth_pct

FROM monthly_sales
ORDER BY month;


-- Which region generates the most profitable sales?
USE brightcart_sales;
SELECT 
Region,
	ROUND(SUM(Realized_Sales_INR),2) AS sales,
    ROUND(SUM(Profit_INR),2) AS Profit,
    
ROUND(
	SUM(Profit_INR)/
    NULLIF(SUM(Realized_sales_INR),0)*100,
    2
    ) AS profit_margin_pct,
    COUNT(DISTINCT Order_ID) AS Orders
FROM sales_transactions_no_bom
GROUP BY Region 
ORDER BY Sales DESC;
SELECT * 
FROM sales_transactions_no_bom;

-- City Performance
SELECT 
	City,
    Region,
    ROUND(SUM(Realized_Sales_INR),2) AS Sales,
    ROUND(SUM(Profit_INR),2) AS Profit,
    COUNT(DISTINCT Order_ID) AS orders,
    COUNT(DISTINCT Customer_ID) AS customers,
    ROUND(AVG(Satisfaction_Score),2) AS avg_satisfaction
FROM sales_transactions_no_bom
GROUP BY City,Region
ORDER BY Sales DESC;
SELECT *
FROM sales_transactions_no_bom;

-- Category Performance
USE brightcart_sales;
SELECT
    Product_Category,

    ROUND(SUM(Realized_Sales_INR),2) AS sales,
    ROUND(SUM(Profit_INR),2) AS profit,

    SUM(Units) AS units,

    ROUND(
        SUM(Profit_INR) /
        NULLIF(SUM(Realized_Sales_INR),0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(CASE WHEN Return_Flag='Yes' THEN 1 ELSE 0 END) /
        COUNT(*) * 100,
        2
    ) AS return_rate_pct

FROM sales_transactions_no_bom

GROUP BY Product_Category
ORDER BY sales DESC;

-- Product performance
SELECT
    Product,
    Product_Category,

    ROUND(SUM(Realized_Sales_INR),2) AS sales,
    ROUND(SUM(Profit_INR),2) AS profit,

    SUM(Units) AS units,

    COUNT(DISTINCT Order_ID) AS orders,

    ROUND(
        SUM(CASE WHEN Return_Flag='Yes' THEN 1 ELSE 0 END) /
        COUNT(*) * 100,
        2
    ) AS return_rate_pct

FROM sales_transactions_no_bom

GROUP BY Product, Product_Category
ORDER BY sales DESC;

-- New VS returning Customers
USE brightcart_sales;
SELECT
	Customer_Type,
    COUNT(DISTINCT Customer_ID) AS Customers,
    COUNT(DISTINCT Order_ID) AS orders,
    
    ROUND(SUM(Realized_Sales_INR),2) AS sales,
    ROUND(SUM(Profit_INR),2) AS profit,
    
    ROUND(
		SUM(Realized_Sales_INR)/
        COUNT(DISTINCT Order_ID),
        2
	) AS average_order_value,
    ROUND(AVG(Satisfaction_Score),2) AS satisfaction,
    ROUND(
		SUM(CASE WHEN Return_Flag='Yes' THEN 1 ELSE 0 END)/
        COUNT(*)*100,
        2
        ) AS return_rate_pct
	FROM sales_transactions_no_bom
    GROUP BY Customer_Type;
    
-- Customer Segment
SELECT 
	Customer_Segment,
    COUNT(DISTINCT Customer_ID) AS Customers,
    ROUND(SUM(Realized_Sales_INR),2) AS sales,
    ROUND(SUM(Profit_INR),2) AS Profit,
    ROUND(
		SUM(Realized_Sales_INR)/
        COUNT(DISTINCT Order_ID),
        2
	) AS average_order_value
    
FROM sales_transactions_no_bom
GROUP BY Customer_Segment
ORDER BY sales DESC;

-- Channel Performance
USE brightcart_sales;
SELECT 
	Channel,
    
    ROUND(SUM(Realized_Sales_INR),2) AS Sales,
    ROUND(SUM(Profit_INR),2) AS profit,
    
    COUNT(DISTINCT Order_ID) AS orders,
    ROUND(AVG(Satisfaction_Score),2) AS satisfaction,
    
    ROUND(
		SUM(CASE WHEN Return_Flag='Yes' THEn 1 ELSE 0 END)/
        COUNT(*)*100,
        2
	) AS return_rate_pct
FROM sales_transactions_no_bom
GROUP BY Channel
ORDER BY sales DESC;

-- Campaign Analysis
SELECT
	Campaign,
    COUNT(DISTINCT Order_ID) AS orders,
    
    ROUND(SUM(Realized_Sales_INR),2) AS Sales,
    ROUND(SUM(Profit_INR),2)AS Profit,
    
    ROUND(AVG(Discount_Pct),2) AS avg_discount,
    
    ROUND(
		SUM(Profit_INR) /
        NULLIF(SUM(Realized_Sales_INR),0)*100,
        2
	) AS profit_margin_pct

FROM sales_transactions_no_bom
GROUP BY Campaign
ORDER BY Sales DESC;
	
-- Discount Analysis
SELECT
	CASE 
		WHEN Discount_Pct <= 5 THEN '0-5%'
        WHEN Discount_Pct <=10 THEN '6-10%'
        WHEN Discount_Pct <=15 THEN '11-15%'
		WHEN Discount_Pct <=20 THEN '16-20%'
        ELSE '21%+'
	END AS Discount_band,
    COUNT(*) AS orders,
    
    ROUND(SUM(Realized_Sales_INR),2) AS sales,
    ROUND(SUM(Profit_INR),2) AS profit,
    
    ROUND(
		SUM(Profit_INR)/
        NULLIF(SUM(Realized_sales_INR),0) *100,
        2
	) AS profit_margins_pct,
    ROUND(
		SUM(CASE WHEN Return_Flag='Yes' THEN 1 ELSE 0 END)/
        COUNT(*) *100,
        2
	) AS return_Rate_pct
FROM sales_transactions_no_bom
GROUP BY Discount_band
ORDER BY MIN(Discount_Pct);

SELECT *
FROM sales_transactions_no_bom;

-- SalesPerson Performance
USE brightcart_sales;
SELECT 
	 SalesPerson,
     Region,
     
     ROUND(SUM(Realized_Sales_INR),2) AS sales,
     ROUND(SUM(Profit_INR),2) AS profits,
     
     COUNT(DISTINCT Order_ID ) AS orders,
     COUNT(DISTINCT Customer_ID) AS customers,
     
     ROUND(AVG(Discount_Pct),2) AS avg_discount
FROM sales_transactions_no_bom
GROUP BY SalesPerson,Region
ORDER BY sales DESC;

-- SalesPerson Target Achievement 
SELECT *
FROM monthly_actual;
USE brightcart_sales;
WITH monthly_actual AS
(
    SELECT
        DATE_FORMAT(Order_Date,'%Y-%m') AS month_key,
        Salesperson,
        SUM(Realized_Sales_INR) AS actual_sales,

        COUNT(
            DISTINCT CASE
                WHEN Customer_Type='New'
                THEN Customer_ID
            END
        ) AS new_customers

    FROM sales_transactions_no_bom

    GROUP BY
        DATE_FORMAT(Order_Date,'%Y-%m'),
        Salesperson
)

SELECT

    DATE_FORMAT(t.`Month`,'%Y-%m') AS month,

    t.Salesperson,
    t.Region,

    t.Sales_Target_INR,

    ROUND(COALESCE(a.actual_sales,0),2) AS actual_sales,

    ROUND(
        COALESCE(a.actual_sales,0) /
        NULLIF(t.Sales_Target_INR,0) * 100,
        2
    ) AS target_achievement_pct,

    t.New_Customer_Target,

    COALESCE(a.new_customers,0) AS actual_new_customers

FROM monthly_targets t

LEFT JOIN monthly_actual a
    ON DATE_FORMAT(t.`Month`,'%Y-%m') = a.month_key
    AND t.Salesperson = a.Salesperson

ORDER BY month, t.Salesperson;-- IT HAS ERROR I WILL MAKE IT CORRECT TOMORROW

-- LEAD KPIs
SELECT 
	COUNT(DISTINCT Lead_ID) AS total_leads,
    
    SUM(
		CASE 
			WHEN Converted='Yes'
			THEN 1
            ELSE 0
		END
	) AS converted_leads,
    ROUND(
		SUM(CASE WHEN Converted='Yes' THEN 1 ELSE 0 END)/
        COUNT(*)*100,
        2
	) AS converted_rate_pct,
    
    ROUND(
		SUM(Lead_Cost_INR)/
        NULLIF(
			SUM(CASE WHEN Converted='Yes' THEN 1 ELSE 0 END),
            0
		),
        2
	) AS cost_per_converted_lead,
    ROUND(
		AVG(
			CASE
				WHEN Converted='Yes'
                THEN Days_to_Convert
			END
		),
        2
	) AS avg_days_to_convert
FROM leads_pipeline_no_bom;
            
    
 SELECT *
 FROM leads_pipeline_no_bom;
    
-- Best Lead Source
SELECT
	Lead_Source,
    COUNT(*) AS total_leads,
    
    SUM(
		CASE WHEN  Converted='Yes'
        THEN 1 ELSE 0 END
	) AS conerted_leads,
    
    ROUND(
		SUM(CASE WHEN Converted='Yes' THEN 1 ELSE  0 END)/
        COUNT(*) *100,
        2
	) AS converted_rate_pct,
    
	ROUND(AVG(Lead_Cost_INR),2) as avg_leads_cost,
    
    ROUND(
		SUM(Lead_Cost_INR)/
        NULLIF(
			SUM(CASE WHEN Converted='Yes' THEN 1 ELSE 0 END),
            0
            ),
            2
		) AS cost_per_Converted_lead,
        
        ROUND(
			AVG(
				CASE 
					WHEN Converted="Yes"
                    THEN 1 ELSE 0 
				END
			),
            2
		) AS avg_days_to_convert
	FROM leads_pipeline_no_bom
    GROUP BY Lead_Source
    ORDER BY converted_rate_pct;
    
-- Why Leads are lost
SELECT 
	Lost_Reason,
    COUNT(*) AS lost_leads
    
FROM leads_pipeline_no_bom
WHERE Converted='No'
GROUP BY Lost_Reason
ORDER BY lost_leads DESC;
	-- By SalesPerson
    SELECT 
		Salesperson,
        Lost_Reason,
        COUNT(*) AS lost_leads
	FROM leads_pipeline_no_bom
    WHERE Converted='No'
    GROUP BY Salesperson, Lost_Reason
    ORDER BY Salesperson, lost_leads DESC;

-- Salesperson lead conversion
SELECT 
	Salesperson,
    
    COUNT(*) AS leads,
    SUM(
		CASE WHEN Converted="Yes"
        THEN 1 ELSE 0 END
	) AS conversion,
    
    ROUND(
    SUM(CASE WHEN  Converted='Yes' THEN 1 ELSE 0 END )/
    COUNT(*) *100,
    2
    ) AS conversion_rate_pct,
    
    ROUND(AVG(Follow_ups),2) AS avg_followups
FROM leads_pipeline_no_bom
GROUP BY Salesperson
ORDER BY conversion_rate_pct;

-- Repeat customers
WITH customer_orders AS 
(
	SELECT
		Customer_ID,
        COUNT(DISTINCT Order_ID) AS orders,
        SUM(Realized_Sales_INR) AS Sales
	FROM sales_transactions_no_bom
    GROUP BY Customer_ID
)
SELECT
	COUNT(*) AS total_customers,
    SUM(
		CASE WHEN Orders>1 THEN 1 ELSE 0 END
	) AS repeat_customers,
    
    ROUND(
		SUM(CASE WHEN orders>1 THEN 1 ELSE 0 END)/
        COUNT(*) *100,
        2
	) AS repeat_customer_rate_pct
FROM customer_orders;

-- Delivery Impact
SELECT 
	CASE 
		WHEN Delivery_Days<=3 THEN 'Fast: 0-3 days'
        WHEN Delivery_Days<=7 THEN 'Normal: 4-7 days'
        ELSE 'Slow: 8+days'
	END  AS delivery_group,
    
    COUNT(*) AS orders,
    
	ROUND(
		SUM( CASE WHEN return_Flag='Yes'THEN 1 ELSE 0 END)/
        COUNT(*) *100,
      2  
	) AS return_rate_pct
FROM sales_transactions_no_bom
GROUP BY delivery_group
ORDER BY MIN(Delivery_Days);
        
        
        
	



    

























 