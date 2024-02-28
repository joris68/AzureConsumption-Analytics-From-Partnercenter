from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import os 
import logging
import requests





#SCOPE = ['fa3d9a0c-3fb0-42cc-9193-47c7ecd2edbd/.default', 'offline_access']

class Tokenizer:

    @classmethod
    def get_params_from_KeyVault(self) -> dict:

        #Key_Vault_URL = os.environ("KeyVaultURL")

        try:
            secret_client = self.getSecretClient("https://newconsunmptionkeyvault.vault.azure.net/")
            CLIENT_ID = secret_client.get_secret("applicationClient")
            REDIRECT_URI = secret_client.get_secret("redirectURI")
            SCOPE = secret_client.get_secret("scope")
            CLIENT_SECRET = secret_client.get_secret("clientSecret")
            AUTH_URL = secret_client.get_secret("microsoftLoginUrl")

        except Exception as e:
            raise Exception("Something went wrong querying the the secrets from the key vault")
        
        params = {
            "CLIENT_ID" : CLIENT_ID.value,
            "REDIRECT_URI" : REDIRECT_URI.value,
            "SCOPE": SCOPE.value,
            "CLIENT_SECRET" : CLIENT_SECRET.value,
            "AUTH_URL": AUTH_URL.value
        }

        return params




    @classmethod
    def createAuthCodeUrl(self) -> str:

            params = self.get_params_from_KeyVault()
        
            # Construct the authorization URL
            auth_url = params["AUTH_URL"] + 'authorize'
            auth_params = {
                'client_id': params["CLIENT_ID"],
                'response_type': 'code',
                'redirect_uri': params["REDIRECT_URI"],
                'scope': f"{params['SCOPE']} offline_access"
            }

            auth_url = auth_url + '?' + '&'.join([f'{k}={v}' for k, v in auth_params.items()])

            logging.info(f"this is the auth code: {auth_url}")

            return auth_url
        

    @classmethod
    def initializeAccesssRefreshTokens(self, auth_code):


        params = self.get_params_from_KeyVault()
        
        # Construct the token request URL
        token_url = params["AUTH_URL"] + 'token'
        token_params = {
                'grant_type': 'authorization_code',
                'code': auth_code,
                'client_id': params["CLIENT_ID"],
                'client_secret': params["CLIENT_SECRET"],
                'redirect_uri': params["REDIRECT_URI"],
                'scope': f"{params['SCOPE']} offline_access"
            }

            # Set the headers with the Content-Type
        headers = {'Content-Type': 'application/x-www-form-urlencoded'}

        try:
            # Send the token request and get the access token
            response = requests.post(token_url, data=token_params, headers=headers)
            response.raise_for_status()
        except Exception as e:
            logging.error(f"HTTP error came back from POST request {str(e)}")
            raise Exception

        access_token = response.json()['access_token']
        access_token_expiration_time = response.json()['expires_in']
        refresh_token = response.json()['refresh_token']
        return access_token, access_token_expiration_time, refresh_token

    @classmethod
    def getSecretClient(self, KEYVAULT_URL):
        try:
            credential = DefaultAzureCredential()
            secret_client = SecretClient(vault_url=KEYVAULT_URL, credential=credential, logging_enable=True)
            logging.info("The secret client has been created.")
            return secret_client
        except Exception as e:
            logging.error(f"Error in getSecretClient: {str(e)}")
            raise

    @classmethod
    def getNewRefreshTokensfromAPI(self, refresh_token):

        params = self.get_params_from_KeyVault()

        try:
            # Construct the token request URL
            token_url = params["AUTH_URL"] + 'token'

            # Construct the token request parameters
            token_params = {
                'grant_type': 'refresh_token',
                'refresh_token': f'{refresh_token}',
                'client_id': params["CLIENT_ID"],
                'client_secret': params["CLIENT_SECRET"],
                'scope': f"{params['SCOPE']} offline_access",
                'redirect_uri': params["REDIRECT_URI"],
            }

            headers = {"content-Type" : "application/x-www-form-urlencoded"}

            response = requests.post(url=token_url, data=token_params, headers=headers)
            response.raise_for_status()

            # Get the access token and refresh token form the response
            access_token = response.json()['access_token']
            access_token_expiration_time = response.json()['expires_in']
            refresh_token = response.json()['refresh_token']

            # return the response in Json format
            return access_token, access_token_expiration_time, refresh_token
        except Exception as e:
            logging.error(f"Error in getNewRefreshTokensfromAPI: {str(e)}")
            raise
