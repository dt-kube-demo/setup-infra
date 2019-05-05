#!/bin/bash
# reference: https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/configuration/management-zones-api/

export DT_TENANT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')

echo "----------------------------------------------------"
echo "Apply auto tagging rules in Dynatrace ..."
echo DT_TENANT_HOSTNAME = $DT_TENANT_HOSTNAME
echo DT_API_TOKEN = $DT_API_TOKEN
echo "----------------------------------------------------"

export DT_ZONE_NAME=dt-kube-demo-staging
echo "-----------------------------------------------------------------------------------"
echo "Processing $DT_ZONE_NAME ..."
echo "-----------------------------------------------------------------------------------"
echo "----------------------------------------------------"
echo "Checking if $DT_ZONE_NAME exists ..."
echo "----------------------------------------------------"
export DT_ID=
export DT_ID=$(curl -X GET \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/managementZones?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  | jq -r '.values[] | select(.name == "'$DT_ZONE_NAME'") | .id')

# if exists, then delete it
if [ "$DT_ID" != "" ]
then
  echo "----------------------------------------------------"
  echo "Deleting $DT_ZONE_NAME since exists ..."
  echo "----------------------------------------------------"
  curl -X DELETE \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/managementZones/$DT_ID?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache'
fi

echo "----------------------------------------------------"
echo "Adding $DT_ZONE_NAME ..."
echo "----------------------------------------------------"
curl -X POST \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/managementZones?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
  "name": "'$DT_ZONE_NAME'",
  "rules": [{
		"type": "SERVICE",
		"enabled": true, 
		"propagationTypes": [],
		"conditions": [{
			"key": {
				"attribute": "SERVICE_TAGS"
			},
			"comparisonInfo": {
				"type": "TAG",
				"operator": "EQUALS",
				"value": {
					"context": "CONTEXTLESS",
					"key": "dt-kube-demo-environment",
					"value": "staging"
				},
				"negate": false
			}
		}]
	}]
}'

echo ""

export DT_ZONE_NAME=dt-kube-demo-production
echo "-----------------------------------------------------------------------------------"
echo "Processing $DT_ZONE_NAME ..."
echo "-----------------------------------------------------------------------------------"
echo "----------------------------------------------------"
echo "Checking if $DT_ZONE_NAME exists ..."
echo "----------------------------------------------------"
export DT_ID=
export DT_ID=$(curl -X GET \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/managementZones?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  | jq -r '.values[] | select(.name == "'$DT_ZONE_NAME'") | .id')

# if exists, then delete it
if [ "$DT_ID" != "" ]
then
  echo "----------------------------------------------------"
  echo "Deleting $DT_ZONE_NAME since exists ..."
  echo "----------------------------------------------------"
  curl -X DELETE \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/managementZones/$DT_ID?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache'
fi

echo "----------------------------------------------------"
echo "Adding $DT_ZONE_NAME ..."
echo "----------------------------------------------------"
curl -X POST \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/managementZones?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{
  "name": "'$DT_ZONE_NAME'",
  "rules": [{
		"type": "SERVICE",
		"enabled": true, 
		"propagationTypes": [],
		"conditions": [{
			"key": {
				"attribute": "SERVICE_TAGS"
			},
			"comparisonInfo": {
				"type": "TAG",
				"operator": "EQUALS",
				"value": {
					"context": "CONTEXTLESS",
					"key": "dt-kube-demo-environment",
					"value": "production"
				},
				"negate": false
			}
		}]
	}]
}'

echo ""


