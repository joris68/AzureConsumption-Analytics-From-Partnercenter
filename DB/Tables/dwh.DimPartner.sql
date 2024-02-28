CREATE TABLE [dwh].[DimPartner] (
    [SkPartner]             INT           IDENTITY (1, 1) NOT NULL,
    BkPartner                 NVARCHAR(1000)     NOT NULL,             
    MPNId                   INT             NOT NULL, 
    PartnerName             NVARCHAR(255)   NOT NULL, 
    PartnerLocation         NVARCHAR(255)   NOT NULL, 
    PartnerAttributionType  NVARCHAR(255)   NOT NULL, 
    InsertDate           DATE NOT NULL,
    UpdateDate           DATE NOT NULL
    CONSTRAINT [PK_dwh_DimPartner] PRIMARY KEY ([SkPartner])
   
);

