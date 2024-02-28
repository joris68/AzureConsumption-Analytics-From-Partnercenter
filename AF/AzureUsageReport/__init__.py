import logging
from CommonFiles.common_MS_API import get_secret_client, get_tokens_from_API, get_time_in_string, get_secure_link_for_report, get_secure_link_data, upload_blob_to_storage
import azure.functions as func
import traceback
import os


def main(req: func.HttpRequest) -> func.HttpResponse:
    try:
        #connecting to my keyVault using managed identity
        vault_url = os.environ['vault_url']
        secret_client = get_secret_client(vault_url)

        #getting the credentials from the Key Vault 
        #sirmads_credentials=secret_client.get_secret("credentials", logging_enable=True)
        #sirmads_tenant=secret_client.get_secret("tenantID", logging_enable=True)
        #refresh_token= secret_client.get_secret("refreshtoken", logging_enable=True)
        #reportID = secret_client.get_secret("reportID") 
       # bearer_token = secret_client.get_secret("bearertoken")

        #brauch ich nicht mehr?
        #json_res_new_token = get_tokens_from_API(sirmads_tenant, refresh_token, sirmads_credentials)

        # read out the variables
        #value_bearer = json_res_new_token['access_token']
        #value_refresh = json_res_new_token['refresh_token']


        value_bearer = secret_client.get_secret("bearertoken")
        value_report = secret_client.get_secret("reportID")

        # refresh the tokens in the Key Vault
        #secret_client.set_secret("refreshtoken",  value_refresh)
        #secret_client.set_secret("bearertoken", value_bearer)


        #--------------------------------------------------------------------------------------------
        year, month, day = get_time_in_string()
        json_response = get_secure_link_for_report(value_report.value, value_bearer.value)

        #----------------------------------------
        # get the execution status and the execution date
        ex_status = json_response['value'][0]['executionStatus']
        ex_date = json_response['value'][0]['reportGeneratedTime']

        #check if the report is already finished to download
        if ex_status == "Completed" and ex_date[0:10] == f"{year}-{month}-{day}":
            sec_link = json_response['value'][0]['reportAccessSecureLink']
        else:
            return func.HttpResponse("Noch nicht Zeit für den Report", status_code=401)
        # -------------------------------------
        logging.info("Und hier ist der secure Link: "+ sec_link)

        # get the data set from the secure link
        data = get_secure_link_data(sec_link)
        upload_blob_to_storage( 'azureusage/' + year + '/' + month,    year + month+ day + "AzureUsage.csv" , data.content) 
        return func.HttpResponse(f"Blob, has been successfully written",status_code=200)
    
    except Exception as e:

        error_traceback = traceback.format_exc()

        return func.HttpResponse( str(e) + " --------" + error_traceback ,status_code=400)

