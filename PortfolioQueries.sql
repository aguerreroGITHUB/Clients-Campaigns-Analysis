-- Data Exploration, 2 - Dt_Customer hasn't a format that SQL can read as a date.
SELECT 
	SUBSTRING(Dt_Customer, 1, 2) as day,
	SUBSTRING(Dt_Customer, 4, 2) as month,
	SUBSTRING(Dt_Customer, 7, 4) as year,
	CONCAT(SUBSTRING(Dt_Customer, 7, 4), '-', SUBSTRING(Dt_Customer, 4, 2), '-', SUBSTRING(Dt_Customer, 1, 2)) as cdate
FROM dbo.testings

-- Now that we got the query that reorders it as the way we want, let's save this line into a new column.
-- Since dt_customer was imported as string, we must reorder it.
ALTER TABLE dbo.testings ADD cdate AS  -- If table is well imported, it is imported as date and dt_customer works fine.
CONCAT(SUBSTRING(Dt_Customer, 7, 4), '-', SUBSTRING(Dt_Customer, 4, 2), '-', SUBSTRING(Dt_Customer, 1, 2))

-- Finally, let's check that we did it correctly
SELECT cdate FROM testings
-- Perfect.

-- Data Exploration, 3 - Understand columns, part 1
SELECT Education, Marital_Status
FROM dbo.testings
GROUP BY Education, Marital_Status
ORDER BY Education, Marital_Status


-- Data Exploration, 3 - Understand columns, part 2
SELECT avg(income), stdev(income),
	avg(income)-stdev(income) as LowExpectedIncome,
	avg(income)+stdev(income) as HighExpectedIncome
FROM dbo.testings
-- We expect an income between 26 thousands and 77 thousands from our clients


-- Data Exploration, 3 - Understand columns, part 3
SELECT min(cdate), max(cdate)
FROM dbo.testings
-- Thanks to having created this column, we can ask the database about the minimum and maximum date.
-- Our data covers a time range from july 2012 to june 2014.

-- Data cleaning, 1 - Checking for duplicated or null keys:
SELECT 
	count(ID) as IDs, 
	count(distinct(ID)) as distIDs,
	(select count(ID) from dbo.testings where ID is null) as nulls
FROM dbo.testings


-- Data cleaning, 2 - Nulls in relevant fields
SELECT *
FROM dbo.testings
WHERE Education is null
	OR Marital_Status is null
	OR Income is null
	OR Dt_Customer is null -- cdate would still have "-" symbol


-- Data cleaning, 3 - Misspelled words, extra spaces, input errors...
SELECT distinct(Education) FROM dbo.testings  --1
SELECT distinct(Marital_Status) FROM dbo.testings -- 2- We will only work with Single+Alone, Divorced, Together and Married.
SELECT distinct(kidhome) FROM dbo.testings
SELECT distinct(teenhome) FROM dbo.testings
-- We actually can't check anything for most numeric data, since there will be a lot of distinct values


-- We don't have to relabel anything, all column labels are descriptive enough and easy to work with.
-- We have finished our cleaning stage. The database was already clean but it's a good practice to
--   check it for any new table you work with. We have followed a basic checklist of
--   looking for duplicateds, nulls and any human input error we could detect. 
-- We also have checked that column labels are descriptive enough and are easy to work with.

-- Data analysis, creating total Mnt:
ALTER TABLE dbo.testings ADD TotalMnt AS   -- In any analysis you need a measure for totals.
MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds


-- Kidhome - Teenhome - TotalMnt
Select Kidhome, avg(TotalMnt) as avgSpent
from dbo.testings
group by Kidhome          -- More kids imply less spent.
order by avgSpent desc    -- Clients with kids at home spend way less than clients with no kids.

Select Teenhome, avg(TotalMnt) as avgSpent
from dbo.testings
group by Teenhome
order by avgSpent desc    -- Having teens at home makes client spend slightly less money, but more than with kids.

Select Teenhome + Kidhome as Children, avg(TotalMnt) as avgSpent
from dbo.testings
group by (Teenhome + Kidhome)
order by avgSpent desc    -- We can clearly see that our best target is a client with no children.

