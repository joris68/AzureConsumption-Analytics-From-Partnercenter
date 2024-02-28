CREATE PROCEDURE [dbo].[prc_LoadDimPartner] AS 

DROP TABLE IF EXISTS #tab1;
WITH CTE_BASE 
AS
(
	SELECT 
	
		   CONVERT(NVARCHAR(255),ISNULL(NULLIF(PartnerName,''),'N/A')) 	PartnerName
	      ,CONVERT(INT,ISNULL(NULLIF(MPNId,''),-1)) 		MPNId
	      ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(PartnerLocation,''),'N/A')) 	PartnerLocation
	      ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(PartnerAttributionType,''),'N/A')) 	PartnerAttributionType
	  FROM [stg].[StagingArea]
)

SELECT 
	PartnerName
	,MPNId
	,PartnerLocation
	,PartnerAttributionType
	,CONVERT(NVARCHAR(1000),
		UPPER(CONVERT(NVARCHAR(50),MPNId))  +'|'
		+UPPER(PartnerAttributionType) +'|'
	) BkPartner
INTO #tab1
FROM CTE_BASE  
GROUP BY 
	PartnerName
	,MPNId
	,PartnerLocation
	,PartnerAttributionType

MERGE [dwh].DimPartner AS dest  
USING #tab1 as src ON dest.BkPartner = src.BkPartner
WHEN MATCHED AND 
	(
		dest.MPNId	!= src.MPNId
		OR dest.PartnerLocation	!= src.PartnerLocation
		OR dest.PartnerAttributionType	!= src.PartnerAttributionType
		OR dest.PartnerName	!= src.PartnerName
	)
THEN UPDATE SET 
	MPNId =  src.MPNId
	,PartnerLocation = src.PartnerLocation
	,PartnerAttributionType = src.PartnerAttributionType
	,PartnerName = src.PartnerName
	,[UpdateDate]  = GETDATE()
WHEN NOT MATCHED THEN  
INSERT 
(
	BkPartner
	,MPNId
	,PartnerLocation
	,PartnerAttributionType
	,PartnerName
	,InsertDate
	,UpdateDate
)  
VALUES (

	 src.BkPartner
	,src.MPNId
	,src.PartnerLocation
	,src.PartnerAttributionType
	,src.PartnerName
	,GETDATE()
	,GETDATE()
);


