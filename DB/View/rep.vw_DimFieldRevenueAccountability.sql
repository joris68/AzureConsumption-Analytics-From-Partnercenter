CREATE VIEW rep.vw_DimFieldRevenueAccountability AS
  SELECT
    SkFieldRevenueAccountability
    ,ServiceGroup2
    ,ServiceGroup3
  FROM dwh.DimFieldRevenueAccountability
