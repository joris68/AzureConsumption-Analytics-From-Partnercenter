# Introduction 

This is an Azure-Cloud Resource Consumption Solution. This Solution is viable for direct in indirect Microsoft Partners.
While in the Microsoft Partner Center reports are available on a monthly basis, they do not allow analysis during the month and also historization
of a partners Cloud business developement.
(Consumption Data will be updated every 4 days. Check out: https://learn.microsoft.com/en-us/partner-center/insights-data-frequency)


# Authentication Management

1. Register an Entra Application. This will yield an application ID (this is also known as the client_id, because when authenticating to the Identity platform from microsoft we act as a client) and an object ID for service principle (for managed Identity ). And an application object.


!!Important!! in our case we need to register a multitenant ID, why I am really not sure.... Probably because of Abtis...

Also, in the Partnercenter our newly registered Application MUST become the role of "Executive report viewer", otherwise sensitive data like Revenue data cannot be accessed.

Reading:
https://learn.microsoft.com/en-us/partner-center/insights-programmatic-prerequisites#create-microsoft-entra-application
https://learn.microsoft.com/en-us/partner-center/insights-roles



Why do I need to register an application for for Microsoft Entra ID??
    a. delegete Identity and access management
    b. we create an identity confifguration for our Application to integrate into the Identity Platform (Entra ID)
    c. we tell the platform how to issue access and refresh tokens based on the settings defined in our application
    (https://learn.microsoft.com/en-us/entra/identity-platform/how-applications-are-added)


To not confuse things, application is used for two terms here:
1. The object for the Identity Platform.
2. Our actual code - lets call it our Solution 


What even is an Application (in the context of Entra ID)?
An Application can conist out of a bunch of stuff.
- Name, logo, and publisher
- Redirect URIs
- Secrets (symmetric and/or asymmetric keys used to authenticate the application)
- API dependencies (OAuth)
- Published APIs/resources/scopes (OAuth)
- App roles
- Single sign-on (SSO) metadata and configuration
- User provisioning metadata and configuration
- Proxy metadata and configuration


For our Solution we need Secrets, RedirectURI and API dependencies for Example.


What is an Application Object?
An Application Object is used as a blueprint to issue on or more Service Principals. Application Object and Service Principal can be in a one to many relationship. 

What is a Service Principal. There are three types of Service Pricipals:
1. Application. It defines what the app can do in a specific tenant. And WHAT resources the App can access (we need this for our Application and in order for our Solution to work.)
2. managed Identities
3. Legacy

For further details, check out (really complicated): https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals?tabs=browser

So, our Soluation via Scope. We will "register" this via the API-ID. 
API-ID for the Partnercenter API, can be found in Entra-ID when giving access, also it can be found in the official Github (https://github.com/MicrosoftDocs/partner-rest/blob/docs/partner-rest/develop/api-authentication.md) and the Microsoft documentation (https://learn.microsoft.com/en-us/partner-center/developer/secure-sample-application)

This process is called the Secure Application Model (https://learn.microsoft.com/en-us/partner-center/developer/enable-secure-app-model#create-a-web-app).
We need to make the API calls from an admin agent or sales agent account.

The authorization works like this: Once we have gotten a refresh token we will authenticate with the refresh token to get a new access token for whatever out solution does. The access token will expire after 1 hour.
But how Do we obtain the first refresh token? We need to get a authentication code.

Also, the Redirect URI will be a Azure Function URL, which will be  write the


1. Get  authorization code : 
    https://login.microsoftonline.com/common/oauth2/v2.0/authorize?

    client_id=[APPLICATION ID]&response_type=code&
    redirect_uri=[REDIRECT URI]&scope=[SCOPE]


Important: offline-access MUST be added to the scope, otherwise refresh token won't be returned.

2. obtain the first refresh token
    https://login.microsoftonline.com/common/oauth2/v2.0/token
    Content-Type: application/x-www-form-urlencoded

    grant_type=authorization_code&
    code=[AUTHORIZATION CODE]&
    client_id=[APPLICATION ID]&
    client_secret=[PASSWORD]&
    scope=[SCOPE]&
    edirect_uri=[REDIRECT URI]

3. After that, will wee authenticate Via refresh token to obtain ne access tokens.

    https://login.microsoftonline.com/common/oauth2/v2.0/token
    Content-Type: application/x-www-form-urlencoded

    grant_type=refresh_token&
    refresh_token=[REFRESH TOKEN]&
    client_id=[APPLICATION ID]&
    client_secret=[PASSWORD]&
    scope=[SCOPE]&
    redirect_uri=[REDIRECT URI]

Further Reading:
- https://massivescale.com/microsoft-v2-endpoint-primer/
- https://learn.microsoft.com/en-us/partner-center/developer/enable-secure-app-model#get-authorization-code



# Microsoft Partnercenter API

After getting an access token, we can now identify to the microsoft Partnercenter API to get the acutal Data.

Partnercenter API SetUP (reading : https://learn.microsoft.com/en-us/partner-center/insights-programmatic-access-paradigm):

1. We need to create a query on the Server. This is SQL like. You can find this in the Python file "APISetUp.py". This will return a queryID.
2. We need to create a report on the server with an already given query ID. We will need to specify a redirect URI, the startTime, recurrenceInterval, and recurrenceCount. This will yield a reportID.

3. Normally, our web Application (Azure Function) should be called from the PartnerCenter Notification service, whenever a new dataset is ready for download.

4. We will extract the field "reportAccessSecureLink" from the Answer contains the actual URl where we can download our data from.



# Build and Test

1. We already know our TenantID

2. register a Enterprise Application in Entra ID
    This will yield: application_id, application_object_id, redirect_uri (just choose the default)

3. Figure out the scope -> define scope

4. deploy Azure Key Vault ans set  following secrets: ApplicationID, Application_secret, scope, redirect_uri

5. deploy storage account, save connection string tzo key vault

6. deploy SQL Server and database and store connectionstring in keyvault
    deploy stored procedures to the database and build tables

7. deploy Azure Data Factory with linked services to storage account and database
    now the infrastructure is ready

8. Invoke function InitializeKeyVaultTokens

9. Invoke functions refreshKeyVaultTokens ->  create_Ids_and_store
    now everything should be ready.
    Azure function should be triggered via Notofication service from Microsoft API and Azure data Factory via Blobtrigger.

10. check if everything works
