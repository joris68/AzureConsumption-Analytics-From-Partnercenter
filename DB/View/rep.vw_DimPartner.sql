CREATE VIEW rep.vw_DimPartner AS
  SELECT
    SkPartner
    ,MPNId
    ,PartnerName
    ,PartnerLocation
    ,PartnerAttributionType
  FROM dwh.DimPartner


