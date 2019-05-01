#!/bin/bash

# reference: https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/configuration/auto-tag-api/

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/applyAutoTaggingRules.log)
exec 2>&1


export DT_TENANT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')

echo "----------------------------------------------------"
echo "Setting up auto tagging rules in your Dynatrace tenant."
echo DT_TENANT_HOSTNAME = $DT_TENANT_HOSTNAME
echo DT_API_TOKEN = $DT_API_TOKEN

export DT_RULE_NAME=dt-kube-demo-service
echo "-----------------------------------------------------------------------------------"
echo "Processing $DT_RULE_NAME ..."
echo "-----------------------------------------------------------------------------------"
echo "----------------------------------------------------"
echo "Checking if $DT_RULE_NAME exists ..."
echo "----------------------------------------------------"
export DT_ID=
export DT_ID=$(curl -X GET \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  | jq -r '.values[] | select(.name == "'$DT_RULE_NAME'") | .id')

# if exists, then delete it
if [ "$DT_ID" != "" ]
then
  echo "----------------------------------------------------"
  echo "Deleting $DT_RULE_NAME since exists (ID = $DT_ID) ..."
  echo "----------------------------------------------------"
  curl -X DELETE \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags/$DT_ID?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache'
fi

echo "----------------------------------------------------"
echo "Adding $DT_RULE_NAME ..."
echo "----------------------------------------------------"
curl -X POST \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
    "name": "'$DT_RULE_NAME'",
    "rules": [
        {
            "type": "SERVICE",
            "enabled": true,
            "valueFormat": "{ProcessGroup:KubernetesContainerName}",
            "propagationTypes": [],
            "conditions": [
                {
                    "key": {
                        "attribute": "PROCESS_GROUP_PREDEFINED_METADATA",
                        "dynamicKey": "KUBERNETES_CONTAINER_NAME",
                        "type": "PROCESS_PREDEFINED_METADATA_KEY"
                    },
                    "comparisonInfo": {
                        "type": "STRING",
                        "operator": "EXISTS",
                        "value": null,
                        "negate": false,
                        "caseSensitive": null
                    }
                }
            ]
        }
    ]
}'

echo ""
export DT_RULE_NAME=dt-kube-demo-environment
echo "-----------------------------------------------------------------------------------"
echo "Processing $DT_RULE_NAME ..."
echo "-----------------------------------------------------------------------------------"
echo "----------------------------------------------------"
echo "Checking if $DT_RULE_NAME exists ..."
echo "----------------------------------------------------"
export DT_ID=
export DT_ID=$(curl -X GET \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  | jq -r '.values[] | select(.name == "'$DT_RULE_NAME'") | .id')

# if exists, then delete it
if [ "$DT_ID" != "" ]
then
  echo "----------------------------------------------------"
  echo "Deleting $DT_RULE_NAME since exists (ID = $DT_ID) ..."
  echo "----------------------------------------------------"
  curl -X DELETE \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags/$DT_ID?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache'
fi

echo "----------------------------------------------------"
echo "Adding $DT_RULE_NAME ..."
echo "----------------------------------------------------"
curl -X POST \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
	"name": "'$DT_RULE_NAME'",
  "rules": [
    {
      "type": "SERVICE",
      "enabled": true,
      "valueFormat": "{ProcessGroup:KubernetesNamespace}",
      "propagationTypes": [],
      "conditions": [
        {
          "key": {
            "attribute": "PROCESS_GROUP_PREDEFINED_METADATA",
            "dynamicKey": "KUBERNETES_NAMESPACE",
            "type": "PROCESS_PREDEFINED_METADATA_KEY"
          },
          "comparisonInfo": {
            "type": "STRING",
            "operator": "EXISTS",
            "value": null,
            "negate": false,
            "caseSensitive": null
          }
        }
      ]
    }
  ]
  }'
  
echo ""
