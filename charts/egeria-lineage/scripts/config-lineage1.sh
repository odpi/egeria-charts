# 1. Update the server type name for lineage1
echo -e '\n\n > Update the server type name for lineage1:\n'
curl -k --request POST "${EGERIA_OMAG_SERVER_URL}/open-metadata/admin-services/users/${EGERIA_LINEAGE_USER}/servers/${EGERIA_LINEAGE_SERVER}/server-type?typeName=Integration%20Daemon" \
--data-raw ''

# 2. Configure the integration services audit log
echo -e '\n\n > Configure the default audit log:\n'
curl -k --request POST "${EGERIA_OMAG_SERVER_URL}/open-metadata/admin-services/users/${EGERIA_LINEAGE_USER}/servers/${EGERIA_LINEAGE_SERVER}/audit-log-destinations/default" \
--header 'Content-Type: application/json' \

# 3. Configure the sample lineage integrator service
echo -e '\n\n > Configure the sample lineage integrator service:\n'
curl -k --request POST "${EGERIA_OMAG_SERVER_URL}/open-metadata/admin-services/users/${EGERIA_LINEAGE_USER}/servers/${EGERIA_LINEAGE_SERVER}/integration-services/lineage-integrator" \
--header 'Content-Type: application/json' \
--data @- <<EOF
{
	"class": "IntegrationServiceRequestBody",
	"omagserverPlatformRootURL": "{EGERIA_OMAG_SERVER_URL}",
	"omagserverName": "${EGERIA_OMAG_SERVER_NAME}",
	"connectorUserId": "${EGERIA_LINEAGE_USER}",
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
									"bootstrap.servers": "${EGERIA_KAFKA_ENDPOINT}"
								},
								"local.server.id": "${EGERIA_LINEAGE_CONSUMER_ID}",
								"consumer": {
									"bootstrap.servers": "${EGERIA_KAFKA_ENDPOINT}"
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

# 4. Start the Lineage Integration sample server
echo -e '\n\n > Start the Lineage Integration sample server:\n'
curl -k --request POST "${EGERIA_OMAG_SERVER_URL}/open-metadata/admin-services/users/${EGERIA_LINEAGE_USER}/servers/${EGERIA_LINEAGE_SERVER}/instance" \
--data-raw ''