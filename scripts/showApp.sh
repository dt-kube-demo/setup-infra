#!/bin/bash

export STAGING_URL=$(kubectl -n staging get svc front-end -o json | jq -r '.status.loadBalancer.ingress[0].hostname')
export PRODUCTION_URL=$(kubectl -n production get svc front-end -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

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