CREATE VIEW rep.vw_DimService AS
  SELECT
    SkService
    ,ServiceLevel1
    ,ServiceLevel3
    ,ServiceLevel2
    ,ServiceLevel4
  FROM dwh.DimService


