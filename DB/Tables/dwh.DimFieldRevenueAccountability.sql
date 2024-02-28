CREATE TABLE [dwh].[DimFieldRevenueAccountability] 
(
    SkFieldRevenueAccountability INT           IDENTITY (1, 1) NOT NULL,
    BkFieldRevenueAccountability NVARCHAR (255) NOT NULL,
    [ServiceGroup2]  NVARCHAR (255) NOT NULL,
    [ServiceGroup3]  NVARCHAR (255) NOT NULL, 
    InsertDate           DATE NOT NULL,
    UpdateDate           DATE NOT NULL
    CONSTRAINT [PK_dwh_DimFieldRevenueAccountability] PRIMARY KEY ([SkFieldRevenueAccountability])
);

