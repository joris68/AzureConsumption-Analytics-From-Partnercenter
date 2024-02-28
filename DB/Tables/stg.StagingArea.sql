create Table [stg].[StagingArea] (
    -- DimSubscription
    SubscriptionId varchar(255),
    SubscriptionStartDate varchar(255),
    SubscriptionEndDate varchar(255),
    SubscriptionState varchar(255),

    -- DimService
    ServiceLevel1 varchar(255),
    ServiceLevel2 varchar(255),
    ServiceLevel3 varchar(255),
    ServiceLevel4 varchar(255),

    --DimFieldRevenueAccountAbiloty 
    ServiceGroup2 varchar(255),
    ServiceGroup3 varchar(255),

    --DimCustomer
    CustomerTpid Int,
    CustomerTenantId varchar(255),
    CustomerTenantName varchar(255),
    CustomerSegment varchar(255),
    CustomerMarket varchar(255),

    --DimPartner
    MPNId INT ,
    PartnerName varchar(255),
    PartnerLocation varchar(255),
    PartnerAttributionType varchar(255),

    -- Fakt
    IsACRDuplicateAtPGALevel INT,
    ACR_USD float,
    ReportMonth varchar(20),

    InsertDate VARCHAR(50),
    UpdateDate VARCHAR(50)


)
