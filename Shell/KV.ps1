#2. Create a Key Vault and store two things: application_id (client_id), redirect_Uri, scope

$location = "west europe"
$resourceGroupName = "consumptionsolution"

$keyVaultName = Read-Host  "Enter The Name for the Key Vault"
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location $location
$applicationClient = Read-Host  "Please enter you're client_id (apllicationID) your rigistered in Entra ID"
$redirectURI = Read-Host  "Please enter the redirect URI from Entra Application"
$scope = Read-Host  "Please Enter the scope you need for the Authenticaton API"
$tenantID = Read-Host "Please enter Tenant ID"
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "applicationClient" -SecretValue $applicationClient
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "redirectURI" -SecretValue $redirectURI
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "scope" -SecretValue $scope
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "tenantID" -SecretValue $tenantID
