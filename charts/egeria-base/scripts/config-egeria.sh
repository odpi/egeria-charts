#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

# Script will be run by k8s as part of our initialization job.
# Assumed here - platform up & responding to REST api, plus Kafka is available

# Note - expect to port this to python, aligned with our notebook configuration
# - this will facilitate error handling (vs very verbose scripting). Groovy an alternative
# Initial a version a script to get the basics working

# exit when any command fails
set -e

# Creates the post data for the event bus according to kafka security (KAFKA_SECURITY_ENABLED)
generatePostData() {
  if [ "${KAFKA_SECURITY_ENABLED}" = "true" ]; then
    cat << EOF
{
  "producer": {
    "bootstrap.servers": "${KAFKA_ENDPOINT}",
    "security.protocol": "${KAFKA_SECURITY_PROTOCOL}",
    "ssl.keystore.location": "${KAFKA_SECURITY_KEYSTORE_LOCATION}",
    "ssl.keystore.password": "${KAFKA_SECURITY_KEYSTORE_PASSWORD}",
    "ssl.truststore.location": "${KAFKA_SECURITY_TRUSTSTORE_LOCATION}",
    "ssl.truststore.password": "${KAFKA_SECURITY_TRUSTSTORE_PASSWORD}"
  }, 
  "consumer": {
    "bootstrap.servers": "${KAFKA_ENDPOINT}",
    "security.protocol": "${KAFKA_SECURITY_PROTOCOL}",
    "ssl.keystore.location": "${KAFKA_SECURITY_KEYSTORE_LOCATION}",
    "ssl.keystore.password": "${KAFKA_SECURITY_KEYSTORE_PASSWORD}",
    "ssl.truststore.location": "${KAFKA_SECURITY_TRUSTSTORE_LOCATION}",
    "ssl.truststore.password": "${KAFKA_SECURITY_TRUSTSTORE_PASSWORD}"
  } 
}
EOF
  else
    cat << EOF
{
  "producer": {
    "bootstrap.servers": "${KAFKA_ENDPOINT}"
  },
  "consumer": {
    "bootstrap.servers": "${KAFKA_ENDPOINT}"
  }
}
EOF
  fi
}

printf -- "-- Needed environment variables from egeria-base --\n"
printf "EGERIA_ENDPOINT=%s\n" "${EGERIA_ENDPOINT}"
printf "EGERIA_USER=%s\n" "${EGERIA_USER}"
printf "EGERIA_SERVER=%s\n" "${EGERIA_SERVER}"
printf "BASE_TOPIC_NAME=%s\n" "${BASE_TOPIC_NAME}"
printf "EGERIA_COHORT=%s\n" "${EGERIA_COHORT}"
printf "VIEW_SERVER=%s\n" "${VIEW_SERVER}"
printf "STARTUP_CONFIGMAP=%s\n" "${STARTUP_CONFIGMAP}"
printf "POSTCONFIG_STARTUP_SERVER_LIST=%s\n" "${POSTCONFIG_STARTUP_SERVER_LIST}"
printf "KAFKA_ENDPOINT=%s\n" "${KAFKA_ENDPOINT}"
if [ "${KAFKA_SECURITY_ENABLED}" = "true" ]; then
  printf "KAFKA_SECURITY_PROTOCOL=%s\n" "${KAFKA_SECURITY_PROTOCOL}"
  printf "KAFKA_SECURITY_KEYSTORE_LOCATION=%s\n" "${KAFKA_SECURITY_KEYSTORE_LOCATION}"
  printf "KAFKA_SECURITY_KEYSTORE_PASSWORD=%s\n" "${KAFKA_SECURITY_KEYSTORE_PASSWORD}"
  printf "KAFKA_SECURITY_TRUSTSTORE_LOCATION=%s\n" "${KAFKA_SECURITY_TRUSTSTORE_LOCATION}"
  printf "KAFKA_SECURITY_TRUSTSTORE_PASSWORD=%s\n" "${KAFKA_SECURITY_TRUSTSTORE_PASSWORD}"
fi
printf -- "-- End of Needed environment variables --\n\n"

printf -- "-- Configuring platform with required servers\n"


# Set the URL root
printf "\n\n > Setting server URL root:\n"
RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/server-url-root?url=${EGERIA_ENDPOINT}" | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Setting server URL root successful.\n"
  unset RC
else
	printf "\n\nSetting the URL root failed.\n"
	exit 1
fi

# Setup the event bus
printf "\n\n > Setting up event bus:\n"
RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/event-bus?topicURLRoot=${BASE_TOPIC_NAME}" \
  --data "$(generatePostData)" | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Setting up event bus successful.\n"
  unset RC
else
	printf "\n\nSetting up event bus failed.\n"
	exit 1
fi

