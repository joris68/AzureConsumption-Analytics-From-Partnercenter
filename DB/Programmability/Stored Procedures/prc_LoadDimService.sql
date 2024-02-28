CREATE PROCEDURE [dbo].[prc_LoadDimService]
AS
  DROP TABLE IF EXISTS #tab1;
  WITH CTE_BASE 
  AS
  (
    SELECT 
    
        CONVERT(NVARCHAR(255),ISNULL(NULLIF([ServiceLevel1],''),'N/A')) 	ServiceLevel1
          ,CONVERT(NVARCHAR(255),ISNULL(NULLIF([ServiceLevel2],''),'N/A')) 	ServiceLevel2
          ,CONVERT(NVARCHAR(255),ISNULL(NULLIF([ServiceLevel3],''),'N/A')) 	ServiceLevel3
          ,CONVERT(NVARCHAR(255),ISNULL(NULLIF([ServiceLevel4],''),'N/A')) 	ServiceLevel4
    
      FROM [stg].[StagingArea]
  )

  SELECT 
    ServiceLevel1
    ,ServiceLevel2
    ,ServiceLevel3
    ,ServiceLevel4
    ,CONVERT(NVARCHAR(1000),
      UPPER(ServiceLevel1)  +'|'
      +UPPER(ServiceLevel2) +'|'
      +UPPER(ServiceLevel3) +'|'
      +UPPER(ServiceLevel4) +'|'
    ) BkService
  INTO #tab1
  FROM CTE_BASE  
  GROUP BY 
    ServiceLevel1
    ,ServiceLevel2
    ,ServiceLevel3
    ,ServiceLevel4


  MERGE [dwh].[DimService] AS dest  
  USING #tab1 as src ON dest.BkService = src.BkService
  WHEN MATCHED AND 
    (
      dest.[ServiceLevel1]	!= src.[ServiceLevel1]
      OR dest.[ServiceLevel2]	!= src.[ServiceLevel2]
      OR dest.[ServiceLevel3]	!= src.[ServiceLevel3]
      OR dest.[ServiceLevel4]	!= src.[ServiceLevel4]
    )
  THEN UPDATE SET 
    ServiceLevel1 =  src.ServiceLevel1
    ,ServiceLevel2 = src.ServiceLevel2
    ,ServiceLevel3 = src.ServiceLevel3
    ,ServiceLevel4 = src.ServiceLevel4
    ,[UpdateDate]  = GETDATE()
  WHEN NOT MATCHED THEN  
  INSERT 
  (
    [BkService]
    ,[ServiceLevel1]
    ,[ServiceLevel3]
    ,[ServiceLevel2]
    ,[ServiceLevel4]
    ,[InsertDate]
    ,[UpdateDate]
  )  
  VALUES (

    src.[BkService]
    ,src.[ServiceLevel1]
    ,src.[ServiceLevel3]
    ,src.[ServiceLevel2]
    ,src.[ServiceLevel4]
    ,GETDATE()
    ,GETDATE()
  );