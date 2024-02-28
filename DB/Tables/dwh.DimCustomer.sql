CREATE TABLE [dwh].[DimCustomer] 
(
    [SkCustomer]         INT            IDENTITY (1, 1) NOT NULL,
    BkCustomer              NVARCHAR(1000)     NOT NULL,             
    [CustomerTpid]       INT NOT NULL,
    [CustomerTenantId]   NVARCHAR (255) NOT NULL,
    [CustomerSegment]    NVARCHAR (255) NOT NULL,
    [CustomerMarket]     NVARCHAR (255) NOT NULL,
    [CustomerTenantName] NVARCHAR (255) NOT NULL,
    InsertDate           DATE NOT NULL,
    UpdateDate           DATE NOT NULL
    CONSTRAINT [PK_dwh_DimCustomer] PRIMARY KEY ([SkCustomer])
);

