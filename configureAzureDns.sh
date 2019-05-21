#!/bin/bash

AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
AZURE_RESOURCE_GROUP=$(cat creds.json | jq -r '.azureResourcePrefix')-dt-kube-demo-group
AZURE_RESOURCE_CLUSTER=$(cat creds.json | jq -r '.azureResourcePrefix')-dt-kube-demo-cluster
DNS_NAME="$(cat creds.json | jq -r '.azureResourcePrefix')"-dt-kube-demo

# format: MC_jahn-dt-kube-demo-group_jahn-dt-kube-demo-cluster_eastus
CLUSTER_RESOURCE_GROUP=MC_"$AZURE_RESOURCE_GROUP"_"$AZURE_RESOURCE_CLUSTER"_"$AZURE_LOCATION" 

echo "================================================================"
echo "Updating DNS entrys for CLUSTER_RESOURCE_GROUP:"
echo "$CLUSTER_RESOURCE_GROUP"
echo "================================================================"

for NAMESPACE in staging production
do
	for SERVICE in front-end
	do
		APP_IP_ADDRESS=$(kubectl get service $SERVICE -n $NAMESPACE --output=json | jq .status.loadBalancer.ingress[0].ip)
		APP_RESOURCE_GROUP_ID=$(az network public-ip list -g $CLUSTER_RESOURCE_GROUP | jq -r ".[] | select(.ipAddress==$APP_IP_ADDRESS) | .id")
		echo "Assign service: $SERVICE ($APP_IP_ADDRESS) to DNS: $NAMESPACE-$DNS_NAME"
		echo "APP_RESOURCE_GROUP_ID: $APP_RESOURCE_GROUP_ID"

		ADD_DNS_RESULT=$(az network public-ip update --dns-name $NAMESPACE-$DNS_NAME --ids $APP_RESOURCE_GROUP_ID)
		FQDN=$(echo $ADD_DNS_RESULT | jq -r .dnsSettings.fqdn)
		echo "Service is reachable at $FQDN"
		echo ""
	done
done

for NAMESPACE in cicd
do
	for SERVICE in jenkins
	do
		APP_IP_ADDRESS=$(kubectl get service $SERVICE -n $NAMESPACE --output=json | jq .status.loadBalancer.ingress[0].ip)
		APP_RESOURCE_GROUP_ID=$(az network public-ip list -g $CLUSTER_RESOURCE_GROUP | jq -r ".[] | select(.ipAddress==$APP_IP_ADDRESS) | .id")
		echo "Assign service: $SERVICE ($APP_IP_ADDRESS) to DNS: $SERVICE-$DNS_NAME"
		echo "APP_RESOURCE_GROUP_ID: $APP_RESOURCE_GROUP_ID"

		ADD_DNS_RESULT=$(az network public-ip update --dns-name $SERVICE-$DNS_NAME --ids $APP_RESOURCE_GROUP_ID)
		FQDN=$(echo $ADD_DNS_RESULT | jq -r .dnsSettings.fqdn)
		echo "Service is reachable at $FQDN"
q		echo ""
	done
done