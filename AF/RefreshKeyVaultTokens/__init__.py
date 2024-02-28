import logging
import os
import requests
import azure.functions as func
from CommonFiles.commonTokens import Tokenizer



def main(req: func.HttpRequest) -> func.HttpResponse:

    try:    
        # ---------------------------------------------------------------
        # Get the Access and Refresh Tokens and store them in KeyVault 
        # ---------------------------------------------------------------
        
        #KEYVAULT_URL = URLConstants.MicrosoftKeyVault
 
        keyVaultClient = Tokenizer.getSecretClient("https://msconsumption.vault.azure.net/")
       
        refresh_token = keyVaultClient.get_secret("refreshtoken")
        
        access_token, access_token_expiration_time, updated_refresh_token = Tokenizer.getNewRefreshTokensfromAPI(refresh_token.value)
        
        keyVaultClient.set_secret("accesstoken", access_token, expires_on=access_token_expiration_time)
        keyVaultClient.set_secret("refreshtoken", updated_refresh_token)
        
        return func.HttpResponse(f"Tokens refreshed successfully and stored in KeyVault", status_code=200)
    
    except Exception as e:
        
        logging.error(e)
        return func.HttpResponse("An Error occured refreshing the tokens.", status_code=500)