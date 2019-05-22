#!/bin/bash

clear
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

./1-installPrerequisiteTools.sh $DEPLOYMENT  2>&1 | tee logs/1-installPrerequisiteTools.log
#read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./2-enterInstallationScriptInputs.sh $DEPLOYMENT 2>&1 | tee logs/2-enterInstallationScriptInputs.log
#read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./3-provisionInfrastructure.sh $DEPLOYMENT  2>&1 | tee logs/3-provisionInfrastructure.log
#read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./4-setupDemo.sh $DEPLOYMENT 2>&1 | tee logs/4-setupDemo.log
#read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./5-forkApplicationRepositories.sh  2>&1 | tee logs/5-forkApplicationRepositories.log
