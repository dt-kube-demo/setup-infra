#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/setupIstio.log)
exec 2>&1

DT_TENANT_HOSTNAME=$1
DT_PAAS_TOKEN=$2

kubectl apply -f ../manifests/istio/crds.yml
kubectl apply -f ../manifests/istio/istio-demo.yml

sleep 500

kubectl label namespace production istio-injection=enabled

kubectl create -f ../manifests/istio/istio-gateway.yml

./createIstionServiceEntry.sh $DT_TENANT_HOSTNAME $DT_PAAS_TOKEN