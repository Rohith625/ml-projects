--Data Analysis using sales_table.Dataset uploaded as csv.
--selecting all data
select * from `Retail_sales.Sales_table`

--Amount collected by product category
select Product_Category,sum(Total_Amount) as Amount from `Retail_sales.Sales_table`
group by Product_Category
order by sum(Total_Amount) desc

--Amount collected by Month Name
SELECT FORMAT_DATETIME("%B", DATETIME(Date)) as month_name,sum(Total_Amount) as Amount
FROM `Retail_sales.Sales_table`
group by month_name
order by Amount desc

--Amount by Gender
select Gender,sum(Total_Amount) as Amount from `Retail_sales.Sales_table`
GROUP BY Gender
order by Amount desc

--Amount by weekname
SELECT FORMAT_DATE('%a', Date) AS weekday_name,sum(Total_Amount) as Amount
FROM `my-first-trial-project-403511.Retail_sales.Sales_table`
group by weekday_name
order by Amount desc

--Amount by age group
with cte as
(select *,case when Age >=15 and Age<25 then "Adolescene"
when Age>=25 and age<45 then "Adult"
else "old age" END as Age_Group
from `Retail_sales.Sales_table`)
select Age_Group,sum(Total_Amount) as Amount
from cte
group by Age_Group
order by Amount desc

--Amount and Quanity bought on weekends
with cte as
(select *,FORMAT_DATE('%a', Date) AS weekday_name from `Retail_sales.Sales_table`)
select cte.weekday_name,sum(Total_Amount) as Amount,sum(Quantity) as Quantity from cte
where cte.weekday_name in ('Sat','Sun')
group by cte.weekday_name
order by Amount desc

--Amount and Quanity bought on weekdays
with cte as
(select *,FORMAT_DATE('%a', Date) AS weekday_name from `Retail_sales.Sales_table`)
select cte.weekday_name,sum(Total_Amount) as Amount,sum(Quantity) as Quantity from cte
where cte.weekday_name  not in ('Sat','Sun')
group by cte.weekday_name
order by Amount desc

--items and its cost
select distinct(product_category),Price_per_Unit
from `Retail_sales.Sales_table`
where Price_per_Unit in 
(select Price_per_Unit from `Retail_sales.Sales_table`)

--average Amount by product category
select Product_Category,round(sum(Total_Amount)/sum(Quantity),2) as avg_amount
from `Retail_sales.Sales_table`
group by Product_Category

--percentage of Amount bought by gender
with cte as (select Gender,sum(Total_amount) as Amount_by_gender
from `Retail_sales.Sales_table`
group by Gender)
select cte.Gender,
round(SAFE_DIVIDE(cte.Amount_by_gender,sum(cte.Amount_by_gender) over ()),2)*100 as Amount_percentage_by_gender
from cte
order by Amount_percentage_by_gender desc


--Amount percentage by quarter
with cte as
(select extract(quarter from Date) as quarter,sum(Total_Amount) as Amount_quarter_category
from `Retail_sales.Sales_table`
group by quarter)
select cte.quarter,
round(SAFE_DIVIDE(Amount_quarter_category,SUM(Amount_quarter_category) OVER()),2)*100 AS share_revenue
from cte
order by cte.quarter

--Amount percentage by product category and quarter
with cte as 
(select Product_Category,extract(quarter from Date) as quarter,sum(Total_Amount) as Amount_by_quarter_category
from `Retail_sales.Sales_table`
group by Product_Category,quarter)
select product_category,quarter,
round(safe_divide(Amount_by_quarter_category,sum(Amount_by_quarter_category) over (partition by cte.quarter)),2)*100 as amount_percent
from cte
order by quarter


--percentage of amount spent by gender for their bauty
with cte as 
(select product_category,gender,sum(Total_Amount) as Amount_by_criteria
from `Retail_sales.Sales_table`
group by product_category,Gender)
select product_category,gender,
round(safe_divide(cte.Amount_by_criteria,sum(cte.Amount_by_criteria)over(partition by product_category)),2)*100
as Amount_percent
from cte
where product_category='Beauty'

--quantity percent and amount percent 
--% of proudct category bought and % of amount received
with cte as
(select case when Price_per_Unit>100 then "costly" else "cheap" end as price_category,
sum(Total_Amount) as Amount,sum(quantity) as quantity_total
from `Retail_sales.Sales_table`
group by price_category)
select price_category,round(safe_divide(quantity_total,sum(quantity_total)over()),2)*100 as quantity_percent,
round(safe_divide(Amount,sum(Amount) over()),2)*100 as Amount_percent
from cte