# Enable all the access services (we will adjust this later)
printf "\n\n > Enabling all access services:\n"
RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/access-services?serviceMode=ENABLED" | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Enabling all access services successful.\n"
  unset RC
else
	printf "\n\nEnabling all access services failed.\n"
	exit 1
fi

# Use a local graph repo
printf "\n\n > Use a local graph repo:\n"
RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/local-repository/mode/local-graph-repository" | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Using local graph repo successful.\n"
  unset RC
else
	printf "\n\nUsing local graph repo failed.\n"
	exit 1
fi

# Configure the cohort membership
printf "\n\n > Configuring cohort membership:\n"
RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/cohorts/${EGERIA_COHORT}" | cut -d "}" -f2)
	
if [ "${RC}" -eq 200 ]; then
  printf "Configuring cohort membership successful.\n"
  unset RC
else
	printf "\n\nConfiguring cohort membership failed.\n"
	exit 1
fi

# Start up the server
printf "\n\n > Starting the server:\n"
RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST --max-time 900 \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/instance" | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Starting the server successful.\n"
  unset RC
else
	printf "\n\nStarting the server failed.\n"
	exit 1
fi

# --- Now the view server

# Set the URL root
printf "\n\n > Setting view server URL root:\n"
RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/server-url-root?url=${EGERIA_ENDPOINT}" | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Setting view server URL root successful.\n"
  unset RC
else
	printf "\n\nSetting view server URL root failed.\n"
	exit 1
fi

# Setup the event bus
printf "\n\n > Setting up event bus:\n"
RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/event-bus?topicURLRoot=${BASE_TOPIC_NAME}" \
  --data "$(generatePostData)" | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Setting up event bus successful.\n"
  unset RC
else
	printf "\n\nSetting up event bus failed.\n"
	exit 1
fi

# Set as view server
printf "\n\n > Set as view server:\n"
RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/server-type?typeName=View%20Server" | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Setting as view server successful.\n"
  unset RC
else
	printf "\n\nSetting as view server failed.\n"
	exit 1
fi

# Configure the view server cohort membership
printf "\n\n > Configuring cohort membership:\n"

RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/cohorts/${EGERIA_COHORT}" | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Configuring cohort membership successful.\n"
  unset RC
else
	printf "\n\nConfiguring cohort membership failed.\n"
	exit 1
fi

# Configure the view services
printf "\n\n > Setting up Glossary Author:\n"

RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/view-services/glossary-author" \
  --data @- << EOF | cut -d "}" -f2
{
  "class": "ViewServiceConfig",
  "omagserverPlatformRootURL": "${EGERIA_ENDPOINT}",
  "omagserverName" : "${EGERIA_SERVER}"
}
EOF

)

if [ "${RC}" -eq 200 ]; then
  printf "Setting up Glossary Author successful.\n"
  unset RC
else
	printf "\n\nSetting up Glossary Author failed.\n"
	exit 1
fi

# Setting up TEX
printf "\n\n > Setting up TEX:\n"

RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/view-services/tex" \
  --data @- << EOF | cut -d "}" -f2
{
  "class":"IntegrationViewServiceConfig",
  "viewServiceAdminClass":"org.odpi.openmetadata.viewservices.tex.admin.TexViewAdmin",
  "viewServiceFullName":"Type Explorer",
  "viewServiceOperationalStatus":"ENABLED",
  "omagserverPlatformRootURL": "UNUSED",
  "omagserverName" : "UNUSED",
  "resourceEndpoints" : [
    {
      "class"              : "ResourceEndpointConfig",
      "resourceCategory"   : "Platform",
      "description"        : "Platform",
      "platformName"       : "platform",
      "platformRootURL"    : "${EGERIA_ENDPOINT}"
    },
    {
      "class"              : "ResourceEndpointConfig",
      "resourceCategory"   : "Server",
      "serverInstanceName" : "${EGERIA_SERVER}",
      "description"        : "Server",
      "platformName"       : "platform",
      "serverName"         : "${EGERIA_SERVER}"
    }
  ]
}
EOF

)

if [ "${RC}" -eq 200 ]; then
  printf "Setting up TEX successful.\n"
  unset RC
else
	printf "\n\nSetting up TEX failed.\n"
	exit 1
fi

# Setting up REX
printf "\n\n > Setting up REX:\n"
RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/view-services/rex" \
  --data @- << EOF | cut -d "}" -f2
{
  "class":"IntegrationViewServiceConfig",
  "viewServiceAdminClass":"org.odpi.openmetadata.viewservices.rex.admin.RexViewAdmin",
  "viewServiceFullName":"Repository Explorer",
  "viewServiceOperationalStatus":"ENABLED",
  "omagserverPlatformRootURL": "UNUSED",
  "omagserverName" : "UNUSED",
  "resourceEndpoints" : [
    {
			"class"              : "ResourceEndpointConfig",
			"resourceCategory"   : "Platform",
			"description"        : "Platform",
			"platformName"       : "platform",
			"platformRootURL"    : "${EGERIA_ENDPOINT}"
    },
		{
			"class"              : "ResourceEndpointConfig",
			"resourceCategory"   : "Server",
			"serverInstanceName" : "${EGERIA_SERVER}",
			"description"        : "Server",
			"platformName"       : "platform",
			"serverName"         : "${EGERIA_SERVER}"
    }
  ]
}
EOF

)

