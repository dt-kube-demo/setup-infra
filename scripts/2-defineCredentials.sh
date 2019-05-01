#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/2-defineCredentials.log)
exec 2>&1

YLW='\033[1;33m'
NC='\033[0m'

CREDS=./creds.json

if [ -f "$CREDS" ]
then
    export DT_TENANT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')
    export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
    export DT_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')
    export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
    export GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
    export GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
    export GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
fi

clear
echo "==================================================================="
echo -e "${YLW}Please enter the values as requested below: ${NC}"
echo "==================================================================="
read -p "Dynatrace Tenant ID (e.g. abc12345.live.dynatrace.com) (current: $DT_TENANT_HOSTNAME) : " DT_TENANT_HOSTNAME_NEW
read -p "Dynatrace API Token                                    (current: $DT_API_TOKEN) : " DT_API_TOKEN_NEW
read -p "Dynatrace PaaS Token                                   (current: $DT_PAAS_TOKEN) : " DT_PAAS_TOKEN_NEW
read -p "GitHub User Name                                       (current: $GITHUB_USER_NAME) : " GITHUB_USER_NAME_NEW
read -p "GitHub Personal Access Token                           (current: $GITHUB_PERSONAL_ACCESS_TOKEN) : " GITHUB_PERSONAL_ACCESS_TOKEN_NEW
read -p "GitHub User Email                                      (current: $GITHUB_USER_EMAIL) : " GITHUB_USER_EMAIL_NEW
read -p "GitHub Organization                                    (current: $GITHUB_ORGANIZATION) : " GITHUB_ORGANIZATION_NEW
echo "==================================================================="
echo ""
# set value to new input or default to current value
DT_TENANT_HOSTNAME=${DT_TENANT_HOSTNAME_NEW:-$DT_TENANT_HOSTNAME}
DT_API_TOKEN=${DT_API_TOKEN_NEW:-$DT_API_TOKEN}
DT_PAAS_TOKEN=${DT_PAAS_TOKEN_NEW:-$DT_PAAS_TOKEN}
GITHUB_USER_NAME=${GITHUB_USER_NAME_NEW:-$GITHUB_USER_NAME}
GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_PERSONAL_ACCESS_TOKEN_NEW:-$GITHUB_PERSONAL_ACCESS_TOKEN}
GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL_NEW:-$GITHUB_USER_EMAIL}
GITHUB_ORGANIZATION=${GITHUB_ORGANIZATION_NEW:-$GITHUB_ORGANIZATION}

echo -e "${YLW}Please confirm all are correct: ${NC}"
echo "Dynatrace Tenant: $DT_TENANT_HOSTNAME"
echo "Dynatrace API Token: $DT_API_TOKEN"
echo "Dynatrace PaaS Token: $DT_PAAS_TOKEN"
echo "GitHub User Name: $GITHUB_USER_NAME"
echo "GitHub Personal Access Token: $GITHUB_PERSONAL_ACCESS_TOKEN"
echo "GitHub User Email: $GITHUB_USER_EMAIL"
echo "GitHub Organization: $GITHUB_ORGANIZATION" 
read -p "Is this all correct? (y/n) : " -n 1 -r
echo ""
echo "==================================================================="

if [[ $REPLY =~ ^[Yy]$ ]]
then
    cp $CREDS $CREDS.bak 2> /dev/null
    rm $CREDS 2> /dev/null
    cat ./creds.sav | sed 's~DT_TENANT_HOSTNAME_PLACEHOLDER~'"$DT_TENANT_HOSTNAME"'~' | \
      sed 's~DYNATRACE_API_TOKEN~'"$DT_API_TOKEN"'~' | \
      sed 's~DYNATRACE_PAAS_TOKEN~'"$DT_PAAS_TOKEN"'~' | \
      sed 's~GITHUB_USER_NAME_PLACEHOLDER~'"$GITHUB_USER_NAME"'~' | \
      sed 's~PERSONAL_ACCESS_TOKEN_PLACEHOLDER~'"$GITHUB_PERSONAL_ACCESS_TOKEN"'~' | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' >> $CREDS

    echo ""
    echo "The credentials file can be found here:" $CREDS
    echo ""
fi
