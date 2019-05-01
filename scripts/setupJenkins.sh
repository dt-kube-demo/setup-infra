LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/setupJenkins.log)
exec 2>&1

YLW='\033[1;33m'
NC='\033[0m'

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
  echo "./setupJenkins.sh <deployment type>"
  echo "valid deployment types are: ocp eks gcp aks"
  echo "====================================="   
  echo ""
  exit 1
fi

export GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
export GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
export REGISTRY_URL=$(cat creds.json | jq -r '.registry')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
export DT_TENANT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')


echo "----------------------------------------------------"
echo "Deploying Jenkins ..."
rm -f ../manifests/gen/k8s-jenkins-deployment.yml

mkdir -p ../manifests/gen

if [ $DEPLOYMENT == ocp ]; then
  cat ../manifests/jenkins/ocp-jenkins-deployment.yml | \
    sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
    sed 's~GITHUB_ORGANIZATION_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
    sed 's~DOCKER_REGISTRY_IP_PLACEHOLDER~'"$REGISTRY_URL"'~' | \
    sed 's~DT_TENANT_URL_PLACEHOLDER~'"$DT_TENANT_HOSTNAME"'~' | \
    sed 's~DT_API_TOKEN_PLACEHOLDER~'"$DT_API_TOKEN"'~' >> ../manifests/gen/ocp-jenkins-deployment.yml
  oc create -f ../manifest/jenkins/ocp-jenkins-pvcs.yml
  oc create -f ../manifests/gen/ocp-jenkins-deployment.yml
  oc create -f ../manifests/jenkins/ocp-jenkins-rbac.yml
else
  cat ../manifests/jenkins/k8s-jenkins-deployment.yml | \
    sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
    sed 's~GITHUB_ORGANIZATION_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
    sed 's~DOCKER_REGISTRY_IP_PLACEHOLDER~'"$REGISTRY_URL"'~' | \
    sed 's~DT_TENANT_URL_PLACEHOLDER~'"$DT_TENANT_HOSTNAME"'~' | \
    sed 's~DT_API_TOKEN_PLACEHOLDER~'"$DT_API_TOKEN"'~' >> ../manifests/gen/k8s-jenkins-deployment.yml
  kubectl create -f ../manifests/jenkins/k8s-jenkins-pvcs.yml 
  kubectl create -f ../manifests/gen/k8s-jenkins-deployment.yml
  kubectl create -f ../manifests/jenkins/k8s-jenkins-rbac.yml
fi

echo "----------------------------------------------------"
echo "Letting Jenkins start up [150 seconds] ..."
sleep 150

echo ""
