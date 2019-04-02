#!/bin/bash

# load in the shared library and validate argument
. ./deploymentArgument.lib
export DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/2-defineCredentials.log)
exec 2>&1

YLW='\033[1;33m'
NC='\033[0m'

CREDS=./creds.json

if [ -f "$CREDS" ]
then
    export DT_TENANT_ID=$(cat creds.json | jq -r '.dynatraceTenant')
    export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
    export DT_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')
    export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
    export GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
    export GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
    export GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
    export AZURE_SUBSCRIPTION=$(cat creds.json | jq -r '.azureSubscription')
    export AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
    export AZURE_OWNER_NAME=$(cat creds.json | jq -r '.azureOwnerName')
fi

clear
echo "==================================================================="
echo -e "${YLW}Please enter the values as requested below: ${NC}"
echo "==================================================================="
read -p "Dynatrace Tenant ID (8-digits) (current: $DT_TENANT_ID) : " DT_TENANT_ID_NEW
read -p "Dynatrace API Token            (current: $DT_API_TOKEN) : " DT_API_TOKEN_NEW
read -p "Dynatrace PaaS Token           (current: $DT_PAAS_TOKEN) : " DT_PAAS_TOKEN_NEW
read -p "GitHub User Name               (current: $GITHUB_USER_NAME) : " GITHUB_USER_NAME_NEW
read -p "GitHub Personal Access Token   (current: $GITHUB_PERSONAL_ACCESS_TOKEN) : " GITHUB_PERSONAL_ACCESS_TOKEN_NEW
read -p "GitHub User Email              (current: $GITHUB_USER_EMAIL) : " GITHUB_USER_EMAIL_NEW
read -p "GitHub Organization            (current: $GITHUB_ORGANIZATION) : " GITHUB_ORGANIZATION_NEW
if [ $DEPLOYMENT == aks ]; then
  read -p "Azure Subscription             (current: $AZURE_SUBSCRIPTION) : " AZURE_SUBSCRIPTION_NEW
  read -p "Azure Location                 (current: $AZURE_LOCATION) : " AZURE_LOCATION_NEW
  read -p "Azure Owner Name               (current: $AZURE_OWNER_NAME) : " AZURE_OWNER_NAME_NEW
fi
echo "==================================================================="
echo ""
# set value to new input or default to current value
DT_TENANT_ID=${DT_TENANT_ID_NEW:-$DT_TENANT_ID}
DT_API_TOKEN=${DT_API_TOKEN_NEW:-$DT_API_TOKEN}
DT_PAAS_TOKEN=${DT_PAAS_TOKEN_NEW:-$DT_PAAS_TOKEN}
GITHUB_USER_NAME=${GITHUB_USER_NAME_NEW:-$GITHUB_USER_NAME}
GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_PERSONAL_ACCESS_TOKEN_NEW:-$GITHUB_PERSONAL_ACCESS_TOKEN}
GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL_NEW:-$GITHUB_USER_EMAIL}
GITHUB_ORGANIZATION=${GITHUB_ORGANIZATION_NEW:-$GITHUB_ORGANIZATION}
AZURE_SUBSCRIPTION=${AZURE_SUBSCRIPTION_NEW:-$AZURE_SUBSCRIPTION}
AZURE_LOCATION=${AZURE_LOCATION_NEW:-$AZURE_LOCATION}
AZURE_OWNER_NAME=${AZURE_OWNER_NAME_NEW:-$AZURE_OWNER_NAME}

echo -e "${YLW}Please confirm all are correct: ${NC}"
echo "Dynatrace Tenant            : $DT_TENANT_ID"
echo "Dynatrace API Token         : $DT_API_TOKEN"
echo "Dynatrace PaaS Token        : $DT_PAAS_TOKEN"
echo "GitHub User Name            : $GITHUB_USER_NAME"
echo "GitHub Personal Access Token: $GITHUB_PERSONAL_ACCESS_TOKEN"
echo "GitHub User Email           : $GITHUB_USER_EMAIL"
echo "GitHub Organization         : $GITHUB_ORGANIZATION" 
if [ $DEPLOYMENT == aks ]; then
  echo "Azure Subscription       : $AZURE_SUBSCRIPTION"
  echo "Azure Location           : $AZURE_LOCATION"
  echo "Azure Owner Name         : $AZURE_OWNER_NAME"
fi
read -p "Is this all correct? (y/n) : " -n 1 -r
echo ""
echo "==================================================================="

if [[ $REPLY =~ ^[Yy]$ ]]
then
    cp $CREDS $CREDS.bak 2> /dev/null
    rm $CREDS 2> /dev/null
    cat ./creds.sav | sed 's~DYNATRACE_TENANT_PLACEHOLDER~'"$DT_TENANT_ID"'~' | \
      sed 's~DYNATRACE_API_TOKEN~'"$DT_API_TOKEN"'~' | \
      sed 's~DYNATRACE_PAAS_TOKEN~'"$DT_PAAS_TOKEN"'~' | \
      sed 's~GITHUB_USER_NAME_PLACEHOLDER~'"$GITHUB_USER_NAME"'~' | \
      sed 's~PERSONAL_ACCESS_TOKEN_PLACEHOLDER~'"$GITHUB_PERSONAL_ACCESS_TOKEN"'~' | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' >> $CREDS
      if [ $DEPLOYMENT == aks ]; then
        sed 's~AZURE_SUBSCRIPTION_PLACEHOLDER~'"$AZURE_SUBSCRIPTION"'~' >> $CREDS
        sed 's~AZURE_LOCATION_PLACEHOLDER~'"$AZURE_LOCATION"'~' >> $CREDS
        sed 's~AZURE_OWNER_NAME_PLACEHOLDER~'"$AZURE_OWNER_NAME"'~' >> $CREDS
      fi
    echo ""
    echo "The credentials file can be found here:" $CREDS
    echo ""
fi