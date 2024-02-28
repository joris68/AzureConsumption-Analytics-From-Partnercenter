import logging

import azure.functions as func
from CommonFiles.commonTokens import Tokenizer

# Es gibt zwei Möglichkeiten warum diese Function gecalled werden sollte:
#1. wir bekommen einen Code via parameter -> der initiale code um uns das erste Refresh token zu holen (als parameter der URL)
#2. wir bekommen ein refresh token im JSON body zurück, um uns fürs nächste mal ber der API zu authentifizieren für das access token

#3. von der URL her können wir es leider nicht unterscheiden

def main(req: func.HttpRequest) -> func.HttpResponse:

    try:

        # Get query parameters from the request
        code_param = req.params.get('code')
        session_state_param = req.params.get('session_state')

        secret_client = Tokenizer.getSecretClient()

        if code_param and session_state_param:
            # this API got redirected for the initial code
            secret_client.set_secret("initialCode", code_param)
            return func.HttpResponse("Inital code retrieved and successfully stored in Key Vault", status_code=200)
        
        else:

            # Get JSON body from the request
            # extract refresh and access token and save it to Key Vault
                req_body = req.get_json()
                if req_body:
                    access_token = req_body["access_token"]
                    refresh_token = req_body["refresh_token"]
                    secret_client.set_secret("accesstoken", access_token)
                    secret_client.set_secret("refreshtoken", refresh_token)
                    return func.HttpResponse("Refresh and access token successfully gotten and stored to Key Vault",status_code=200)
                else:
                    return func.HttpResponse("Have not found JSON body in the Response",status_code=400)

    
    except Exception as e:
        
        logging.error(e)
        return func.HttpResponse("Error initializing tokens", status_code=500)





