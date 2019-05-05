#!/bin/bash

export JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
export JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')
export GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
export JENKINS_URL=$(kubectl get service jenkins -n cicd -o=json | jq -r .status.loadBalancer.ingress[].hostname)
export JENKINS_URL_PORT=$(kubectl get service jenkins -n cicd -o=json | jq -r '.spec.ports[] | select(.name=="http") | .port')


export CRED_NAME=registry-creds
echo "-----------------------------------------------------------------------------------"
echo "Creating Credential '$CRED_NAME' within Jenkins ..."
echo "-----------------------------------------------------------------------------------"
echo "----------------------------------------------------"
echo "Checking if $CRED_NAME exists ..."
echo "----------------------------------------------------"
export CRED_URL="http://$JENKINS_URL:$JENKINS_URL_PORT/credentials/store/system/domain/_/credential/$CRED_NAME/config.xml"
if [ "$(curl -sL -w '%{http_code}' $CRED_URL -o /dev/null)" == "200" ]
then
  echo "----------------------------------------------------"
  echo "Deleting $CRED_NAME since exists ..."
  echo "----------------------------------------------------"
  curl -X POST http://$JENKINS_URL:$JENKINS_URL_PORT/credentials/store/system/domain/_/credential/$CRED_NAME/doDelete \
  --user $JENKINS_USER:$JENKINS_PASSWORD
fi

echo "----------------------------------------------------"
echo "Adding $CRED_NAME ..."
echo "----------------------------------------------------"
curl -X POST http://$JENKINS_URL:$JENKINS_URL_PORT/credentials/store/system/domain/_/createCredentials \
--user $JENKINS_USER:$JENKINS_PASSWORD \
--data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "'$CRED_NAME'",
    "username": "'$REGISTRY_USER'",
    "password": "'$REGISTRY_TOKEN'",
    "description": "Token used by Jenkins to push to the container registry",
    "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }
}'

export CRED_NAME=git-credentials-acm
echo "-----------------------------------------------------------------------------------"
echo "Creating Credential '$CRED_NAME' within Jenkins ..."
echo "-----------------------------------------------------------------------------------"
echo "----------------------------------------------------"
echo "Checking if $CRED_NAME exists ..."
echo "----------------------------------------------------"
export CRED_URL="http://$JENKINS_URL:$JENKINS_URL_PORT/credentials/store/system/domain/_/credential/$CRED_NAME/config.xml"
if [ "$(curl -sL -w '%{http_code}' $CRED_URL -o /dev/null)" == "200" ]
then
  echo "----------------------------------------------------"
  echo "Deleting $CRED_NAME since exists ..."
  echo "----------------------------------------------------"
  curl -X POST http://$JENKINS_URL:$JENKINS_URL_PORT/credentials/store/system/domain/_/credential/$CRED_NAME/doDelete \
  --user $JENKINS_USER:$JENKINS_PASSWORD
fi

echo "----------------------------------------------------"
echo "Adding $CRED_NAME ..."
echo "----------------------------------------------------"
echo "Creating Credential 'git-credentials-acm' within Jenkins ..."
curl -X POST http://$JENKINS_URL:$JENKINS_URL_PORT/credentials/store/system/domain/_/createCredentials --user $JENKINS_USER:$JENKINS_PASSWORD \
--data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "'$CRED_NAME'",
    "username": "'$GITHUB_USER_NAME'",
    "password": "'$GITHUB_PERSONAL_ACCESS_TOKEN'",
    "description": "Token used by Jenkins to access the GitHub repositories",
    "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
  }
}'

export CRED_NAME=perfsig-api-token
echo "-----------------------------------------------------------------------------------"
echo "Creating Credential '$CRED_NAME' within Jenkins ..."
echo "-----------------------------------------------------------------------------------"
echo "----------------------------------------------------"
echo "Checking if $CRED_NAME exists ..."
echo "----------------------------------------------------"
export CRED_URL="http://$JENKINS_URL:$JENKINS_URL_PORT/credentials/store/system/domain/_/credential/$CRED_NAME/config.xml"
if [ "$(curl -sL -w '%{http_code}' $CRED_URL -o /dev/null)" == "200" ]
then
  echo "----------------------------------------------------"
  echo "Deleting $CRED_NAME since exists ..."
  echo "----------------------------------------------------"
  curl -X POST http://$JENKINS_URL:$JENKINS_URL_PORT/credentials/store/system/domain/_/credential/$CRED_NAME/doDelete \
  --user $JENKINS_USER:$JENKINS_PASSWORD
fi

echo "----------------------------------------------------"
echo "Adding $CRED_NAME ..."
echo "----------------------------------------------------"
echo "Creating Credential 'perfsig-api-token' within Jenkins ..."
curl -X POST http://$JENKINS_URL:$JENKINS_URL_PORT/credentials/store/system/domain/_/createCredentials --user $JENKINS_USER:$JENKINS_PASSWORD \
--data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "'$CRED_NAME'",
    "apiToken": "'$DT_API_TOKEN'",
    "description": "Dynatrace API Token used by the Performance Signature plugin",
    "$class": "de.tsystems.mms.apm.performancesignature.dynatracesaas.model.DynatraceApiTokenImpl"
  }
}'

echo ""