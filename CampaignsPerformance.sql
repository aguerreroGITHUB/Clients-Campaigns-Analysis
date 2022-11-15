--- Create the averages table as a view ---
CREATE VIEW [campaign_means] AS
    Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from companyData
    where AcceptedCmp1 = 1 
    UNION ALL
    Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from companyData
    where AcceptedCmp2 = 1 
    UNION ALL
    Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from companyData
    where AcceptedCmp3 = 1 
    UNION ALL
    Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from companyData
    where AcceptedCmp4 = 1 
    UNION ALL
    Select count(ID)as n, avg(MntWines) as wines, avg(MntFruits) as fruits, avg(MntMeatProducts) as meat, 
    avg(MntFishProducts) as fish, avg(MntSweetProducts) as sweets, avg(MntGoldProds) as gold
    from companyData
    where AcceptedCmp5 = 1 ;
    
--- Create the stdevs tabke as a view ---
CREATE VIEW [campaign_stdevs] AS 
    Select count(ID)as n, stdev(MntWines) as wines, stdev(MntFruits) as fruits, stdev(MntMeatProducts) as meat, 
    stdev(MntFishProducts) as fish, stdev(MntSweetProducts) as sweets, stdev(MntGoldProds) as gold
    from companyData 
    where AcceptedCmp1 = 1 
    UNION ALL
    Select count(ID)as n, stdev(MntWines) as wines, stdev(MntFruits) as fruits, stdev(MntMeatProducts) as meat, 
    stdev(MntFishProducts) as fish, stdev(MntSweetProducts) as sweets, stdev(MntGoldProds) as gold
    from companyData 
    where AcceptedCmp2 = 1 
    UNION ALL
    Select count(ID)as n, stdev(MntWines) as wines, stdev(MntFruits) as fruits, stdev(MntMeatProducts) as meat, 
    stdev(MntFishProducts) as fish, stdev(MntSweetProducts) as sweets, stdev(MntGoldProds) as gold
    from companyData 
    where AcceptedCmp3 = 1 
    UNION ALL
    Select count(ID)as n, stdev(MntWines) as wines, stdev(MntFruits) as fruits, stdev(MntMeatProducts) as meat, 
    stdev(MntFishProducts) as fish, stdev(MntSweetProducts) as sweets, stdev(MntGoldProds) as gold
    from companyData 
    where AcceptedCmp4 = 1 
    UNION ALL
    Select count(ID)as n, stdev(MntWines) as wines, stdev(MntFruits) as fruits, stdev(MntMeatProducts) as meat, 
    stdev(MntFishProducts) as fish, stdev(MntSweetProducts) as sweets, stdev(MntGoldProds) as gold
    from companyData 
    where AcceptedCmp5 = 1 ;
