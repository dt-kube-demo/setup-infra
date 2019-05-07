#!/bin/bash

clear

if [ -z $1 ]; then
  DEPLOYMENT=eks
fi

# once support multiple providers, then add this back
# load in the shared library and validate argument
#source ./deploymentArgument.lib
#DEPLOYMENT=$1
#validate_deployment_argument $DEPLOYMENT

show_menu(){
echo ""
echo "===================================================="
echo "SETUP MENU for $DEPLOYMENT"
echo "===================================================="
echo "1)  Install Prerequisites Tools"
echo "2)  Enter Installation Script Inputs"
echo "3)  Provision Kubernetes cluster"
echo "4)  Setup Demo Services"
echo "5)  Fork Application Repositories"
echo "----------------------------------------------------"
echo "10)  Validate Kubectl"
echo "11)  Validate Prerequisite Tools"
echo "----------------------------------------------------"
echo "99) Delete Kubernetes cluster"
echo "===================================================="
echo "Please enter your choice or <q> or <return> to exit"
read opt
}

show_menu
while [ opt != "" ]
    do
    if [[ $opt = "" ]]; then 
        exit;
    else
        clear
        case $opt in
        1)
                ./1-installPrerequisiteTools.sh $DEPLOYMENT  2>&1 | tee logs/1-installPrerequisiteTools.log
                break
                ;;
        2)
                ./2-enterInstallationScriptInputs.sh $DEPLOYMENT 2>&1 | tee logs/2-enterInstallationScriptInputs.log
                break
                ;;
        3)
                ./3-provisionInfrastructure.sh $DEPLOYMENT  2>&1 | tee logs/3-provisionInfrastructure.log
                break
                ;;
        4)
                ./4-setupDemo.sh $DEPLOYMENT 2>&1 | tee logs/4-setupDemo.log
                break
                ;;
        5)
                GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
                ./5-forkApplicationRepositories.sh $GITHUB_ORGANIZATION 2>&1 | tee logs/5-forkApplicationRepositories.log
                break
                ;;
        10)
                ./validateKubectl.sh  2>&1 | tee logs/validateKubectl.log
                break
                ;;
        11)
                ./validatePrerequisiteTools.sh $DEPLOYMENT 2>&1 | tee logs/validatePrerequisiteTools.log
                break
                ;;
        99)
                ./deleteInfrastructure.sh $DEPLOYMENT 2>&1 | tee logs/deleteInfrastructure.log
                break
                ;;
        q)
           	break
           	;;
        *) 
            	echo "invalid option"
            	show_menu
            	;;
    esac
fi
done
