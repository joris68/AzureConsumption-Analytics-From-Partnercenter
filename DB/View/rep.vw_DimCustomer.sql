CREATE VIEW rep.vw_DimCustomer AS
  SELECT
    SkCustomer
    ,CustomerTpid
    ,CustomerTenantId
    ,CustomerSegment
    ,CustomerMarket
    ,CustomerTenantName
  FROM dwh.DimCustomer


