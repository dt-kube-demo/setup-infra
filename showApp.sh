#!/bin/bash

STAGING_URL=$(kubectl -n staging get svc front-end -o json | jq -r '.status.loadBalancer.ingress[0].hostname')
PRODUCTION_URL=$(kubectl -n production get svc front-end -o json | jq -r '.status.loadBalancer.ingress[0].hostname')
DEPLOYMENT=$(cat creds.json | jq -r '.deployment')

if [ $DEPLOYMENT == "aks" ]
then 
  AZURE_RESOURCE_PREFIX=$(cat creds.json | jq -r '.azureResourcePrefix')
  AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
  PRODUCTION_URL="http://production-$AZURE_RESOURCE_PREFIX-dt-kube-demo.$AZURE_LOCATION.cloudapp.azure.com"
    PRODUCTION_URL="http://production-$AZURE_RESOURCE_PREFIX-dt-kube-demo.$AZURE_LOCATION.cloudapp.azure.com"

fi

echo "--------------------------------------------------------------------------"
echo "Staging    : http://$STAGING_URL"
echo "Production : http://$PRODUCTION_URL"
echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "Kubernetes Staging pods"
kubectl get pods -n staging
echo "--------------------------------------------------------------------------"
echo "Kubernetes Production pods"
kubectl get pods -n production