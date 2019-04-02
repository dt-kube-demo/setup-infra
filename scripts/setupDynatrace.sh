#!/bin/bash

# load in the shared library and validate argument
. ./deploymentArgument.lib
export DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/setupDynatrace.log)
exec 2>&1

YLW='\033[1;33m'
NC='\033[0m'

export DT_TENANT_ID=$(cat creds.json | jq -r '.dynatraceTenant')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
export DT_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')

# using fixed versus 'latest' version 
export DT_LATEST_RELEASE='v0.3.0'

echo "----------------------------------------------------"
echo "Installing Dynatrace OneAgent Operator version : $DT_LATEST_RELEASE"
echo ""

echo "----------------------------------------------------"
echo "Installing Dynatrace Operator $DT_LATEST_RELEASE ..."
case $DEPLOYMENT in
  ocp)
    kubectl create -f https://raw.githubusercontent.com/Dynatrace/dynatrace-oneagent-operator/$DT_LATEST_RELEASE/deploy/openshift.yaml
    oc annotate namespace dynatrace openshift.io/node-selector=""
    ;;
  *)
    kubectl create -f https://raw.githubusercontent.com/Dynatrace/dynatrace-oneagent-operator/$DT_LATEST_RELEASE/deploy/kubernetes.yaml
    ;;
esac
echo ""

echo "----------------------------------------------------"
echo "Letting Dynatrace OneAgent operator start up [60 seconds] ..."
sleep 60

echo "----------------------------------------------------"
echo "Deploying Dynatrace OneAgent pods ..."
kubectl -n dynatrace create secret generic oneagent --from-literal="apiToken=$DT_API_TOKEN" --from-literal="paasToken=$DT_PAAS_TOKEN"

if [ -f ../manifests/gen/cr.yml ]; then
  rm -f ../manifests/gen/cr.yml
fi

mkdir -p ../manifests/gen/dynatrace
curl -o ../manifests/gen/dynatrace/cr.yml https://raw.githubusercontent.com/Dynatrace/dynatrace-oneagent-operator/$DT_LATEST_RELEASE/deploy/cr.yaml
cat ../manifests/gen/dynatrace/cr.yml | sed 's/ENVIRONMENTID/'"$DT_TENANT_ID"'/' >> ../manifests/gen/cr.yml

kubectl create -f ../manifests/gen/cr.yml