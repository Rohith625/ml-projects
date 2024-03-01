create database Employee_attriton_rate;
use Employee_attriton_rate;

#import table from CSV
select * from employee_data;

#write a sql query to find the details of employees under attrition having 5+years of experience in between age group 27-35
select *
from employee_data
where attrition ='Yes'
and totalworkingyears>=5
and Age between 27 and 35;

#fetch the details of employyes having maximum and minimum salary working in different departments who received less than 13% hike
select department,max(monthlyincome) as max_salary,min(monthlyincome) as min_salary
from employee_data
where percentsalaryhike<13
group by department;

#calculate the average monthly income of all the employees who worked more than 3 years whose education background is medical
select educationfield,round(avg(monthlyincome),2) as avg_income
from employee_data
where educationfield='Medical'
and totalworkingyears>=3
group by educationfield;

#identify the total no.of male amd female employees under attrition whose marital status is married and havent received promotion in last 2 years

select gender,count(*) as cnt_emp
from employee_data
where attrition='Yes' and maritalstatus='Married' and YearsSinceLastPromotion > 2
group by gender;

#employees with max performance rating but no promotion for 4 years and above

select yearssincelastpromotion,max(performancerating) as max_rating
from employee_data
group by yearssincelastpromotion
having yearssincelastpromotion > 4;


select *
from employee_data
where performancerating = (select max(performancerating) from employee_data)
and yearssincelastpromotion > 4;

#who has max and min salary percentage hike
select *
from employee_data
where percentsalaryhike=(select max(percentsalaryhike) from employee_data)
or percentsalaryhike=(select min(percentsalaryhike) from employee_data)
order by percentsalaryhike;

#employees working overtime but given min salary hike and are more than 5 years with company
select *
from employee_data
where overtime='Yes' and yearsatcompany > 5 and percentsalaryhike=(select min(percentsalaryhike) from employee_data);

#count of employees by performance rating and job satisfaction
select performancerating,jobsatisfaction,count(*) as count_of_emp
from employee_data
group by performancerating,jobsatisfaction
order by performancerating asc,jobsatisfaction asc;

#monthly income by education field and fresher
select educationfield,max(monthlyincome) as max_income
from employee_data
where totalworkingyears=0
group by educationfield;

#creating age group by age column as adult,senior adult and old age
#adult > 18 and < 30
#senior adult >30and <45
#old age >45 
alter table employee_data
add age_group varchar(30) as (case  when age > 18 and age <= 30 then "Adult"
when age > 30 and age <=45 then "Senior Adult" else "Old Age" end );

#count of employees and average of monthly income with experience of total working years and age group
select  age_group,totalworkingyears,count(*) as count_of_emp,avg(monthlyincome) as avg_income
from employee_data
group by age_group,totalworkingyears
order by totalworkingyears desc;

#comparing business travel and distance fromhome
select businesstravel,distancefromhome,count(*) as count_of_emp
from employee_data
group by businesstravel,distancefromhome
order by businesstravel,distancefromhome;


#count of employees who travel frequently by distance from home
with cte as
(select businesstravel,distancefromhome,count(*) as count_of_emp
from employee_data
where businesstravel='Travel_Frequently'
group by businesstravel,distancefromhome
order by businesstravel,distancefromhome)
select distancefromhome,max(count_of_emp) as max_count_emp
from cte
group by distancefromhome;


#which job role has maxmum number of employees with highest job satisfaction
with cte as(select jobrole,count(*) as count_of_emp
from employee_data
where jobsatisfaction=(select max(jobsatisfaction) from employee_data)
group by jobrole)
,cte1 as 
(select jobrole,count_of_emp 
from cte 
where count_of_emp=(select max(count_of_emp) from cte))
select * from cte1;

#which category of emlpoyees having attrition yes 
with cte as 
(select attrition,worklifebalance,jobsatisfaction,jobinvolvement,count(*) as count_of_emp
from employee_data
where attrition='Yes'
group by attrition,worklifebalance,jobsatisfaction,jobinvolvement
)
select attrition,worklifebalance,jobsatisfaction,jobinvolvement
from cte
where count_of_emp=(select max(count_of_emp) from cte);

#attrition rate by performance rating versus gender
with cte as(select performancerating,gender,count(*) as count_of_emp
from employee_data
where attrition='Yes' 
group by performancerating,gender)
select *
from cte
where count_of_emp=(select max(count_of_emp) from cte);

#count of employee having no promotion by staying in same company and with current role and current manager
select yearsatcompany,yearsincurrentrole,yearswithcurrmanager,count(*) as count_of_emp
from employee_data
where yearssincelastpromotion=0 and yearsatcompany>0 and yearsincurrentrole >0 and yearswithcurrmanager > 0
group by yearsatcompany,yearsincurrentrole,yearswithcurrmanager
order by yearsatcompany,yearsincurrentrole,yearswithcurrmanager;

