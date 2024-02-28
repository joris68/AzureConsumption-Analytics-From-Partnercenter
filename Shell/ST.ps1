#3 deploy the storage account to


$storageAccountName = Read-Host -Prompt "Enter the storage account name"
New-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName -SkuName Standard_LRS -Location $location -Kind StorageV2 -AccessTier Hot

Write-Host "We have created the Storage account '$storageAccountName' the next step will be to save the connection string in the Key Vault"

# Get storage account key
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccountName)[0].Value

# Build connection string
$connectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$storageAccountKey;EndpointSuffix=core.windows.net"

Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "storageconnection" -SecretValue $connectionString