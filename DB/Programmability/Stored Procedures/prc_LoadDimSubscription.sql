CREATE PROCEDURE [dbo].[prc_LoadDimSubscription]
AS
  DROP TABLE IF EXISTS #tab1;
  WITH CTE_BASE 
  AS
  (
    SELECT 
    
        CONVERT(NVARCHAR(50),ISNULL(NULLIF(SubscriptionId,''),'N/A')) 	BkSubscriptionId
          ,CONVERT(INT,ISNULL(NULLIF(SubscriptionStartDate,''),-1)) 		SubscriptionStartDate
          ,CONVERT(INT,ISNULL(NULLIF(SubscriptionEndDate,''),-1)) 			SubscriptionEndDate
          ,CONVERT(NVARCHAR(20),ISNULL(NULLIF([SubscriptionState],''),'N/A')) 	SubscriptionState
      FROM [stg].[StagingArea]
  )

  SELECT 
    BkSubscriptionId
    ,SubscriptionStartDate
    ,SubscriptionEndDate
    ,SubscriptionState

  INTO #tab1
  FROM CTE_BASE  
  GROUP BY 
    BkSubscriptionId
    ,SubscriptionStartDate
    ,SubscriptionEndDate
    ,SubscriptionState

  MERGE [dwh].DimSubscription AS dest  
  USING #tab1 as src ON dest.BkSubscriptionId = src.BkSubscriptionId
  WHEN MATCHED AND 
    (
      dest.SubscriptionStartDate	!= src.SubscriptionStartDate
      OR dest.SubscriptionEndDate	!= src.SubscriptionEndDate
      OR dest.SubscriptionState	!= src.SubscriptionState
    )
  THEN UPDATE SET 
    SubscriptionStartDate =  src.SubscriptionStartDate
    ,SubscriptionEndDate = src.SubscriptionEndDate
    ,SubscriptionState = src.SubscriptionState
    ,[UpdateDate]  = GETDATE()
  WHEN NOT MATCHED THEN  
  INSERT 
  (
    BkSubscriptionId
    ,SubscriptionStartDate
    ,SubscriptionEndDate
    ,SubscriptionState
    ,InsertDate
    ,UpdateDate
  )  
  VALUES (

    src.BkSubscriptionId
    ,src.SubscriptionStartDate
    ,src.SubscriptionEndDate
    ,src.SubscriptionState
    ,GETDATE()
    ,GETDATE()
  );


