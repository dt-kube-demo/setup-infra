#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

export GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
export GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
export REGISTRY_URL=$(cat creds.json | jq -r '.registry')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
export DT_TENANT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')

echo "----------------------------------------------------"
echo "Deploying Jenkins ..."
rm -f ./manifests/gen/k8s-jenkins-deployment.yml

mkdir -p ./manifests/gen

case $DEPLOYMENT in
  ocp)
    cat ./manifests/jenkins/ocp-jenkins-deployment.yml | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORGANIZATION_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
      sed 's~DOCKER_REGISTRY_IP_PLACEHOLDER~'"$REGISTRY_URL"'~' | \
      sed 's~DT_TENANT_URL_PLACEHOLDER~'"$DT_TENANT_HOSTNAME"'~' | \
      sed 's~DT_API_TOKEN_PLACEHOLDER~'"$DT_API_TOKEN"'~' >> ./manifests/gen/ocp-jenkins-deployment.yml
    oc create -f ./manifest/jenkins/ocp-jenkins-pvcs.yml
    oc create -f ./manifests/gen/ocp-jenkins-deployment.yml
    oc create -f ./manifests/jenkins/ocp-jenkins-rbac.yml
    ;;
  *)
    cat ./manifests/jenkins/k8s-jenkins-deployment.yml | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORGANIZATION_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
      sed 's~DOCKER_REGISTRY_IP_PLACEHOLDER~'"$REGISTRY_URL"'~' | \
      sed 's~DT_TENANT_URL_PLACEHOLDER~'"$DT_TENANT_HOSTNAME"'~' | \
      sed 's~DT_API_TOKEN_PLACEHOLDER~'"$DT_API_TOKEN"'~' >> ./manifests/gen/k8s-jenkins-deployment.yml
    kubectl create -f ./manifests/jenkins/k8s-jenkins-pvcs.yml 
    kubectl create -f ./manifests/gen/k8s-jenkins-deployment.yml
    kubectl create -f ./manifests/jenkins/k8s-jenkins-rbac.yml
    ;;
esac

echo "----------------------------------------------------"
echo "Letting Jenkins start up [150 seconds] ..."
echo "----------------------------------------------------"
echo ""
sleep 150

# configure DNS.
./configureJenkinsDns.sh