Select Teenhome + Kidhome as Children, avg(TotalMnt) as avgSpent, avg(Income),
	cast(avg(TotalMnt) as float) / cast(avg(Income) as float) * 100 as PercentageSpent
from dbo.testings
where income != 0
group by (Teenhome + Kidhome)
order by avgSpent desc   -- Clients with no children are less responsible and waste more % of their income.
-- So, cliends with no children are less responsible about their money and waste a bigger %.
-- They also spend more what we can call "raw money". They are deffinetly our best target.

-- Now we jump to Python.
-- We will export a select * from table query. Remember that you are exporting the TottalMnt new column too.
-- First, copy our query. Then, rightclick our database, tasks, export data and export the query as flat file - csv in the desired folder.
-- Use the same folder as the python script in order to just open de folder in vscode.

import pandas as pd
import pandasql as sql
from pandasql import sqldf
from scipy.stats import ttest_ind

doquery = lambda q: sqldf(q,globals())                              # Function that creates queries

df = pd.read_csv('outputTest.csv', sep = ";")
g1 = doquery("Select TotalMnt from df where Kidhome > 0")
g2 = doquery("Select TotalMnt from df where Teenhome > 0")

ttest_ind(g1, g2)   # p-value is e^-63, we can completly discard spents being the same.
-----------------------------------
                   # Show this first in SQL, ratio will be wrong (not stored as float) but mention that with dataframes it will not be a problem.
                   # Mention that we could cast it as float but since we will use a dataframe, it will end up being useless.
df2 = doquery("""  
    Select Marital_Status, count(ID) as n, avg(Income) as Income, avg(TotalMnt) as Spent, avg(TotalMnt)/avg(Income) as Ratio
    FROM df
    WHERE Marital_Status in ('Single', 'Divorced', 'Together', 'Married')
    GROUP BY Marital_Status
    ORDER BY Ratio desc""")
display(df2)       # We can see how ratio of % of income spent is similar for any Marital status. However, married clients look like
                   #   they are a bit worse target for us.
-----------------------------------
df2 = doquery("""
    Select Education, count(ID) as n, avg(Income) as Income, avg(TotalMnt) as Spent, avg(TotalMnt)/avg(Income) as Ratio
    FROM df
    GROUP BY Education
    ORDER BY Ratio desc""")   # We can clearly see that our best target has, at least, a graduation title or higher.
display(df2)
-----------------------------------
-- So, given our analysis, our best target is not married, has no children and, at least, has a graduation title.





-- ANALYSIS PART 2 - PERFORMANCE OF DEAL CAMPAIGNS
-- First, save this two views:
-- First view:
CREATE VIEW [campaign_means] AS
    Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from testings
    where AcceptedCmp1 = 1 
    UNION ALL
    Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from testings
    where AcceptedCmp2 = 1 
    UNION ALL
    Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from testings
    where AcceptedCmp3 = 1 
    UNION ALL
    Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from testings
    where AcceptedCmp4 = 1 
    UNION ALL
    Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from testings
    where AcceptedCmp5 = 1 ;

-- Second view
CREATE VIEW [campaign_stdevs] AS 
    Select count(ID)as n, stdev(MntWines) as wines, stdev(MntFruits) as fruits, stdev(MntMeatProducts) as meat, 
    stdev(MntFishProducts) as fish, stdev(MntSweetProducts) as sweets, stdev(MntGoldProds) as gold
    from testings 
    where AcceptedCmp1 = 1 
    UNION ALL
    Select count(ID)as n, stdev(MntWines) as wines, stdev(MntFruits) as fruits, stdev(MntMeatProducts) as meat, 
    stdev(MntFishProducts) as fish, stdev(MntSweetProducts) as sweets, stdev(MntGoldProds) as gold
    from testings 
    where AcceptedCmp2 = 1 
    UNION ALL
    Select count(ID)as n, stdev(MntWines) as wines, stdev(MntFruits) as fruits, stdev(MntMeatProducts) as meat, 
    stdev(MntFishProducts) as fish, stdev(MntSweetProducts) as sweets, stdev(MntGoldProds) as gold
    from testings 
    where AcceptedCmp3 = 1 
    UNION ALL
    Select count(ID)as n, stdev(MntWines) as wines, stdev(MntFruits) as fruits, stdev(MntMeatProducts) as meat, 
    stdev(MntFishProducts) as fish, stdev(MntSweetProducts) as sweets, stdev(MntGoldProds) as gold
    from testings 
    where AcceptedCmp4 = 1 
    UNION ALL
    Select count(ID)as n, stdev(MntWines) as wines, stdev(MntFruits) as fruits, stdev(MntMeatProducts) as meat, 
    stdev(MntFishProducts) as fish, stdev(MntSweetProducts) as sweets, stdev(MntGoldProds) as gold
    from testings 
    where AcceptedCmp5 = 1 ;

