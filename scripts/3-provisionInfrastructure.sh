#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/3-provisionInfrastructure.log)
exec 2>&1

clear
# Validate Deployment argument
if [ -z $1 ]
then
  echo ""
  echo "============================================="
  echo "Missing 'deployment type' argument."
  echo "Usage:"
  echo "./3-provisionInfrastructure.sh <deployment type>"
  echo "valid deployment types are: ocp eks gcp aks"
  echo "=============================================" 
  echo ""
  exit 1
fi

export DEPLOYMENT=$1
OK=0 ; DEPLOY_TYPES="ocp eks gcp aks"
for DT in $DEPLOY_TYPES ; do [ $1 == $DT ] && { OK=1 ; break; } ; done
if [ $OK -eq 0 ]; then
  echo ""
  echo "====================================="
  echo "Missing 'deployment type' argument."
  echo "Usage:"
  echo "./3-provisionInfrastructure.sh <deployment type>"
  echo "valid deployment types are: ocp eks gcp aks"
  echo "====================================="   
  echo ""
  exit 1
fi

case $DEPLOYMENT in
  eks)
    # AWS   
    echo "===================================================="
    echo "About to provision AWS Resources"
    echo ""
    echo Terraform will evalate the plan then prompt for confirmation
    echo at the prompt, enter 'yes'
    echo The provisioning will take several minutes
    read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key
    export START_TIME=$(date)

    cd ../eks_terraform
    terraform init
    terraform apply
    echo ""
    echo "===================================================="
    echo "Copying generated terraform file into kubectl config"
    cp kubeconfig-*-cluster.yaml ~/.kube/config
    ;;
  aks)
    # Azure 
    echo "===================================================="
    echo "About to provision Azure Resources"
    echo ""
    echo The provisioning will take several minutes
    read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key
    export START_TIME=$(date)
    cd ../aks_arm
    ./createAksCluster.sh
    ;;
  ocp)
    # Open Shift
    echo "Deploy for $DEPLOYMENT not supported"
    exit 1
    ;;
  gcp)
    # Google
    echo "Deploy for $DEPLOYMENT not supported"
    exit 1
    ;;
esac

echo "===================================================="
echo "Finished provisioning $DEPLOYMENT Resources"
echo "===================================================="
echo "Script start time : "$START_TIME
echo "Script end time   : "$(date)

# validate that have kubectl configured first
cd ../scripts
./validateKubectl.sh
if [ $? -ne 0 ]
then
  exit 1
fi