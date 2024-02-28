CREATE PROCEDURE [dbo].[prc_LoadFactAzureUsageReport]
AS
  DROP TABLE IF EXISTS #tab1; 
  DROP TABLE IF EXISTS #tabBase; 
  --DECLARE @String NVARCHAR(10) = 'APR-2023';
  ;WITH CTE_BASE 
  AS
  (
    SELECT 
    
      CONVERT(INT,ISNULL(NULLIF(CustomerTpid,''),-1)) 			CustomerTpid
        ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(CustomerTenantId,''),'N/A')) 		CustomerTenantId
      ,CONVERT(NVARCHAR(255),ISNULL(NULLIF([ServiceGroup2],''),'N/A')) 	ServiceGroup2
          ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(ServiceGroup3,''),'N/A')) 	ServiceGroup3
      ,CONVERT(INT,ISNULL(NULLIF(MPNId,''),-1)) 		MPNId
        ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(PartnerAttributionType,''),'N/A')) 	PartnerAttributionType
        ,CONVERT(NVARCHAR(255),ISNULL(NULLIF([ServiceLevel1],''),'N/A')) 	ServiceLevel1
          ,CONVERT(NVARCHAR(255),ISNULL(NULLIF([ServiceLevel2],''),'N/A')) 	ServiceLevel2
          ,CONVERT(NVARCHAR(255),ISNULL(NULLIF([ServiceLevel3],''),'N/A')) 	ServiceLevel3
          ,CONVERT(NVARCHAR(255),ISNULL(NULLIF([ServiceLevel4],''),'N/A')) 	ServiceLevel4
      ,CONVERT(NVARCHAR(50),ISNULL(NULLIF(SubscriptionId,''),'N/A')) 	BkSubscriptionId
      ,CASE 
        WHEN ReportMonth like '%JAN%' THEN N'01' 
        WHEN ReportMonth like '%FEB%' THEN N'02' 
        WHEN ReportMonth like '%MAR%' THEN N'03' 
        WHEN ReportMonth like '%APR%' THEN N'04' 
        WHEN ReportMonth like '%MAY%' THEN N'05' 
        WHEN ReportMonth like '%JUN%' THEN N'06' 
        WHEN ReportMonth like '%JUL%' THEN N'07' 
        WHEN ReportMonth like '%AUG%' THEN N'08' 
        WHEN ReportMonth like '%SEP%' THEN N'09' 
        WHEN ReportMonth like '%OCT%' THEN N'10' 
        WHEN ReportMonth like '%NOV%' THEN N'11'
        WHEN ReportMonth like '%DEC%' THEN N'12'
        ELSE 'N/A'
      END AS MM
      , SUBSTRING(ReportMonth,CHARINDEX('-',ReportMonth)+1,LEN(ReportMonth)) AS YYYY
      ,CONVERT(NVARCHAR(255),ReportMonth) AS MonthYear
      ,CONVERT(NUMERIC(9,2),ACR_USD) AS  AzureConsumedRevenueInUsd 
      FROM [stg].[StagingArea]
  )

  SELECT 
    CONVERT(NVARCHAR(1000),
      UPPER(CONVERT(NVARCHAR(50),CustomerTpid))  +'|'
      +UPPER(CustomerTenantId) +'|'
    ) BkCustomer
    ,CONVERT(NVARCHAR(1000),
        UPPER(ServiceGroup2)  +'|'
        +UPPER(ServiceGroup3) +'|'
      ) BkFieldRevenueAccountability
    ,CONVERT(NVARCHAR(1000),
      UPPER(CONVERT(NVARCHAR(50),MPNId))  +'|'
      +UPPER(PartnerAttributionType) +'|'
    ) BkPartner
      ,CONVERT(NVARCHAR(1000),
        UPPER(ServiceLevel1)  +'|'
        +UPPER(ServiceLevel2) +'|'
        +UPPER(ServiceLevel3) +'|'
        +UPPER(ServiceLevel4) +'|'
      ) BkService
    ,BkSubscriptionId
    ,EOMONTH(TRY_CONVERT(DATE,CONCAT(YYYY,'-',MM,'-01'))) AS LastDayOfMonth
    ,MonthYear
    ,AzureConsumedRevenueInUsd
  INTO #tabBase
  FROM CTE_BASE b 

  SELECT 
    dc.SkCustomer
    ,df.SkFieldRevenueAccountability
    ,dp.SkPartner
    ,dse.SkService
    ,ds.SkSubscription
    ,b.MonthYear
    ,MIN(LastDayOfMonth) LastDayOfMonth --MIN(1|1) = 1
    ,SUM(AzureConsumedRevenueInUsd) AS AzureConsumedRevenueInUsd
  INTO #tab1
  FROM #tabBase b 
    INNER JOIN dwh.DimCustomer dc on dc.BkCustomer = b.BkCustomer
    INNER JOIN dwh.DimFieldRevenueAccountability df on df.BkFieldRevenueAccountability = b.BkFieldRevenueAccountability
    INNER JOIN dwh.DimPartner dp on dp.BkPartner = b.BkPartner
    INNER JOIN dwh.DimService dse on dse.BkService = b.BkService
    INNER JOIN dwh.DimSubscription ds on ds.BkSubscriptionId = b.BkSubscriptionId
  GROUP BY 
    dc.SkCustomer
    ,df.SkFieldRevenueAccountability
    ,dp.SkPartner
    ,dse.SkService
    ,ds.SkSubscription
    ,b.MonthYear


   
;MERGE [dwh].FactAzureUsageReport AS dest  
USING #tab1 as src ON 
(
	dest.SkCustomer							= src.SkCustomer 
	AND dest.SkFieldRevenueAccountability	= src.SkFieldRevenueAccountability
	AND dest.SkPartner						= src.SkPartner
	AND dest.SkService						= src.SkService
	AND dest.SkSubscription					= src.SkSubscription
	AND dest.MonthYear						= src.MonthYear
) 
WHEN MATCHED AND 
	(
		dest.LastDayOfMonth	!= src.LastDayOfMonth
		OR dest.AzureConsumedRevenueInUsd	!= src.AzureConsumedRevenueInUsd
	)
THEN UPDATE SET 
	LastDayOfMonth =  src.LastDayOfMonth
	,AzureConsumedRevenueInUsd = src.AzureConsumedRevenueInUsd
	,[UpdateDate]  = GETDATE()
WHEN NOT MATCHED THEN  
INSERT 
(
	SkCustomer 
	,SkFieldRevenueAccountability
	,SkPartner
	,SkService
	,SkSubscription
	,MonthYear
	,LastDayOfMonth
	,AzureConsumedRevenueInUsd
	,InsertDate
	,UpdateDate
)  
VALUES (

	 src.SkCustomer 
	,src.SkFieldRevenueAccountability
	,src.SkPartner
	,src.SkService
	,src.SkSubscription
	,src.MonthYear
	,src.LastDayOfMonth
	,src.AzureConsumedRevenueInUsd
	,GETDATE()
	,GETDATE()
);
 
    