if [ "${RC}" -eq 200 ]; then
  printf "Setting up REX successful.\n"
  unset RC
else
	printf "\n\nSetting up REX failed.\n"
	exit 1
fi

# Setting up DINO
printf "\n\n > Setting up DINO:\n"

RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/view-services/dino" \
  --data @- << EOF | cut -d "}" -f2
{
  "class":"IntegrationViewServiceConfig",
  "viewServiceAdminClass":"org.odpi.openmetadata.viewservices.dino.admin.DinoViewAdmin",
  "viewServiceFullName":"Dino",
  "viewServiceOperationalStatus":"ENABLED",
  "omagserverPlatformRootURL": "UNUSED",
  "omagserverName" : "UNUSED",
  "resourceEndpoints" : [
    {
			"class"              : "ResourceEndpointConfig",
			"resourceCategory"   : "Platform",
			"description"        : "Platform",
			"platformName"       : "platform",
			"platformRootURL"    : "${EGERIA_ENDPOINT}"
    },
    {
			"class"              : "ResourceEndpointConfig",
			"resourceCategory"   : "Server",
			"serverInstanceName" : "${EGERIA_SERVER}",
			"description"        : "Server",
			"platformName"       : "platform",
			"serverName"         : "${EGERIA_SERVER}"
    },
    {
			"class"              : "ResourceEndpointConfig",
			"resourceCategory"   : "Server",
			"serverInstanceName" : "${VIEW_SERVER}",
			"description"        : "Server",
			"platformName"       : "platform",
			"serverName"         : "${VIEW_SERVER}"
    }
  ]
}
EOF

)

if [ "${RC}" -eq 200 ]; then
  printf "Setting up DINO successful.\n"
  unset RC
else
	printf "\n\nSetting up DINO failed.\n"
	exit 1
fi

# Setting up Server Author
printf "\n\n > Setting up Server Author:\n"

RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/view-services/server-author" \
  --data @- << EOF | cut -d "}" -f2
{
	"class":"IntegrationViewServiceConfig",
	"viewServiceAdminClass":"org.odpi.openmetadata.viewservices.serverauthor.admin.ServerAuthorViewAdmin",
	"viewFullServiceName":"ServerAuthor",
	"viewServiceOperationalStatus":"ENABLED",
	"omagserverPlatformRootURL": "${EGERIA_ENDPOINT}",
	"resourceEndpoints" : [
		{
			"class"              : "ResourceEndpointConfig",
			"resourceCategory"   : "Platform",
			"description"        : "Platform",
			"platformName"       : "platform",
			"platformRootURL"    : "${EGERIA_ENDPOINT}"
		}
	]
}
EOF

)

if [ "${RC}" -eq 200 ]; then
  printf "Setting up Server Author successful.\n"
  unset RC
else
	printf "\n\nSetting up Server Author failed.\n"
	exit 1
fi

# Start up the view server
printf "\n\n > Starting the view server:\n"

RC=$(curl -k -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST --max-time 900 \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${VIEW_SERVER}/instance" | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Starting the view server successful.\n"
  unset RC
else
	printf "\n\nStarting the view server failed.\n"
	exit 1
fi

# Enabling autostart by updating the configmap
# This can only be done AFTER the server is correctly configured, otherwise it will prevent platform startup

printf "\n\n > Enabling auto-start for the configured servers\n"

token="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
namespace="$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)"
cacert=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

RC=$(curl -k -s -o /dev/null -w "%{http_code}" \
  -X PATCH \
  -d @- \
  -H "Authorization: Bearer $token" \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/strategic-merge-patch+json' \
  https://kubernetes.default.svc/api/v1/namespaces/$namespace/configmaps/$STARTUP_CONFIGMAP << EOF |cut -d "}" -f2
{
  "kind": "ConfigMap",
  "apiVersion": "v1",
  "data":
  {
    "STARTUP_SERVER_LIST": "$POSTCONFIG_STARTUP_SERVER_LIST"
  }
}
EOF

)

if [ "${RC}" -eq 200 ]; then
  printf "Enabling auto-start for the configured servers successful.\n"
  unset RC
else
	printf "\n\nEnabling auto-start for the configured servers failed.\n"
	exit 1
fi

printf -- "-- End of configuration\n"
exit 0
