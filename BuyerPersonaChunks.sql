--- Average Spent by Kids at home ---
Select Kidhome, avg(TotalMnt) as avgSpent
from dbo.companyData
group by Kidhome  
order by avgSpent desc   
;
--- Average Spent by Teens at home ---
Select Teenhome, avg(TotalMnt) as avgSpent
from dbo.companyData
group by Teenhome 
order by avgSpent desc   
;
--- Spent, Income and Spent/Income Ratio per Children ---
Select Teenhome + Kidhome as Children, 
	avg(TotalMnt) as avgSpent, 
	avg(Income) as avgIncome,
	cast(avg(TotalMnt) as float) / cast(avg(Income) as float) * 100 as PercentageSpent -- 100*Spent/Income
from dbo.testings
group by (Teenhome + Kidhome) -- Group by children
order by avgSpent desc 
;
--- Income, Spent and Spent/Income Ratio by Marital Status ---
Select Marital_Status, 
	count(ID) as n,
	avg(Income) as Income,
	avg(TotalMnt) as Spent, 
	cast(avg(TotalMnt)as float) / cast(avg(Income)as float) * 100 as PercentageSpent -- 100*Spent/Income
FROM companyData
WHERE Marital_Status in ('Single', 'Divorced', 'Together', 'Married') -- We will only count relevant fields 
GROUP BY Marital_Status
ORDER BY PercentageSpent desc
;
--- Income, Spent and Spent/Income Ratio by Education level ---
Select Education, 
	count(ID) as n, 
	avg(Income) as Income, 
	avg(TotalMnt) as Spent,
	cast(avg(TotalMnt)as float) / cast(avg(Income)as float) * 100 as PercentageSpent -- 100*Spent/Income
FROM companyData
GROUP BY Education
ORDER BY PercentageSpent desc
;
