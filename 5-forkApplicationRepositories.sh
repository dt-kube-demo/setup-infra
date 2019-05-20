#!/bin/bash

SOURCE_GIT_ORG=dt-kube-demo

type hub &> /dev/null
if [ $? -ne 0 ]
then
    echo "Please install the 'hub' command: https://hub.github.com/"
    exit 1
fi

if [ -z $1 ]
then
    echo "Please provide the target GitHub organization as parameter:"
    echo ""
    echo "  e.g.: ./forkGitHubRepositories.sh myorganization"
    echo ""
    exit 1
else
    ORG=$1
fi

HTTP_RESPONSE=`curl -s -o /dev/null -I -w "%{http_code}" https://github.com/$ORG`

if [ $HTTP_RESPONSE -ne 200 ]
then
    echo "GitHub organization doesn't exist - https://github.com/$ORG - HTTP status code $HTTP_RESPONSE"
    exit 1
fi

echo "===================================================="
echo About to fork github repositories with these parameters:
echo ""
echo "Source : https://github.com/$SOURCE_GIT_ORG"
echo "Target : https://github.com/$ORG"
echo ""
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key

echo ""

declare -a repositories=("catalog-service" "customer-service" "front-end" "order-service" "deploy")

rm -rf ../repositories
mkdir ../repositories
cd ../repositories

for repo in "${repositories[@]}"
do
    echo -e "Cloning https://github.com/$SOURCE_GIT_ORG/$repo"
    git clone -q "https://github.com/$SOURCE_GIT_ORG/$repo"
    cd $repo
    echo -e "Forking $repo to $ORG"
    hub fork --org=$ORG
    cd ..
    echo -e "Done."
done

cd ..
rm -rf repositories
mkdir repositories
cd repositories

for repo in "${repositories[@]}"
do
    TARGET_REPO="http://github.com/$ORG/$repo"
    echo -e "Cloning $TARGET_REPO"
    git clone -q $TARGET_REPO
    echo -e "Done."
done

echo ""