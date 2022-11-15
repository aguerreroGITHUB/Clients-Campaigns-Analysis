--- EDUACTION LEVEL ---
SELECT Education, count(ID) as n
FROM companyData
GROUP BY Education
;
--- MARITAL STATUS ---
SELECT Marital_Status, count(ID) as n
FROM companyData
GROUP BY Marital_Status
;
--- KIDS AT HOME ---
SELECT Kidhome, count(ID) as n
FROM companyData
GROUP BY Kidhome
;
--- TEENS AT HOME ---
SELECT Teenhome, count(ID) as n
FROM companyData
GROUP BY Teenhome
;
--- INCOME RANGE ---
SELECT avg(income) as AvgIncome, stdev(income) as StdIncome,
  avg(income)-stdev(income) as LowerExpectedIncome,
  avg(income)+stdev(income) as HigherExpectedIncome
FROM companyData
;
--- DATES RANGE ---
SELECT min(Dt_Customer) as MinDate,
  max(Dt_Customer) as MaxDate,
FROM companyData
;
