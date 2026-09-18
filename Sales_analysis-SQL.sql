create database sales_analytics;
USE sales_analytics;
CREATE TABLE sales AS
SELECT
    CAST(Row_ID AS UNSIGNED) AS Row_ID,
    Order_ID,
    STR_TO_DATE(Order_Date, '%d-%m-%Y') AS Order_Date,
    STR_TO_DATE(Ship_Date, '%d-%m-%Y') AS Ship_Date,
    Ship_Mode,
    Customer_ID,
    Customer_Name,
    Segment,
    Country,
    City,
    State,
    CAST(Postal_Code AS UNSIGNED) AS Postal_Code,
    Region,
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    CAST(Sales AS DECIMAL(12,2)) AS Sales,
    CAST(Quantity AS UNSIGNED) AS Quantity,
    CAST(Discount AS DECIMAL(5,2)) AS Discount,
    CAST(Profit AS DECIMAL(12,2)) AS Profit
FROM sales_raw;

SELECT COUNT(*) AS total_rows
FROM sales;

SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity,
    AVG(Discount) AS Average_Discount
FROM sales;

#Which product category generates the highest sales, profit, and quantity?
select Category, sum(Sales) as Total_sales, sum(Profit) as Total_profit, sum(Quantity) as Avg_Quantity
from sales
group by Category
order by  Total_sales desc;

#Which 10 individual products generated the highest total sales?
select Product_Name, sum(Sales) as Total_sales
from sales 
group by Product_Name
order by Total_sales desc
limit 10;

#Which 10 individual products generated the highest total profit?
select Product_Name, sum(Profit) as Total_profit
from sales
group by Product_Name
order by Total_profit desc
limit 10;

#Which states generate the highest total sales and total profit?
select State, sum(Sales) as Total_Sales, sum(Profit) as Total_Profit
from sales 
group by State
order by Total_Sales desc;

#Which cities have the lowest total profit?
select City, sum(Profit) as Total_Profit
from sales
group by City 
order by Total_Profit asc;

#Which 10 customers generated the highest total sales?
select Customer_Name, sum(Sales) as Total_Sales
from sales 
group by Customer_Name
order by Total_Sales desc
limit 10 ;

#How do sales change month by month?
select DATE_FORMAT(Order_Date, '%Y-%m') as Month, sum(Sales) as Total_Sales 
from sales 
group by Month 
order by Month desc;

#Which 10 products have the lowest total profit?
select Product_Name, sum(Profit) as Total_Profit
from sales
group by Product_Name
order by Total_Profit asc 
limit 10;

#Which products have high sales but low/negative profit?
select Product_Name, sum(Sales) as Total_Sales, sum(Profit) as Total_Profit  
from sales 
group by Product_Name 
order by Total_Sales desc ,Total_Profit asc;

#Products whose total profit is negative.
select Product_Name , sum(Profit) as Total_Profit 
from sales 
group by Product_Name
having Total_Profit < 0;

#Which products have high total sales but negative total profit?
select Product_Name, sum(Sales) as Total_Sales, sum(Profit) as Total_Profit
from sales 
group by Product_Name 
having Total_Profit <0
order by Total_Sales desc;

#What percentage of sales becomes profit?
select sum(Sales) as Total_Sales, sum(Profit) as Total_Profit, 
   (SUM(Profit) / SUM(Sales) ) * 100  as Profit_Margine
from sales;

#Which region generates the highest total sales and profit?
select Region, sum(Sales) as Total_Sales, sum(Profit) as Total_Profit
from sales 
group by Region 
order by Total_Sales desc, Total_Profit desc;

#Which sub-categories generate the highest sales and profit?
select Sub_Category, sum(Sales) as Total_Sales, sum(Profit) as Total_Profit
from sales 
group by Sub_Category 
order by Total_Sales desc, Total_Profit desc;

#Does giving higher discounts lead to lower profit?
select distinct(Discount), sum(Sales) as Total_Sales, sum(Profit) as Total_Profit
from sales 
group by Discount
Order by Discount desc;

#What is the average sales value of an order for each customer segment?
Select Segment, avg(Sales) as AVG_Sales
from sales 
group by Segment;

