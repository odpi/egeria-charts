#!/usr/bin/env bash

# exit when any command fails
set -e

printf -- "-- Needed environment variables from egeria-base --\n"
printf "EGERIA_USER=%s\n" "${EGERIA_USER}"
printf "KAFKA_ENDPOINT=%s\n" "${KAFKA_ENDPOINT}"
printf "EGERIA_ENDPOINT=%s\n" "${EGERIA_ENDPOINT}"
printf "EGERIA_SERVER=%s\n" "${EGERIA_SERVER}"
printf -- "-- Needed environment variables from egeria-lineage --\n"
printf "EGERIA_LINEAGE_SERVER_NAME=%s\n" "${EGERIA_LINEAGE_SERVER_NAME}"
printf "EGERIA_LINEAGE_TOPIC_NAME=%s\n" "${EGERIA_LINEAGE_TOPIC_NAME}"
printf "EGERIA_LINEAGE_CONSUMER_ID=%s\n" "${EGERIA_LINEAGE_CONSUMER_ID}"
printf "EGERIA_LINEAGE_ENDPOINT=%s\n" "${EGERIA_LINEAGE_ENDPOINT}"
printf -- "-- End of Needed environment variables --\n"

printf -- "-- Configuring the sample lineage connector\n"

# 1. Update the server type name for EGERIA_LINEAGE_SERVER_NAME
printf "\n\n > Update the server type name for \"%s\":\n" "${EGERIA_LINEAGE_SERVER_NAME}"
RC=$(curl -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  "${EGERIA_LINEAGE_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_LINEAGE_SERVER_NAME}/server-type?typeName=Integration%20Daemon" --data-raw '' | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Updating the server type name for \"%s\" successful.\n" "${EGERIA_LINEAGE_SERVER_NAME}"
  unset RC
else
	printf "\n\nUpdating the server type name for \"%s\" failed.\n" "${EGERIA_LINEAGE_SERVER_NAME}"
	exit 1
fi

# 2. Configure the integration services audit log
printf "\n\n > Configure the default audit log:\n"
RC=$(curl -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  "${EGERIA_LINEAGE_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_LINEAGE_SERVER_NAME}/audit-log-destinations/default" --header 'Content-Type: application/json' | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Configuring the default audit log successful.\n"
  unset RC
else
	printf "\n\nConfiguring the default audit log failed.\n"
	exit 1
fi

# 3. Configure the sample lineage integrator service
printf "\n\n > Configure the sample lineage integrator service:\n"
RC=$(curl -s -o /dev/null -w "%{http_code}" --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_LINEAGE_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_LINEAGE_SERVER_NAME}/integration-services/lineage-integrator" \
  --header 'Content-Type: application/json' \
  --data @- << EOF | cut -d "}" -f2
{
  "class": "IntegrationServiceRequestBody",
  "omagserverPlatformRootURL": "${EGERIA_ENDPOINT}",
  "omagserverName": "${EGERIA_SERVER}",
  "connectorUserId": "${EGERIA_USER}",
  "integrationConnectorConfigs": [
    {
    "class": "IntegrationConnectorConfig",
    "connectorId": "ba6dc870-2303-48fc-8611-d50b49706f48",
    "connectorName": "LineageIntegrator",
    "metadataSourceQualifiedName": "TestMetadataSourceQualifiedName",
    "connection": {
      "class": "VirtualConnection",
      "headerVersion": 0,
      "qualifiedName": "Egeria:IntegrationConnector:Lineage:OpenLineageEventReceiverConnection",
      "connectorType": {
        "class": "ConnectorType",
        "headerVersion": 0,
        "connectorProviderClassName": "org.odpi.openmetadata.adapters.connectors.integration.lineage.sample.SampleLineageEventReceiverIntegrationProvider"
      },
      "embeddedConnections": [
        {
          "class": "EmbeddedConnection",
          "headerVersion": 0,
          "position": 0,
          "embeddedConnection": {
            "class": "Connection",
            "headerVersion": 0,
            "qualifiedName": "Kafka Open Metadata Topic Connector for sample lineage",
            "connectorType": {
              "class": "ConnectorType",
              "headerVersion": 0,
              "connectorProviderClassName": "org.odpi.openmetadata.adapters.eventbus.topic.kafka.KafkaOpenMetadataTopicProvider"
            },
            "endpoint": {
              "class": "Endpoint",
              "headerVersion": 0,
              "address": "${EGERIA_LINEAGE_TOPIC_NAME}"
            },
            "configurationProperties": {
              "producer": {
                "bootstrap.servers": "${KAFKA_ENDPOINT}"
              },
              "local.server.id": "${EGERIA_LINEAGE_CONSUMER_ID}",
              "consumer": {
                "bootstrap.servers": "${KAFKA_ENDPOINT}"
              }
            }
          }
        }
      ]
    },
    "refreshTimeInterval": 0,
    "usesBlockingCalls": false
    }
  ]
}
EOF

)

if [ "${RC}" -eq 200 ]; then
  printf "Configuring the sample lineage integrator service successful.\n"
  unset RC
else
	printf "\n\nConfiguring the sample lineage integrator service failed.\n"
	exit 1
fi

# 4. Start the Lineage Integration sample server
printf "\n\n > Start the Lineage Integration sample server:\n"
RC=$(curl -s -o /dev/null -w "%{http_code}" --basic admin:admin -X POST \
  "${EGERIA_LINEAGE_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_LINEAGE_SERVER_NAME}/instance" --data-raw '' | cut -d "}" -f2)

if [ "${RC}" -eq 200 ]; then
  printf "Starting the Lineage Integration sample server successful.\n"
  unset RC
else
	printf "\n\nStarting the Lineage Integration sample server failed.\n"
	exit 1
fi

printf -- "-- End of configuration\n"
exit 0
