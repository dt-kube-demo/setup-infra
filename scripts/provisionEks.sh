#!/bin/bash

CLUSTER_NAME=$(cat creds.json | jq -r '.clusterName')
CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')

echo "===================================================="
echo "About to provision AWS Resources. "
echo "The provisioning will take several minutes"
echo "Cluster Name         : $CLUSTER_NAME"
echo "Cluster Region       : $CLUSTER_REGION"
echo "===================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
echo ""

echo "------------------------------------------------------"
echo "Creating AKS Cluster: $CLUSTER_NAME"
echo "------------------------------------------------------"
eksctl create cluster --name=$CLUSTER_NAME --node-type=m5.2xlarge --nodes=1 --region=$CLUSTER_REGION
eksctl utils update-coredns --name=$CLUSTER_NAME --region=$CLUSTER_REGION

echo "------------------------------------------------------"
echo "Getting Cluster Credentials"
echo "------------------------------------------------------"
az aks get-credentials --resource-group myResourceGroup --name $CLUSTER_NAME