#For each Category, what is the profit margin %?
select Category, sum(Sales) , sum(Profit),
(sum(Profit)/sum(Sales))*100 as Profit_Margine
from sales
group by Category;

#How much total sales did the company generate in each year?
select sum(Sales) as Total_Sales , year(Order_Date) as Year
from sales
group by Year(Order_Date)
Order by Year;

#Show all sales transactions where the profit is negative.
select Product_Name, Sales, Profit 
from sales 
where Profit <0;

#For every transaction, classify it as "Profit" if Profit > 0 and "Loss" if Profit < 0.
select Product_Name, Profit ,
case 
     when Profit > 0 then "Profit"
     when Profit < 0 then "Loss"
     else " No Profit"
     end as Status
     from sales;
     
     #How many unique orders are there in the entire dataset?
     select count( distinct Order_ID)  as Total_Orders from sales;
     
     #How many unique customers are there in the dataset?
	 select count( distinct Customer_ID)  as Total_Customers from sales;
          
     #How many unique orders does each Segment have?
     select Segment, count(distinct Order_ID) as Total_Orders
     from sales
     group by Segment;
     
     #For each category, show its total sales and total profit.
    select A.Category,
          A.Total_Sales,
          B.Total_Profit
          from (
          select Category, Sum(Sales) as Total_Sales 
          from sales 
          group by Category
          ) as A
          join 
          (
          select Category, sum(Profit) as Total_Profit 
          from sales 
          group by Category 
          ) as B
          on A.Category = B.Category;
          
    #or 
    SELECT Category,
       SUM(Sales) AS Total_Sales,
       SUM(Profit) AS Total_Profit
FROM sales
GROUP BY Category;

#First calculate total sales by category, then show only categories where total sales are greater than ₹700,000.
with category_sales as 
(
select Category, sum(Sales) as Total_Sales
from sales 
group by Category
having Total_Sales > 700000
)
select * from category_sales;

#Calculate total sales and total profit for each category, then calculate the profit margin from those results.

with profitmargine as 
(
select sum(Sales) as Total_sales, 
sum(Profit) as Total_Profit ,
 Category 
from sales 
group by Category 
)
select Total_Sales, 
Total_Profit , 
Category, 
(Total_Profit/Total_Sales)*100
 from profitmargine ;
 
 #Show each category's total sales and the overall total sales beside it.
 WITH category_sales AS
(
    SELECT Category,
           SUM(Sales) AS Total_Sales
    FROM sales
    GROUP BY Category
),
overall_sales AS
(
    SELECT SUM(Sales) AS Overall_Sales
    FROM sales
)
SELECT Category,
       Total_Sales,
       Overall_Sales
FROM category_sales
JOIN overall_sales;


 #Show each category's total sales and the overall total sales percentage  beside it.
 with category_sales as 
 (
 select Category, sum(Sales) as Total_Sales
 from sales 
 group by Category 
 ),
 Overall_Sales as 
(
select sum(Sales) as Overall_Sales
from sales
)
select Category, (Total_Sales /Overall_Sales)*100 as Sales_Percentage
from category_sales join Overall_Sales;

#Find customers whose total sales are greater than ₹10,000.
select Customer_Name, sum(Sales) as Total_Sales 
from sales 
group by Customer_Name 
having Total_Sales > 10000;

#Show each category's total sales and total profit together.
select Category, sum(Sales) as Total_Sales, sum(Profit) as Total_Profit 
from sales 
group by Category 
order by Total_Sales desc, Total_Profit desc;

#Show each category's total sales and compare it with the average category sales.
with category_sales as 
(
select Category, sum(Sales) as Total_Sales 
from sales 
group by Category 
),
avg_sale as 
(
select avg(Total_Sales) as avg_category_sale
from category_sales
)
select A.Category,
      A.Total_Sales, 
      B.avg_category_sale
      from category_sales as A cross join avg_sale as B;

