
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import logging
import requests
import pytz
from datetime import datetime, timedelta
import os
from azure.storage.blob import BlobServiceClient
import json


class APPHandler:

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
        return  year,month, day


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

        logging.info(f"JSON Responde from the API:  {res_secure_link.text}")

        if res_secure_link.status_code == 200:

            logging.info("Request from the secure link was successful")

            json_response = res_secure_link.json()
            return json_response
        
        else:

            logging.error("The API returned the wrong status code for the given Query parameter. This could mean the report is not ready to download ot is still in pending state.")
            raise Exception("")
        
    
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
