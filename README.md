# Overview

This repos has the code and scripts to provision and configure a cloud infrastructure running Kubernetes and the required CI/CD components to build, deploy and host a micro service based order processing demo application.

<img src="images/orders.png" width="300"/>

Once monitored by Dynatrace, a multi-tier call flow will be available.

<img src="images/dt-call-flow.png" width="500"/>

Footnotes:
* Currently, these setup scripts support only Amazon EKS.  The plan is to then support Azure, RedHat, and Cloud Foundry PaaS platforms.
* Uses a docker registry run within the cluster
* Demo app based on example from: https://github.com/ewolff/microservice-kubernetes

# Pre-requisites

## 1. Accounts

1. Dynatrace - Assumes you will use a trial SaaS dynatrace tenant from https://www.dynatrace.com/trial and create a PaaS and API token
1. GitHub - Assumes you have a github account and have created a new github organization
1. Cloud provider account.  Highly recommend to sign up for personal free trial as to have full admin rights and to not cause any issues with your enterprise account. Links to free trials
   * AWS - https://aws.amazon.com/free/
   * Azure - https://azure.microsoft.com/en-us/free/

## 2. Tools

The following set of tools are required by the installation scripts and interacting with the environment.

All platforms
* helm - [Package manager for Kubernetes](https://helm.sh/)
* jq - [Json query utility to suport parsing](https://stedolan.github.io/jq/)
* yq - [Yaml query utility to suport parsing](https://github.com/mikefarah/yq)
* hub - [git utility to support command line forking](https://github.com/github/hub)
* kubectl - [CLI to manage the cluster](https://kubernetes.io/docs/tasks/tools/install-kubectl). This is required for all, but will use the installation instructions per each cloud provider

AWS additional tools
* aws - [CLI for AWS](https://aws.amazon.com/cli/)
* ekscli - [CLI for Amazon EKS](https://eksctl.io/)
* aws-iam-authenticator - [Provides authentication kubectl to the eks cluster](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

Azure additional tools
* az - [CLI for Azure](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)

# Bastion host setup

See these instructions for provisioning an ubuntu 16.04 LTS host on the targeted cloud provider.
* [AWS EC2 instance](AWS.md) 
* [Azure VM instance](AZURE.md) 

# Provision Cluster and onboard the Orders application

There are multiple scripts used for the setup and they must be run the right order.  Just run the setup script that will prompt you with menu choices.
```
./setup.sh <deployment type>
```
NOTE: Valid 'deployment type' argument values are:
* eks = AWS
* aks = Azure

NOTE: The ```setup.sh``` script will set your 'deployment type' selection into creds.json file so that you don't have to keep typing it in each time.

The setup menu should look like this:
```
====================================================
SETUP MENU
====================================================
1)  Install Prerequisites Tools
2)  Enter Installation Script Inputs
3)  Provision Kubernetes cluster
4)  Setup Demo Services
5)  Fork Application Repositories
----------------------------------------------------
10)  Validate Kubectl
11)  Validate Prerequisite Tools
----------------------------------------------------
99) Delete Kubernetes cluster
====================================================
Please enter your choice or <q> or <return> to exit

```

NOTE: each script will log the console output into the ```logs/``` subfolder.

## 1) Install Prerequisites Tools

This will install the required unix tools such as kubectl, jq, cloud provider CLI.

At the end if the installation, the Sscript will call the 'Validate Prerequisite Tools' script that will verify tools setup setup.  

You can re-run both 'Install Prerequisites Tools' or 'Validate Prerequisite Tools' anytime as required.

## 2) Enter Installation Script Inputs

Before you do this step, be prepared with your github credentials, dynatrace tokens, and cloud provider project information available.

This will prompt you for values that are referenced in the remaining setup scripts. Inputted values are stored in ```creds.json``` file.  

## 3) Provision Kubernetes cluster

This will provision a Cluster on the specified cloud deployment type. This script will take several minutes to run and you can verify the cluster was created with the the cloud provider console.

This script at the end will run the 'Validate Kubectl' script.  

## 4) Setup Demo Services

This script will:
* created staging & production namespaces for the orders app
* install jenkins in the cicd namespaces and setup credentials, environment variables and configure the t-systems performance signature plug-in
* install the Kubernetes Dynatrace Operator
* setup autotagging rules in Dynatrace
* import Jenkins jobs for deploying the application

## 5) Fork Order application repositories

This is an optional step.  You would need to do this if you plan to build the docker images from source.

This script will fork the orders application into the github organization you specified when you called 'Enter Installation Script Inputs' step.

Internally, this script will:
1. delete and created a local respositories/ folder
1. clone the orders application repositories
1. use the ```hub``` unix git utility to fork each repositories
1. push each repository to your personal github organization

# Other setup related scripts

These are additional scripts available in the 'setup.sh' menu.

## 10)  Validate Kubectl

This script will attempt to 'get pods' using kubectl. 

## 11)  Validate Prerequisite Tools

This script will look for the existence of required prerequisite tools.  It does NOT check for version just the existence of the script. 

## 99) Remove Kubernetes cluster

Fastest way to remove everything is to delete your cluster using this script.  Becare when you run this as to not lose your work.

NOTE: ekscli will report that the delete is done, but review the AWS console too. It seems it takes longer for the eks cluster and the cloudformation script that ekscli creates to actaully be deleted.

# Helpful scripts

These scripts are helpful when using and reviewing status of your environment.  Just run the helper script that will prompt you with menu choices.
```
./helper.sh
```

The helper menu should look like this:
```
====================================================
HELPER MENU
====================================================
1) show App
2) show Jenkins
3) show Dyntrace
====================================================
Please enter your choice or <q> or <return> to exit

```

NOTE: each script will log the console output into the ```logs/``` subfolder.

## 1) Show app

Displays the deployed orders application pods and urls

## 2) show Jenkins

Displays the jenkins pods

## 3) Show Dyntrace

Displays the URL to the running Jenkins server


# Deploying the application

Just run the 'deploy-staging' or 'deploy-production' Jenkins job.  You can verify the application is deployed by running the 'show app' helper script which will show you pod status and the application URL.