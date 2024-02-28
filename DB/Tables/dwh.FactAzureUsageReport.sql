CREATE TABLE [dwh].[FactAzureUsageReport] 
(
    [SkCustomer]                        INT             NOT NULL,
    [SkFieldRevenueAccountability]      INT             NOT NULL,
    [SkPartner]                         INT             NOT NULL,
    [SkService]                         INT             NOT NULL,
    [SkSubscription]                    INT             NOT NULL,
    MonthYear                           NVARCHAR(255)   NOT NULL,
    LastDayOfMonth                      DATE            NOT NULL,
    AzureConsumedRevenueInUsd           NUMERIC(9,2)    NULL,
    InsertDate                          DATE NOT NULL,
    UpdateDate                          DATE NOT NULL
);
GO


CREATE CLUSTERED INDEX CIX_dwh_FactAzureUsageReport_LastDayOfMonth_SkCustomer
    ON dwh.FactAzureUsageReport
    (LastDayOfMonth,SkCustomer)

