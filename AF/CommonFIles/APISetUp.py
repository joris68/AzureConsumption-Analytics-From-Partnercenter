# this file handles the SetUp für de Microsoft Partnercenter API
# and has two follwing Tasks:
#   1. Handles the creation of the automtic report ID, and stores it in the Key Vault
#   2. Handles the creation of the Query ID correlated to the reprt and stores it in the Key Vault

import logging
import requests
from datetime import datetime, timedelta
import os

class APISetUp:

    @classmethod
    def create_query_on_server(cls, secret_client):

        try:

            bearertoken = secret_client.get_secret('accesstoken')

            logging.info("Inside the create DI function we have gotten the bearertokne from the key vault")

            query = "SELECT PGAMpnId,SubscriptionId,SubscriptionStartDate,SubscriptionEndDate,FirstUseDate,SubscriptionState,Month,ServiceLevel1,ServiceLevel2,ServiceLevel3,ServiceLevel4,ServiceInfluencer,ServiceGroup2,ServiceGroup3,ComputeOS,ComputeOSAttribute,ComputeCoreSoftware,UsageUnits,UsageQuantity,CustomerName,CustomerTenantId,CustomerTenantName,CustomerTpid,CustomerSegment,CustomerMarket,MPNId,PartnerName,PartnerLocation,PartnerAttributionType,SalesChannel,EnrollmentNumber,IsACRDuplicateAtPGALevel,ResellerID,ResellerName,IndustryName,VerticalName,AdminType,MonthlySubscriptionLevelACR,PartnerOneSubID,PartnerOneSubCountry,ParticipantPublicCustomerNumber,PCNSubsidiaryName,PCNPartnerName,IsDuplicateAtMpnLevel,IsDuplicateAtPgaAttributionTypeLevel,AI_OfferType,EOU,SubscriptionCount,ACR_USD,CustomerCount,CustomerTenantCount from AzureUsage TIMESPAN LAST_MONTH"

            logging.info(f"This is the query {query}")

            payload_query = {
                "name": "Azure Usage Query",
                "description": "Select * from AzureUsage",
                "query": query
                }
            
            logging.info(f"This is the query payload: {str(payload_query)}")
            
            headers_query = {
                "X-AadUserTicket" : f"{bearertoken.value}",
                "Content-Type": "application/json",
                "accept" : "application/json"

            }

            logging.info(f"This is the header for the query request: {str(headers_query)}")

            response_query = requests.post(url="https://api.partnercenter.microsoft.com/insights/v1/mpn/ScheduledQueries", headers=headers_query, data=payload_query )

            if response_query.status_code == 200:
                query_response_json = response_query.json()

                query_id = query_response_json['value'][0]['queryId']

                logging.info(f"Got the queryID from the MS-Server: {query_id}")
                return query_id
            else:
                query_response_json = response_query.json()
                raise Exception("Else Block: The Query-request returned the wrong status code: "  + str(query_response_json))

        except:
            logging.error("The Query-request returned the wrong status code: "  + str(query_response_json))
            raise Exception("The Query-request returned the wrong status code:" + str(query_response_json))
        
    
    @classmethod
    def create_report_on_server(cls, secret_client, query_id):
        
   
        try:

            bearertoken = secret_client.get_secret('bearertoken')

            url_report =  "https://api.partnercenter.microsoft.com/insights/v1/mpn/ScheduledReport"

            function_app_name = os.environ['function_app_name']

            # generate the starttime

            today = datetime.today()

            # Calculate the date one day from today
            one_day_from_today = today + timedelta(days=1)

            # Format the date in yyyy-MM-dd format
            formatted_date = one_day_from_today.strftime('%Y-%m-%d')

            payload_report = {
                "reportName": "Azure Usage Callback Report",
                "description": "Report for Consumption Data Analysis",
                "queryId": query_id,
                "startTime": f"{formatted_date}T08:00:00Z", # at which the report generation will begin, I will set that per default one day from today at 8 in the morning
                "executeNow": False,
                "queryStartTime": "<<not important>>",
                "queryEndTime": "<<not important>>",
                "recurrenceInterval": 24, # we want to download the report every 24 hours
                "recurrenceCount": 1000, 
                "format": "CSV",
                "callbackUrl": "https://" + function_app_name + ".azurewebsites.net/api/AzureUsageReport?",
                "callbackMethod": "POST"
            }

            logging.info(f"This is the payload for the report request: {str(payload_report)}")

            headers_report = {
                "X-AadUserTicket" : f"{bearertoken.value}",
                "Content-Type": "Application/JSON",
                "accept" : "application/json"
            }

            logging.info(f"This is the header for the query request: {str(headers_report)}")

            response_report = requests.post(url=url_report, headers=headers_report, data=payload_report)

            if response_report.status_code == 200:
                report_response_json = response_report.json()

                report_id = report_response_json['value'][0]['reportId']

                logging.info(f"Got the reportID from the MS-Server: {report_id}")

                return report_id
            else:
                report_response_json = response_report.json()
                raise Exception("Else Block: The Report-request returned the wrong status code: "  + str(report_response_json))
    
        except:
       
            logging.error("The Report-request returned the wrong status code: " +  str(response_report['message']))
            raise Exception("The Reprt-request returned the wrong status code: " + str(response_report['message']))
