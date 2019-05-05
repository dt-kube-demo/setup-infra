#!/bin/bash

export JENKINS_POD=$(kubectl get pods -n cicd -o=json | jq -r .items[].metadata.name)
export JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
export JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')

case $1 in
  all)
    echo "updating all installed plugins on $JENKINS_POD - still working on this one"
#    kubectl -n cicd exec -it $JENKINS_POD -- sh -c "updates=$(java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth $JENKINS_USER:$JENKINS_PASSWORD list-plugins | grep -e ')$' | awk '{ print $1 }') && java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth $JENKINS_USER:$JENKINS_PASSWORD install-plugin ${updates} && java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth $JENKINS_USER:$JENKINS_PASSWORD safe-restart"
    ;;
  just-perfsig)
    echo "just updating perfsig plugins on $JENKINS_POD"
    kubectl -n cicd exec -it $JENKINS_POD -- sh -c "java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth $JENKINS_USER:$JENKINS_PASSWORD install-plugin performance-signature-dynatracesaas performance-signature-ui performance-signature-viewer && java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth $JENKINS_USER:$JENKINS_PASSWORD safe-restart"
    ;;
  *)
    echo "nothing will be updated"
esac
