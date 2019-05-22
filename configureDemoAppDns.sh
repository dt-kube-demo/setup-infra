#!/bin/bash

# values read in from creds file
DEPLOYMENT=$(cat creds.json | jq -r '.deployment')
RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
# derived values
CLUSTER_NAME="$RESOURCE_PREFIX"-dt-kube-demo-cluster

case $DEPLOYMENT in
  aks)
		AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
		AZURE_RESOURCE_GROUP=$(cat creds.json | jq -r '.resourcePrefix')-dt-kube-demo-group
		DNS_NAME="$(cat creds.json | jq -r '.resourcePrefix')"-dt-kube-demo

		# format: MC_jahn-dt-kube-demo-group_jahn-dt-kube-demo-cluster_eastus
		CLUSTER_RESOURCE_GROUP=MC_"$AZURE_RESOURCE_GROUP"_"$CLUSTER_NAME"_"$AZURE_LOCATION" 

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
		;;
  *)
    echo "Skipping setup for $DEPLOYMENT"
esac
