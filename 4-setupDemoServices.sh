#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

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

echo "===================================================="
echo "Finished setting up demo app infrastructure "
echo "===================================================="
echo "Script start time : "$START_TIME
echo "Script end time   : "$(date)

echo ""
echo ""
./showJenkins.sh 