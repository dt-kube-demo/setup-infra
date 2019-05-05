#!/bin/bash

export JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
export JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')
export JENKINS_URL=$(kubectl get service jenkins -n cicd -o=json | jq -r .status.loadBalancer.ingress[].hostname)
export JENKINS_URL_PORT=$(kubectl get service jenkins -n cicd -o=json | jq -r '.spec.ports[] | select(.name=="http") | .port')
echo ""
echo "--------------------------------------------------------------------------"
echo "Jenkins is running @"
echo "$JENKINS_URL"
echo "Admin user           : $JENKINS_USER"
echo "Admin password       : $JENKINS_PASSWORD"
echo ""
echo "NOTE: Credentials are from values in creds.json file "
echo "Password may not be accurate if you adjusted it in Jenkins UI"
echo "--------------------------------------------------------------------------"
echo ""