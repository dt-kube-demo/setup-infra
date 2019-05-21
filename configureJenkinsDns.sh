#!/bin/bash

DEPLOYMENT=$(cat creds.json | jq -r '.deployment')

case $DEPLOYMENT in
  aks)
    AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
		AZURE_RESOURCE_GROUP=$(cat creds.json | jq -r '.azureResourcePrefix')-dt-kube-demo-group
		AZURE_RESOURCE_CLUSTER=$(cat creds.json | jq -r '.azureResourcePrefix')-dt-kube-demo-cluster
		DNS_NAME="$(cat creds.json | jq -r '.azureResourcePrefix')"-dt-kube-demo

		# format: MC_jahn-dt-kube-demo-group_jahn-dt-kube-demo-cluster_eastus
		CLUSTER_RESOURCE_GROUP=MC_"$AZURE_RESOURCE_GROUP"_"$AZURE_RESOURCE_CLUSTER"_"$AZURE_LOCATION" 

    echo "----------------------------------------------------"
    echo "Setting up Jenkins DNS"
    echo "----------------------------------------------------"
    echo ""
    NAMESPACE=cicd
    SERVICE=jenkins
    APP_IP_ADDRESS=$(kubectl get service $SERVICE -n $NAMESPACE --output=json | jq .status.loadBalancer.ingress[0].ip)
    APP_RESOURCE_GROUP_ID=$(az network public-ip list -g $CLUSTER_RESOURCE_GROUP | jq -r ".[] | select(.ipAddress==$APP_IP_ADDRESS) | .id")
    echo "Assign service: $SERVICE ($APP_IP_ADDRESS) to DNS: $SERVICE-$DNS_NAME"
    echo "APP_RESOURCE_GROUP_ID: $APP_RESOURCE_GROUP_ID"

    ADD_DNS_RESULT=$(az network public-ip update --dns-name $SERVICE-$DNS_NAME --ids $APP_RESOURCE_GROUP_ID)
    FQDN=$(echo $ADD_DNS_RESULT | jq -r .dnsSettings.fqdn)
    echo "Service is reachable at $FQDN"
    echo ""
    ;;
  *)
    echo "Skipping DNS setup for Jenkins"
esac
