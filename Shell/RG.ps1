# 1. Create a new Resource Group
$resourceGroupName = Read-Host "Enter The Name for the Resource Group"
$location = Read-Host "Enter The Region for the Resource Group"                  

# Create a new resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location
Write-Host "Resource group '$resourceGroupName' created successfully."