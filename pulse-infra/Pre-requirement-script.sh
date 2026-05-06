#to create storage account for terraform state file
# az group create --name pulse-rg --location centralindia

az storage account create \
    --name pulsesa \
    --resource-group pulse-rg \
    --location centralindia\
    --sku Standard_LRS \
    --kind StorageV2 
