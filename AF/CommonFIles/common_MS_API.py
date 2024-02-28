# code zum Auslagern, damit die eigentliche Function übersichtlicher wird
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import logging
import requests
import pytz
from datetime import datetime, timedelta
import os
from azure.storage.blob import BlobServiceClient
import json


# get the secret client for connecting to the key vault adn return it
def get_secret_client(vault_url):

    try:

        credential = DefaultAzureCredential()
        secret_client = SecretClient(vault_url=vault_url, credential=credential, logging_enable = True)
        logging.info("successfully gotten the secret client")
        return secret_client
    
    except:

        logging.error("Could not get the secret client")
        raise Exception("Could not get the secret client")




# we are going to need the key Vault objects , the teneant ID , and the Refresh Token
def get_tokens_from_API(tenant, refresh_token, credentials):
    endpoint  = "/oauth2/v2.0/token"

    url_new_token = "https://login.microsoftonline.com/" + tenant.value + endpoint


    payload = credentials.value + refresh_token.value
    logging.info("das ist mein Payload:" + payload)

    headers = {
        "content-Type" : "application/x-www-form-urlencoded"
    }
    
    res_new_token = requests.post(url = url_new_token, data=payload, headers=headers )

    if res_new_token.status_code == 200:

        json_res_new_token = res_new_token.json()

        # return the response in Json format
        return json_res_new_token
    else:
        logging.error("We have gotten the wrong status code from the request to get a new access token")
        raise Exception("We have gotten the wrong status code from the request to get a new access token ")
    

def get_time_in_string():

    timezone = pytz.timezone('Europe/Berlin')

    now = datetime.now(timezone)
    
    
    day = now.day
    month = now.month
    year = now.year

    # Add leading zero to single digit values
    month = f'{month:02d}'
    day = f'{day:02d}'
    year = str(year)

    logging.info("The current Time is stored in variables.")
    
    return  (year,month, day)



# we need the reportID and the bearetoken  as key Vault object´
# # hier setzten wir den getLatestExecution = false -> dann gibts ein value array
# TODO hier nochmal die endparas überprüfen
def get_secure_link_for_report(reportID, bearer_token):

    end_paras = "?executionStatus=Completed&getLatestExecution=False"

    url_report_execution = "https://api.partnercenter.microsoft.com/insights/v1/mpn/ScheduledReport/execution/" + reportID.value + end_paras

    headers= {
        "Authorization": 'Bearer '+ bearer_token.value
    }

    res_secure_link = requests.get(url=url_report_execution, headers=headers)

    logging.info("Hier ist die Antwort der secure Link Abfrage: " +  res_secure_link.text)

    if res_secure_link.status_code == 200:

        logging.info("Request from the secure link was successful")

        json_response = res_secure_link.json()
        return json_response
    
    else:

        logging.error("We have gotten the wrong status code from the request to get the secure link")
        raise Exception("We have gotten the wrong status code from the request to get the secure link")


def get_secure_link_data(sec_link):

    data = requests.get(url= sec_link)

    if  data.status_code == 200:

        logging.info("Successfully gotten the data from the secure link")
        return data
    else:
        logging.error("Could not download the data from the secure link")
        raise Exception("Could not download the data from the secure link")


def upload_blob_to_storage(containerpath, blob_name, blob_content):

    try:

        connection_string = os.environ['storage_connection']

        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        container_client = blob_service_client.get_container_client(containerpath )
        output_blob = container_client.get_blob_client(blob_name)

        output_blob.upload_blob(blob_content)
    
    except:

        logging.error("Something went wrong uploading the blob")
        raise Exception("Something went wrong uploading the blob")


def get_latest_blob_from_staging(container_name, folder_name = None):

    try:

        connection_string = os.environ['storage_connection']
        
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)

      
        container_client = blob_service_client.get_container_client(container_name )
        

        if folder_name == None:
            blob_client = container_client.get_blob_client()
        else:
            blob_client = container_client.get_blob_client(folder_name)


        blob_list = container_client.list_blobs()
       
        last_modified_blob = None
        last_modified_time = None
        
        for blob in blob_list:
            if last_modified_time is None or blob.last_modified > last_modified_time:
                last_modified_blob = blob
                last_modified_time = blob.last_modified

        blob_client = container_client.get_blob_client(last_modified_blob)

        logging.info(f"The latest blob wiht the name {last_modified_blob.name} was successfully from storage retrieved")
        
        return blob_client.download_blob()
    
    except Exception as e:

        logging.info("Something went wrong in the in the process of retrieving the the latest Blob")

        raise Exception("Something went wrong in the in the process of retrieving the the latest Blob")


def create_query_on_server_return_id(secret_client):

    try:

        bearertoken = secret_client.get_secret('bearertoken')

        logging.info("Inside the create DI function we have gotten the bearertokne from the key vault")

        query = "SELECT PGAMpnId,SubscriptionId,SubscriptionStartDate,SubscriptionEndDate,FirstUseDate,SubscriptionState,Month,ServiceLevel1,ServiceLevel2,ServiceLevel3,ServiceLevel4,ServiceInfluencer,ServiceGroup2,ServiceGroup3,ComputeOS,ComputeOSAttribute,ComputeCoreSoftware,UsageUnits,UsageQuantity,CustomerName,CustomerTenantId,CustomerTenantName,CustomerTpid,CustomerSegment,CustomerMarket,MPNId,PartnerName,PartnerLocation,PartnerAttributionType,SalesChannel,EnrollmentNumber,IsACRDuplicateAtPGALevel,ResellerID,ResellerName,IndustryName,VerticalName,AdminType,MonthlySubscriptionLevelACR,PartnerOneSubID,PartnerOneSubCountry,ParticipantPublicCustomerNumber,PCNSubsidiaryName,PCNPartnerName,IsDuplicateAtMpnLevel,IsDuplicateAtPgaAttributionTypeLevel,AI_OfferType,EOU,SubscriptionCount,ACR_USD,CustomerCount,CustomerTenantCount from AzureUsage TIMESPAN LAST_MONTH"

        logging.info(f"This is the query {query}")

        payload_query = {
            "Name": "Azure Usage Query",
            "Description": "Select * from AzureUsage",
            "Query": query
            }
        
        logging.info(f"This is the query payload: {str(payload_query)}")
        
        headers_query = {
            "X-AadUserTicket" : f"{bearertoken.value}",
            "Content-Type": "Application/JSON",
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


def create_report_on_server_return_id(query_id, secret_client):
   
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
       

       

   
