import logging
import azure.functions as func
import urllib.parse
from CommonFiles.commonTokens import Tokenizer
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def main(req: func.HttpRequest) -> func.HttpResponse:
    
    try: 

        # Get the authorization URL
        #auth_url = createAuthCodeUrl()

        auth_url = Tokenizer.createAuthCodeUrl()
        
        # ---------------------------------------------------------------
        # MFA Automation with Selnium and extract the auth code from the URL.
        # ---------------------------------------------------------------
        
        #driver = webdriver.Chrome()
        driver = webdriver.Edge()
        driver.get(auth_url)
        # This is the codeword to know that the authentication is completed
        auth_response_code = 'code='
        # Wait for the user to complete the authorization flow and be redirected back to the redirect URI
        WebDriverWait(driver, 300).until(EC.url_contains(auth_response_code))
        # Get the full URL
        completeAuthURI = driver.current_url
        # Extract the code from the URL
        parsed_url = urllib.parse.urlparse(completeAuthURI)
        query_params = urllib.parse.parse_qs(parsed_url.query)
        auth_code = query_params.get('code', [None])[0]
        driver.quit()

        # ---------------------------------------------------------------
        # Get the Access and Refresh Tokens and store them in KeyVault 
        # ---------------------------------------------------------------
        
        #KEYVAULT_URL = URLConstants.MicrosoftKeyVault

        access_token, access_token_expiration_time, refresh_token = Tokenizer.initializeAccesssRefreshTokens(auth_code)
        
        keyVaultClient = Tokenizer.getSecretClient("https://msconsumption.vault.azure.net/")
        keyVaultClient.set_secret("accesstoken", access_token, expires_on=access_token_expiration_time)
        keyVaultClient.set_secret("refreshtoken", refresh_token)

        return func.HttpResponse("Tokens initialized successfully and stored in KeyVault", status_code=200)
    
    except Exception as e:
        
        logging.error(e)
        return func.HttpResponse("Error initializing tokens", status_code=500)