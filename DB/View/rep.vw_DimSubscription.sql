CREATE VIEW rep.vw_DimSubscription AS
  SELECT
    SkSubscription
    ,BkSubscriptionId
    ,SubscriptionStartDate
    ,SubscriptionEndDate
    ,SubscriptionState
  FROM dwh.DimSubscription


