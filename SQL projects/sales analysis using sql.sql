#creating database
create database retail_sales

#using it
use retail_sales

#selecting all data
select * from sales

#info about colums
describe sales

#updating date column to date format
 UPDATE `sales` SET `Date` = str_to_date( `Date`, '%d-%m-%Y' );
 
 #changing the datatype of date column to date
 alter table sales
 change `Date` `Date` date
 
#calculating new amount as new column
alter table sales
add new_amount int

update sales
set new_amount=(amount-(amount*discount))

#calculating cost price as a new column
alter table sales
add cost_price int

update sales
set cost_price=(new_amount-(new_amount*`profit %`))

#creating profit column
alter table sales
add profit int

update sales 
set profit=(new_amount-cost_price)

#creating age group column
alter table sales
add agegroup varchar(50)

update sales
set agegroup=(select case when age>15 and age<=22 then "Adolescene" when age>22 and age<45 then "Adult" 
else "senior Adult" end)

#How does customer age and gender influence their purchasing behavior?
select agegroup,gender,sum(new_amount) as total_amount
from sales
group by agegroup,gender
order by total_amount desc,agegroup,gender

#creating a month name as new column 
alter table sales
add month varchar(50)

update sales 
set month=(select monthname(Date))

#creating seasons summer ,winter and rainy from date as new column
alter table sales
add season varchar(50)

update sales
set season=(select case when month(Date)>=3 and month(Date)<=6 then "Summer"
when month(Date)>=7 and month(Date)<=10 then "Rainy" else "Winter" end)

#creating wwekday as new column from date like monday,tuesday etc
alter table sales
add daynames varchar(50)

update sales 
set daynames=(select dayname(date))

#Are there discernible patterns in sales across different time periods?
select month,`Product Category`,sum(new_amount) as total_amount from sales
group by month,`Product Category`
order by month 

select daynames,`Product Category`,sum(new_amount) as total_amount from sales
group by daynames,`Product Category`
order by daynames,total_amount desc

#Which product categories hold the highest appeal among customers?
select `Product Category`,sum(new_amount) as total_amount,sum(quantity) as quantity_total
from sales
group by `Product Category`
order by total_amount desc,quantity_total desc

#How do customers adapt their shopping habits during seasonal trends?
select season,`Product Category`,sum(new_amount) as total_amount from sales
group by season,`Product Category`
order by season,total_amount desc

#What are the relationships between age, spending, and product preferences?
select agegroup,gender,`Product Category`,round(avg(new_amount),2) as avg_amount
from sales
group by agegroup,gender,`Product Category`
order by avg_amount desc,agegroup,gender

#quantity bought by product category
select `Product Category`,sum(quantity) as quantity_total from sales
group by `Product Category`
order by quantity_total desc
