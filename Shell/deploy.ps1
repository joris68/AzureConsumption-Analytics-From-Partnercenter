
# This will create the workflow to deploy the architechture like described in the README.
# This will be in respect to the dependencys the different Services need.


# 1. Create a new Resource Group
$resourceGroupName = Read-Host  "Enter The Name for the Resource Group"
$location = Read-Host "Enter The Region for the Resource Group"                  

# Create a new resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location
Write-Host "Resource group '$resourceGroupName' created successfully."

#2. Create a Key Vault and store two things: application_id (client_id), redirect_Uri, scope

$keyVaultName = Read-Host  "Enter The Name for the Key Vault"
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location $location
$applicationClient = Read-Host  "Please enter you're client_id (apllicationID) your rigistered in Entra ID"
$redirectURI = Read-Host  "Please enter the redirect URI from Entra Application"
$scope = Read-Host  "Please Enter the scope you need for the Authenticaton API"
$objectID = Read-Host "Please enter the objectID (Service Pricipal for the Application). This Will be used to grant the application access to the Key Vault"
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "applicationClient" -SecretValue $applicationClient
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "redirectURI" -SecretValue $redirectURI
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "scope" -SecretValue $scope
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "objectID" -SecretValue $objectID

# Grant application access using the objectID
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $objectID -PermissionsToSecrets Get,Set

Write-Host "Key Vault successfully created and secrets stored in Key Vault, Permisseion for Application granted"


#3 deploy the storage account to Resource Group
$storageAccountName = Read-Host "Enter the storage account name"
New-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName -SkuName Standard_LRS -Location $location -Kind StorageV2 -AccessTier Hot
Write-Host "We have created the Storage account '$storageAccountName' the next step will be to save the connection string in the Key Vault"
# Get storage account key
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccountName)[0].Value
# Build connection string
$connectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$storageAccountKey;EndpointSuffix=core.windows.net"
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "storageconnection" -SecretValue $connectionString

#4. Deploy Logical SQL Server and SQL database
$SQLAdmin = Read-Host "Please Provide SQL Admin Name"
$SQLPasswort = Read-Host "Please Provide SQL Passwort"
$serverName = Read-Host "Provide ServerName. Servername must be unique"
$databaseName = Read-Host "Provide a warehouse name for the database."



# Create a server with a system wide unique server name
$server = New-AzSqlServer -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SQLAdmin, $(ConvertTo-SecureString -String $SQLPasswort -AsPlainText -Force))

# Create a server firewall rule that allows access from the specified IP range
#$serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
  #  -ServerName $serverName `
  #  -FirewallRuleName "AllowedIPs" -StartIpAddress $startIp -EndIpAddress $endIp

# Create a blank database with an S0 performance level
$database = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName "S0" `
    -SampleName "AdventureWorksLT"