-- Now, export those 2 tables as csv (rclick database -> tasks -> export data...)
-- Then, let's jump back to python:

import pandas as pd
import pandasql as sql
from pandasql import sqldf


doquery = lambda q: sqldf(q,globals())                              # Function that creates queries

df = pd.read_csv('outputTest.csv', sep = ";")
base = doquery("""Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from df """)

means = pd.read_csv('meanCampaigns.csv', sep = ";")
# Open std table in excel and make it numeric format before running script, decimals are delimited with ","
stds = pd.read_csv('stdCampaigns.csv', sep = ";")

print("n and base averages")
display(base)

print("Means for each campaign:")
display(means)

print("Standard Deviations for each campaign:")
display(stds)

ratios = means.copy()
percentage_deviation = stds.copy()
keys = means.keys()

for i in range(len(base.columns)):
    if i != 0:    # Standard deviation for n makes no sense
        x = 100*(-1)*(base[keys[i]][0]-stds[keys[i]]).div(base[keys[i]][0]).round(2) # -1 because difference will be negative
        percentage_deviation[keys[i]] = x

for i in range(len(base.columns)):
    ratios[keys[i]] = means[keys[i]].div(base[keys[i]][0]).round(2)

print("percentage_deviation:")
display(percentage_deviation)

print("Average increase ratio (x times the average)")
display(ratios)

-- Conclussion:
-- There aren't that much standard deviations that are the double of its value, and we can see that
--   the higher ones are from smaller values so flat increases are more representative.
-- So, most means will be representative enough to give credibility to our analysis.
-- Speaking about means, the second campaign only had 1% of participation (n column). The first 6% and 3,4,5 7%.
--   since in the first campaign there were less clients, we can say that 6% is as successfully than the others 7%.
--   Looking to the mean ratios, clients who participated in the first campaign bought more than two times the average in almost every field.
--   Fruits in second campaign are lower than the average.
--   This comparision is an estimate, we are comparing totals from clients. This is a work for a company who did not store data about their
--     campaigns and we are doing estimates. Of course that real campaign data may be different but, since there are thousands of records,
--     this estimates helps us to find the better possible reliable trends. 
-- We could analyze how relative the n% participation is by only counting clients with a creation date lesser or equal than
--   the lastest creation date from clients who participate in the campaign but, since %s of participation are low,
--   it doesn't have why to be a reliable metric, so we will ignore that detail since the data does not provide the campaign date.
--   So, the first campaigns may have a higher % of participation due to the company having less clients when the capaign was released.

-- ANALYSIS PART 3 - PHYSICAL SHOPS VS WEB
Select sum(NumWebPurchases) as Webs, sum(NumStorePurchases) as Stores
from testings     -- 12 to 9, we can see how store purchases are around one third bigger than webs
-- Web, stil, looks like doing 9 of 21, a bit more of 40% of our purchases.

Select sum(NumCatalogPurchases) as Catalog, sum(NumStorePurchases) as Stores
from testings   -- Around 46% of store purchases are made with a catalog.


-- Both web and store and doing well. Stores still move a bigger volume of sells than the web.
-- Catalogs are suprisingly effective, almost the half of the purchases in stores are made with one.