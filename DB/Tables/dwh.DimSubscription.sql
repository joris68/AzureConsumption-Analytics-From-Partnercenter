CREATE TABLE [dwh].[DimSubscription] 
(
    [SkSubscription]        INT          IDENTITY (1, 1) NOT NULL,
    [BkSubscriptionId]        NVARCHAR (50) NOT NULL,
    [SubscriptionStartDate] INT          NOT NULL,
    [SubscriptionEndDate]   INT          NOT NULL,
    [SubscriptionState]     NVARCHAR (20) NOT NULL, 
    InsertDate           DATE NOT NULL,
    UpdateDate           DATE NOT NULL
    CONSTRAINT [PK_dwh_DimSubscription] PRIMARY KEY ([SkSubscription])
);

