CREATE VIEW rep.vw_FactAzureUsageReport AS
  SELECT
    SkCustomer
    ,SkFieldRevenueAccountability
    ,SkPartner
    ,SkService
    ,SkSubscription
    ,MonthYear
    ,LastDayOfMonth
    ,AzureConsumedRevenueInUsd
  FROM dwh.FactAzureUsageReport


