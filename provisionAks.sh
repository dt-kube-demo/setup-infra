#!/bin/bash

# values read in from creds file
AZURE_SUBSCRIPTION=$(cat creds.json | jq -r '.azureSubscription')
AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
AZURE_RESOURCE_PREFIX=$(cat creds.json | jq -r '.azureResourcePrefix')
# derived values
AZURE_RESOURCEGROUP="$AZURE_RESOURCE_PREFIX-dt-kube-demo-group"
AZURE_CLUSTER="$AZURE_RESOURCE_PREFIX-dt-kube-demo-cluster"
AZURE_DEPLOYMENTNAME="$AZURE_RESOURCE_PREFIX-dt-kube-demo-deployment"
AZURE_SERVICE_PRINCIPAL="$AZURE_RESOURCE_PREFIX-dt-kube-demo-sp"

echo "===================================================="
echo "About to provision Azure Resources with these inputs: "
echo "The provisioning will take several minutes"
echo ""
echo "AZURE_SUBSCRIPTION      : $AZURE_SUBSCRIPTION"
echo "AZURE_LOCATION          : $AZURE_LOCATION"
echo "AZURE_RESOURCEGROUP     : $AZURE_RESOURCEGROUP"
echo "AZURE_CLUSTER           : $AZURE_CLUSTER"
echo "AZURE_DEPLOYMENTNAME    : $AZURE_DEPLOYMENTNAME"
echo "AZURE_SERVICE_PRINCIPAL : $AZURE_SERVICE_PRINCIPAL"
echo "===================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
echo ""

echo "------------------------------------------------------"
echo "Creating Resource group: $AZURE_RESOURCEGROUP"
echo "------------------------------------------------------"
az account set -s $AZURE_SUBSCRIPTION
az group create --name "$AZURE_RESOURCEGROUP" --location $AZURE_LOCATION
az group list -o table

# need to look up service principal id and then delete it
# this is outside of the resource group
AZURE_SERVICE_PRINCIPAL_APPID=$(az ad sp list --display-name $AZURE_SERVICE_PRINCIPAL | jq -r '.[0].appId | select (.!=null)')
if [ -n "$AZURE_SERVICE_PRINCIPAL_APPID" ]
then
    echo "------------------------------------------------------"
    echo "Deleting Service Principal     : $AZURE_SERVICE_PRINCIPAL"
    echo "AZURE_SERVICE_PRINCIPAL_APPID  : $AZURE_SERVICE_PRINCIPAL_APPID"
    echo "------------------------------------------------------"
    az ad sp delete --id $AZURE_SERVICE_PRINCIPAL_APPID
fi

echo "------------------------------------------------------"
echo "Creating Service Principal: $AZURE_SERVICE_PRINCIPAL"
echo "------------------------------------------------------"
az ad sp create-for-rbac -n "http://$AZURE_SERVICE_PRINCIPAL" \
    --role contributor \
    --scopes /subscriptions/"$AZURE_SUBSCRIPTION"/resourceGroups/"$AZURE_RESOURCEGROUP" > ./aks/azure_service_principal.json
AZURE_APPID=$(jq -r .appId ./aks/azure_service_principal.json)
AZURE_APPID_SECRET=$(jq -r .password ./aks/azure_service_principal.json)

echo "Letting service principal persist properly (30 sec) ..."
sleep 30 
echo "Generated Serice Principal App ID: $AZURE_APPID"
 
# prepare cluster parameters file values
jq -n \
    --arg owner "$AZURE_RESOURCE_PREFIX" \
    --arg name "$AZURE_CLUSTER" \
    --arg location "$AZURE_LOCATION" \
    --arg dns "$AZURE_LOCATION-dns" \
    --arg agentvmsize "Standard_D4s_v3" \
    --arg appid "$AZURE_APPID" \
    --arg appidsecret "$AZURE_APPID_SECRET" \
    --arg kubernetesversion "1.12.7" \ '{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "resourceName": {
            "value": $name
        },
        "owner": {
            "value": $owner
        },
        "location": {
            "value": $location
        },
        "dnsPrefix": {
            "value": $dns
        },
        "agentCount": {
            "value": 1
        },
        "agentVMSize": {
            "value": $agentvmsize
        },
        "servicePrincipalClientId": {
            "value": $appid
        },
        "servicePrincipalClientSecret": {
            "value": $appidsecret
        },
        "kubernetesVersion": {
            "value": $kubernetesversion
        },
        "networkPlugin": {
            "value": "kubenet"
        },
        "enableRBAC": {
            "value": true
        },
        "enableHttpApplicationRouting": {
            "value": false
        }
    }
}' > ./aks/parameters.json

echo "------------------------------------------------------"
echo "About to create cluster with these parameters."
cat ./aks/parameters.json
echo 
echo "AZURE_APPID=$AZURE_APPID"
echo "AZURE_APPID_SECRET=$AZURE_APPID_SECRET"
echo "------------------------------------------------------"
echo "Create Cluster will take several minutes"

read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
echo ""

cd aks
./deploy.sh -i $AZURE_SUBSCRIPTION -g $AZURE_RESOURCEGROUP -n $AZURE_DEPLOYMENTNAME -l $AZURE_LOCATION
cd ..

echo "------------------------------------------------------"
echo "Configuring Azure DNS"
echo "------------------------------------------------------"
echo ""
./configureAzureDns.sh

echo "Updated Kubectl with credentials"
az aks get-credentials --resource-group $AZURE_RESOURCEGROUP --name $AZURE_CLUSTER --overwrite-existing

echo "------------------------------------------------------"
echo "Azure cluster deployment complete."
echo "------------------------------------------------------"
echo ""