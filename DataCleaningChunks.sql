--- LOOKING FOR DUPLICATED IDs ---
SELECT 
  count(ID) as IDs, -- how many IDs
	count(distinct(ID)) as distIDs, -- how many distinct IDs. Should be the same as IDs if there are no duplicateds.
	(select count(ID) from dbo.companyData where ID is null) as nulls -- subquery that counts nulls
FROM dbo.companyData
