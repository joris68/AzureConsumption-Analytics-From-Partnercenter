CREATE TABLE [dwh].[DimService] (
    SkService INT            IDENTITY (1, 1) NOT NULL,
    BkService NVARCHAR (1000) NOT NULL,
    ServiceLevel1  NVARCHAR (255) NOT NULL,
    ServiceLevel3  NVARCHAR (255) NOT NULL,
    ServiceLevel2  NVARCHAR (255) NOT NULL,
    ServiceLevel4  NVARCHAR (255) NOT NULL, 
    InsertDate           DATE NOT NULL,
    UpdateDate           DATE NOT NULL
    CONSTRAINT [PK_dwh_DimService] PRIMARY KEY ([SkService])
);

