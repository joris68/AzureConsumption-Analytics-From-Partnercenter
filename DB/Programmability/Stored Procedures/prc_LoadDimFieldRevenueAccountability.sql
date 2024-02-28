CREATE PROCEDURE [dbo].[prc_LoadDimFieldRevenueAccountability]
AS
  DROP TABLE IF EXISTS #tab1;
  WITH CTE_BASE 
  AS
  (
    SELECT 
    
        CONVERT(NVARCHAR(255),ISNULL(NULLIF([ServiceGroup2],''),'N/A')) 	ServiceGroup2
          ,CONVERT(NVARCHAR(255),ISNULL(NULLIF(ServiceGroup3,''),'N/A')) 	ServiceGroup3
      FROM [stg].[StagingArea]
  )

  SELECT 
    ServiceGroup2
    ,ServiceGroup3
    ,CONVERT(NVARCHAR(1000),
      UPPER(ServiceGroup2)  +'|'
      +UPPER(ServiceGroup3) +'|'
    ) BkFieldRevenueAccountability
  INTO #tab1
  FROM CTE_BASE  
  GROUP BY 
    ServiceGroup2
    ,ServiceGroup3


  MERGE [dwh].[DimFieldRevenueAccountability] AS dest  
  USING #tab1 as src ON dest.BkFieldRevenueAccountability = src.BkFieldRevenueAccountability
  WHEN MATCHED AND 
    (
      dest.[ServiceGroup2]	!= src.[ServiceGroup2]
      OR dest.[ServiceGroup3]	!= src.[ServiceGroup3]
    )
  THEN UPDATE SET 
    ServiceGroup2 =  src.ServiceGroup2
    ,ServiceGroup3 = src.ServiceGroup3
    ,[UpdateDate]  = GETDATE()
  WHEN NOT MATCHED THEN  
  INSERT 
  (
    [BkFieldRevenueAccountability]
    ,[ServiceGroup2]
    ,[ServiceGroup3]
    ,InsertDate
    ,UpdateDate
  )  
  VALUES (

    src.[BkFieldRevenueAccountability]
    ,src.[ServiceGroup2]
    ,src.[ServiceGroup3]
    ,GETDATE()
    ,GETDATE()
  );