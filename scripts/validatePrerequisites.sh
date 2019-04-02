#!/bin/bash

# load in the shared library and validate argument
. ./deploymentArgument.lib
export DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/validatePrerequisites.log)
exec 2>&1

echo "=============================================================================="
echo "Validating Common pre-requisites"
echo "=============================================================================="
echo -n "Validating jq utility				"
type jq &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'jq' json query utility"
    echo ""
    exit 1
fi
echo "ok	$(command -v jq)"

echo -n "Validating hub utility				"
type hub &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing git 'hub' utility"
    echo ""
    exit 1
fi
echo "ok	$(command -v hub)"

echo -n "Validating kubectl				"
type kubectl &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'kubectl'"
    echo ""
    exit 1
fi
echo "ok	$(command -v kubectl)"

# openshift tools
echo ""
if [ $DEPLOYMENT == ocp ]; then
  echo "-----------------------------------------------------------------"
  echo "Validating OCP pre-requisites"
  echo "-----------------------------------------------------------------"
  echo -n "Validating oc				"
  type oc &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'oc'"
    echo ""
    exit 1
  fi
  echo "ok	$(command -v oc)"
fi

# AWS tools
if [ $DEPLOYMENT == eks ]; then
  echo "-----------------------------------------------------------------"
  echo "Validating EKS pre-requisites"
  echo "-----------------------------------------------------------------"
  echo -n "Validating AWS cli				"
  type aws &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'aws CLI'"
    echo ""
    exit 1
  fi
  echo "ok	$(command -v aws)"

  echo -n "Validating terraform				"
  type terraform &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'terraform'"
    echo ""
    exit 1
  fi
  echo "ok	$(command -v terraform)"

  echo -n "Validating aws-iam-authenticator utility	"
  type aws-iam-authenticator &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'aws-iam-authenticator'"
    echo ""
    exit 1
  fi
  echo "ok	$(command -v aws-iam-authenticator)"

  echo -n "Validating AWS cli is configured		"
  export AWS_STS_USER=$(aws sts get-caller-identity | jq -r '.UserId')
  if [ -z $AWS_STS_USER ]; then
    echo ">>> Unable to locate credentials. You can configure credentials by running \"aws configure\"."
    echo ""
    exit 1
  fi
  echo "ok	AWS cli is configured with UserId: $AWS_STS_USER"
fi

# Azure tools
if [ $DEPLOYMENT == aks ]; then
  echo "-----------------------------------------------------------------"
  echo "Validating Azure pre-requisites"
  echo "-----------------------------------------------------------------"
  echo -n "Validating az		         		"
  type az &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'az'"
    echo ""
    exit 1
  fi
  echo "ok      $(az --version | head -n 1)"
fi

echo "=============================================================================="
echo "Validation of pre-requisites complete"
echo "=============================================================================="
