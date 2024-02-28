CREATE PROCEDURE [dbo].[prc_LoadDimCustomer]
AS
DROP TABLE IF EXISTS #tab1;
WITH CTE_BASE 
AS
(
	SELECT 
	
		 CONVERT(INT,ISNULL(NULLIF(CustomerTpid,''),-1)) 			CustomerTpid
	      ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(CustomerTenantId,''),'N/A')) 		CustomerTenantId
	     -- ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(CustomerName,''),'N/A')) 	CustomerName --currently not in src. Mistake DBR ?
	      ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(CustomerSegment,''),'N/A')) 	CustomerSegment
	      ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(CustomerMarket,''),'N/A')) 	CustomerMarket
	      ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(CustomerTenantName,''),'N/A')) 	CustomerTenantName
	  FROM [stg].[StagingArea]
)

SELECT 
	CustomerTpid
	,CustomerTenantId
	,CustomerSegment
	,CustomerMarket
	,CustomerTenantName
	,CONVERT(NVARCHAR(1000),
		UPPER(CONVERT(NVARCHAR(50),CustomerTpid))  +'|'
		+UPPER(CustomerTenantId) +'|'
	) BkCustomer
INTO #tab1
FROM CTE_BASE  
GROUP BY 
	CustomerTpid
	,CustomerTenantId
	,CustomerSegment
	,CustomerMarket
	,CustomerTenantName

MERGE [dwh].DimCustomer AS dest  
USING #tab1 as src ON dest.BkCustomer = src.BkCustomer
WHEN MATCHED AND 
	(
		dest.CustomerTpid	!= src.CustomerTpid
		OR dest.CustomerSegment	!= src.CustomerSegment
		OR dest.CustomerMarket	!= src.CustomerMarket
		OR dest.CustomerTenantName	!= src.CustomerTenantName
		OR dest.CustomerTenantId	!= src.CustomerTenantId
	)
THEN UPDATE SET 
	CustomerTpid =  src.CustomerTpid
	,CustomerSegment = src.CustomerSegment
	,CustomerMarket = src.CustomerMarket
	,CustomerTenantName = src.CustomerTenantName
	,CustomerTenantId = src.CustomerTenantId
	,[UpdateDate]  = GETDATE()
WHEN NOT MATCHED THEN  
INSERT 
(
	CustomerTpid
	,BkCustomer
	,CustomerTenantId
	,CustomerSegment
	,CustomerMarket
	,CustomerTenantName
	,InsertDate
	,UpdateDate
)  
VALUES (

	 src.CustomerTpid
	,src.BkCustomer
	,src.CustomerTenantId
	,src.CustomerSegment
	,src.CustomerMarket
	,src.CustomerTenantName
	,GETDATE()
	,GETDATE()
);