#count of employee having same experience  at company,same role in current company and with same manager got no promotion
#make years as 0-3,3-7 and 7+ and count employees
with cte as 
(select *,(case when yearsatcompany between 0 and 3 then "0-3"
when yearsatcompany between 3 and 7 then "3-7"
else "7+" end )as years_at_cmp_group,
(case when yearsincurrentrole between 0 and 3 then "0-3"
when yearsincurrentrole between 3 and 7 then "3-7" else "7+" end) as years_in_curr_role_grp,
(case when yearswithcurrmanager between 0 and 3 then "0-3"
when yearswithcurrmanager between 3 and 7 then "3-7" else "7+" end) as years_with_curr_manager_grp,
(case when yearssincelastpromotion between 0 and 3 then "0-3" 
when yearssincelastpromotion between 3 and 7 then "3-7" else "7+" end) as  years_since_last_promotion_grp
from employee_data)
select years_at_cmp_group,years_in_curr_role_grp,years_with_curr_manager_grp,years_since_last_promotion_grp,count(*) as count_of_emp
from cte
where  years_at_cmp_group=years_in_curr_role_grp and years_since_last_promotion_grp=years_with_curr_manager_grp and
years_at_cmp_group=years_since_last_promotion_grp and years_in_curr_role_grp=years_with_curr_manager_grp
group by years_at_cmp_group,years_in_curr_role_grp,years_with_curr_manager_grp,years_since_last_promotion_grp
order by count(*) desc;

#count of employee having same experience  at company,same role in current company and with same manager got no promotion
select yearsatcompany,yearsincurrentrole,yearswithcurrmanager,yearssincelastpromotion,count(*) as count_of_emp
from employee_data
where  yearsatcompany=yearsincurrentrole and yearssincelastpromotion=yearswithcurrmanager and
yearsatcompany=yearssincelastpromotion and yearsincurrentrole=yearswithcurrmanager
group by yearsatcompany,yearsincurrentrole,yearswithcurrmanager,yearssincelastpromotion
order by count(*) desc;

#count of employee having same experience  at company,same role in current company and with same manager got no promotion and looking 
#for job change
select yearsatcompany,yearsincurrentrole,yearswithcurrmanager,yearssincelastpromotion,count(*) as count_of_emp
from employee_data
where  yearsatcompany=yearsincurrentrole and yearssincelastpromotion=yearswithcurrmanager and
yearsatcompany=yearssincelastpromotion and yearsincurrentrole=yearswithcurrmanager and attrition='Yes'
group by yearsatcompany,yearsincurrentrole,yearswithcurrmanager,yearssincelastpromotion
order by count(*) desc;

#count of employees having experience greater than 7 and earning less than average earning by employee having 2 years below experience
select count(*) 
from employee_data
where totalworkingyears > 7 and monthlyincome < (select avg(monthlyincome) from employee_data where totalworkingyears <=2);

#count of employees having experience greater than 7 and earning less than maximum earning by employee having 2 years below experience
select count(*) 
from employee_data
where totalworkingyears > 7 and monthlyincome < (select max(monthlyincome) from employee_data where totalworkingyears <=2);

#count of employees having experience greater than 7 and earning less than average earning by employee having 2 years below experience
#and looking for a job change
select count(*) as count_of_emp
from employee_data
where totalworkingyears > 7 and monthlyincome < (select avg(monthlyincome) from employee_data where totalworkingyears <=2)
and attrition='Yes';

#count of employees having experience greater than 7 and earning less than average earning by employee having 2 years below experience
#and looking for a job change
select count(*) as count_of_emp
from employee_data
where totalworkingyears > 7 and monthlyincome < (select max(monthlyincome) from employee_data where totalworkingyears <=2)
and attrition='Yes';

#getting nth salary by department
with cte as 
(select department,monthlyincome,dense_rank() over(partition by department order by monthlyincome desc) as rank_salary
from employee_data)
select department,monthlyincome
from cte
where rank_salary=1;

#max salary by dept
select department,max(monthlyincome) as max_sal
from employee_data
group by department;

#comparing salaries who stayed at same company for more than average num of companies worked by all employees

with cte as
(select *,ifnull(round(totalworkingyears/numcompaniesworked),0) as switching_company_probability
from employee_data
where totalworkingyears > 1 and numcompaniesworked > 1
)
select switching_company_probability,round(avg(monthlyincome)) as avg_income
from cte
group by switching_company_probability
order by round(avg(monthlyincome)) desc
limit 1;

#count of employees got hike greater than 20 by working overtime
select count(*) as count_of_emp
from employee_data
where overtime='yes' and percentsalaryhike > 20;

#count of employees who did overtime and got how much hike
select percentsalaryhike,count(*) as count_of_emp
from employee_data
group by percentsalaryhike
order by percentsalaryhike;