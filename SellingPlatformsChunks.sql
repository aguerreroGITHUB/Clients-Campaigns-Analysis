--- Catalog vs Stores comparison ---
Select sum(NumCatalogPurchases) as Catalog, 
	sum(NumStorePurchases) as Stores, 
	100*cast(sum(NumCatalogPurchases) as float)/cast(sum(NumStorePurchases)as float) as ProportionPerc
from companyData;

--- Web vs Stores comparison ---
Select sum(NumWebPurchases) as Web, 
	sum(NumStorePurchases) as Stores, 
	100*cast(sum(NumWebPurchases) as float)/cast(sum(NumStorePurchases)as float) as ProportionPerc
from companyData;
