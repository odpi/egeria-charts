#!/usr/bin/env bash

printf "\n\n-- Needed environment variables --\n"
printf "EGERIA_USER=%s\n" "${EGERIA_USER}"
printf "KAFKA_ENDPOINT=%s\n" "${KAFKA_ENDPOINT}"
printf "EGERIA_LINEAGE_SERVER_NAME=%s\n" "${EGERIA_LINEAGE_SERVER_NAME}"
printf "EGERIA_LINEAGE_TOPIC_NAME=%s\n" "${EGERIA_LINEAGE_TOPIC_NAME}"
printf "EGERIA_LINEAGE_CONSUMER_ID=%s\n" "${EGERIA_LINEAGE_CONSUMER_ID}"
printf "EGERIA_LINEAGE_ENDPOINT=%s\n" "${EGERIA_LINEAGE_ENDPOINT}"
printf "\n\n-- End of Needed environment variables --\n"

# 1. Update the server type name for lineage1
printf "\n\n > Update the server type name for lineage1:\n"
curl -k --request POST "${EGERIA_LINEAGE_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_LINEAGE_SERVER_NAME}/server-type?typeName=Integration%20Daemon" --data-raw ''

# 2. Configure the integration services audit log
if [[ "$?" == 0 ]]; then {
    printf "\n\nUpdating the server type name succesful!\n"
    printf "\n\n > Configure the default audit log:\n"
    curl -k --request POST "${EGERIA_LINEAGE_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_LINEAGE_SERVER_NAME}/audit-log-destinations/default" --header 'Content-Type: application/json'
} else {
    printf "\n\nUpdating the server type name failed!\n"
    exit 255
} fi

# 3. Configure the sample lineage integrator service
if [[ "$?" == 0 ]]; then {
    printf "\n\nConfiguring the integration services audit log succesful!\n"
    printf "\n\n > Configure the sample lineage integrator service:\n"
    curl -k --request POST "${EGERIA_LINEAGE_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_LINEAGE_SERVER_NAME}/integration-services/lineage-integrator" --header 'Content-Type: application/json' --data @- <<EOF
{
    "class": "IntegrationServiceRequestBody",
    "omagserverPlatformRootURL": "${EGERIA_LINEAGE_ENDPOINT}",
    "omagserverName": "${EGERIA_LINEAGE_SERVER_NAME}",
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
} else {
    printf "\n\nConfiguring the integration services audit log failed!\n"
    exit 255
} fi

# 4. Start the Lineage Integration sample server
if [[ "$?" == 0 ]]; then {
    printf "\n\nConfigure the sample lineage integrator service successful!\n"
    printf "\n\n > Start the Lineage Integration sample server:\n"
    curl -k --request POST "${EGERIA_LINEAGE_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_LINEAGE_SERVER_NAME}/instance" --data-raw ''
} else {
    printf "\n\nConfigure the sample lineage integrator service failed!\n"
    exit 255
} fi

if [[ "$?" == 0 ]]; then {
    printf "\n\nStarting the lineage integration sample server successful!\n"
} else {
    printf "\n\nStarting the lineage integration sample server failed!\n"
    exit 255
} fi
