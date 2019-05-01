#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/4-setupInfrastructure.log)
exec 2>&1
clear

# Validate Deployment argument
if [ -z $1 ]
then
  echo ""
  echo "============================================="
  echo "Missing 'deployment type' argument."
  echo "Usage:"
  echo "./0-InstallTools.sh <deployment type>"
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
  echo "./4-setupInfrastructure.sh <deployment type>"
  echo "valid deployment types are: ocp eks gcp aks"
  echo "====================================="   
  echo ""
  exit 1
fi

# validate that have utlities installed first
./validatePrerequisites.sh $DEPLOYMENT
if [ $? -ne 0 ]
then
  exit 1
fi

# validate that have dynatrace configured properly
./validateDynatrace.sh
if [ $? -ne 0 ]
then
  exit 1
fi

# validate that have kubectl configured first
./validateKubectl.sh
if [ $? -ne 0 ]
then
  exit 1
fi

echo " "
echo "===================================================="
echo About to setup demo app infrastructure with these parameters:
cat creds.json | grep -E "jenkins|dynatrace|github"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key

export START_TIME=$(date)
export GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')

echo "----------------------------------------------------"
echo "Creating K8s namespaces ..."
kubectl create -f ../manifests/namespaces.yml 

echo "----------------------------------------------------"
echo "Setting up Jenkins  ..."
./setupJenkins.sh $DEPLOYMENT

echo "----------------------------------------------------"
echo "Updating Jenkins PerfSig plugins ..."
./upgradeJenkinsPlugins.sh just-perfsig

echo "----------------------------------------------------"
echo "Letting Jenkins restart [60 seconds] ..."
sleep 60

# add credentials
./createJenkinsCredentials.sh

# add Jenkins pipelines
./importJenkinsPipelines.sh $GITHUB_ORGANIZATION

# add Dynatrace Operator
./setupDynatrace.sh $DEPLOYMENT

# add Dynatrace Tagging rules
./applyAutoTaggingRules.sh
echo "----------------------------------------------------"
echo "Letting Dynatrace tagging rules be applied [150 seconds] ..."
sleep 150

#echo "----------------------------------------------------"
#echo "Deploying Istio ..."
#./setupIstio.sh $DT_TENANT_HOSTNAME $DT_PAAS_TOKEN

echo "===================================================="
echo "Finished setting up demo app infrastructure "
echo "===================================================="
echo "Script start time : "$START_TIME
echo "Script end time   : "$(date)

echo ""
echo ""
./showJenkins.sh 