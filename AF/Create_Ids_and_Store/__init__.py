import logging
import traceback
from CommonFiles.APP_File import APPHandler
from CommonFiles.APISetUp import APISetUp
import os

import azure.functions as func


# this is a setUp function for the Microsoft API. We have to register a query and a report for the report. In that order.
# check "https://learn.microsoft.com/en-us/partner-center/insights-programmatic-access-paradigm" for more information on the API
# swagger documentation for the API: https://api.partnercenter.microsoft.com/insights/v1/mpn/swagger/index.html

def main(req: func.HttpRequest) -> func.HttpResponse:
    
    try:

        #vault_url = os.environ['vault_url']
        secret_client = APPHandler.get_secret_client("https://newconsunmptionkeyvault.vault.azure.net/")


        # create query ID and store it into the key Vault
        query_id = APISetUp.create_query_on_server(secret_client)
        secret_client.set_secret('queryID', query_id)
        logging.info("QueryID was stored in Key Vault")


        # create report ID and store it into the key Vault
        report_id = APISetUp.create_report_on_server(secret_client, query_id)
        secret_client.set_secret('reportID', report_id)
        logging.info("ReportID was stored in Key Vault")

        func.HttpResponse("Creating the Query ID and the Report ID  was successful and now stored in Key Vault for further access", status_code=200)


    except Exception as e:

        error_traceback = traceback.format_exc()

        return func.HttpResponse( str(e) + " --------" + error_traceback ,status_code=400)


