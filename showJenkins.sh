#!/bin/bash

DEPLOYMENT=$(cat creds.json | jq -r '.deployment')
JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')
JENKINS_PORT=$(kubectl get service jenkins -n cicd -o=json | jq -r '.spec.ports[] | select(.name=="http") | .port' )
JENKINS_URL=$(kubectl get service jenkins -n cicd -o=json | jq -r '.status.loadBalancer.ingress[].hostname | select (.!=null)')
if [ -n "JENKINS_URL" ]
then
  JENKINS_URL="http://$(kubectl get service jenkins -n cicd -o=json | jq -r '.status.loadBalancer.ingress[].ip')"
fi

if [ $DEPLOYMENT == "aks" ]
then 
  RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
  AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
  JENKINS_URL="http://jenkins-$RESOURCE_PREFIX-dt-kube-demo.$AZURE_LOCATION.cloudapp.azure.com"
fi

echo "--------------------------------------------------------------------------"
echo "kubectl -n cicd get pods"
echo "--------------------------------------------------------------------------"
kubectl -n cicd get pods
echo ""
echo "--------------------------------------------------------------------------"
echo "Jenkins is running @"
echo "$JENKINS_URL:$JENKINS_PORT"
echo "Admin user           : $JENKINS_USER"
echo "Admin password       : $JENKINS_PASSWORD"
echo ""
echo "NOTE: Credentials are from values in creds.json file "
echo "Password may not be accurate if you adjusted it in Jenkins UI"
echo "--------------------------------------------------------------------------"
echo ""