#"Show every product's sales, but only products whose sales are above the average product sales."
with product_sale as 
(
select Product_Name, sum(Sales) as Total_Sales
from sales
group by Product_Name 
),
avg_sale as 
(
select avg(Total_Sales) as avg_product_sale
from  product_sale
)
select ps.Product_Name, 
       ps.Total_Sales,
       av.avg_product_sale
       from product_sale as ps 
       cross join avg_sale as av 
       where ps.Total_Sales > av.avg_product_sale;

#Show transactions where Sales is greater than the average Sales of all transactions.
select  Product_Name, Sales from sales
where Sales >
(
select avg(Sales) from sales );	

#Find products whose individual transaction Sales are greater than the average Sales.
select  Product_Name, Sales from sales
where Sales >
(
select avg(Sales) from sales
);

#Find products whose total sales are greater than the average total sales of all products.
with product_sales as 
(
Select Product_Name, sum(Sales) as Total_Sales 
from sales
group by Product_Name 
)
select Product_Name, Total_Sales 
from product_sales 
where Total_Sales >
(select avg(Sales) as avg_sales from product_sales
);

#For each year, show total sales and the sales from the previous year.
with yearly_status as 
(
select year(Order_Date) as Year, sum(Sales) as Total_Sales 
from sales 
group by year(Order_Date)
)
select Total_Sales, 
Year, lag(Total_Sales) over (order by Year ) as lagyear from yearly_status;


#How much did sales increase or decrease compared with the previous year?
with yearly_status as 
(
select year(Order_Date) as Year, sum(Sales) as Total_Sales 
from sales 
group by year(Order_Date)
),
yearly_lag  as
(
select Total_Sales, 
Year, 
lag(Total_Sales) over (order by Year ) as Previous_Year_Sales
from yearly_status
),
yoy_growth as (
select Year, Total_Sales, Previous_Year_Sales, 
Total_Sales - Previous_Year_Sales as Sales_Difference
from yearly_lag)
select (Total_Sales - Previous_Year_Sales)/Previous_Year_Sales *100 as growth from yoy_growth;

#Give me the top 3 products in each category.
with product_sales as (
select Product_Name, Category, sum(Sales) as Total_Sales
from sales 
group by Category , Product_Name
),
ranked_products AS (
select Category, Total_Sales, Product_Name,
Row_Number() over (partition by Category order by Total_Sales Desc) as Product_Rank 
from product_sales 
)
SELECT Category,
       Product_Name,
       Total_Sales,
       Product_Rank
FROM ranked_products
WHERE Product_Rank <= 3
ORDER BY Category, Product_Rank;

#Rank sub-categories by total profit, highest to lowest,  allowing ties.
select Sub_Category, 
sum(Profit) as Total_Profit, 
rank() over (order by sum(Profit) desc) as Profit_Rank
from sales
group by Sub_Category;

#Rank sub-categories by total profit, highest to lowest, without allowing ties.
select Sub_Category, 
sum(Profit) as Total_Profit, 
dense_rank() over (order by sum(Profit) desc) as Profit_Rank
from sales
group by Sub_Category;

#For each year, show the next year's sales.
WITH yearly_sales AS
(
    SELECT YEAR(Order_Date) AS Year,
           SUM(Sales) AS Total_Sales
    FROM sales
    GROUP BY YEAR(Order_Date)
)
SELECT Year,
       Total_Sales,
       lead(Total_Sales) over (order by Year) as next_year_sale
FROM yearly_sales;

#Show each year's sales and how much sales will change in the next year.
WITH yearly_sales AS
(
    SELECT YEAR(Order_Date) AS Year,
           SUM(Sales) AS Total_Sales
    FROM sales
    GROUP BY YEAR(Order_Date)
),
Next_year as
(SELECT Year,
       Total_Sales,
       lead(Total_Sales) over (order by Year) as next_year_sale
FROM yearly_sales
)
select Total_Sales, next_year_sale, 
next_year_sale - Total_Sales as Sales_next_year
from Next_year;

#Management wants to identify the 10 customers who generated the highest total profit, along with their total sales.
select Customer_Name, sum(Sales) as Total_Sales, sum(Profit) as Total_Profit 
from sales 
group by Customer_Name 
order by Total_Profit desc, Total_Sales desc
limit 10;