#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

echo '-- Environment variables --'
env
echo '-- End of Environment variables --'

echo -e '\n-- Configuring platform with required servers...'

echo -e '\n > Configuring conformance test suite driver:\n'

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/server-url-root?url=${EGERIA_ENDPOINT}" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/server-type?typeName=Conformance" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/event-bus?topicURLRoot=egeria" \
  --data '{"producer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"}, "consumer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"} }' || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/cohorts/${EGERIA_COHORT}" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/conformance-suite-workbenches/repository-workbench/repositories" \
  --data '{"class":"RepositoryConformanceWorkbenchConfig","tutRepositoryServerName":"'"${TUT_SERVER}"'","maxSearchResults":'${CTS_FACTOR}' }' || exit $?

# Custom audit log configuration to help troubleshooting errors and exceptions for CTS server #
# Remove all audit log destinations (removes default) #
curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X DELETE \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/audit-log-destinations" \
  --data ''|| exit $?
# Add the custom console destination using only Error and Exception severities #
curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/audit-log-destinations/console" \
  --data '["Error","Exception"]'|| exit $?

echo -e '\n > Configuring technology under test:\n'

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/server-url-root?url=${EGERIA_ENDPOINT}" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/server-type?typeName=TUT" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/organization-name?name=Egeria" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/event-bus?topicURLRoot=egeria" \
  --data '{"producer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"}, "consumer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"} }' || exit $?

if [ "${TUT_TYPE}" = "native" ]; then
  if [ "${CONNECTOR_PROVIDER}" = "org.odpi.openmetadata.adapters.repositoryservices.graphrepository.repositoryconnector.GraphOMRSRepositoryConnectorProvider" ]; then
    curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
      "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/mode/local-graph-repository" || exit $?
  elif [ "${CONNECTOR_PROVIDER}" = "org.odpi.openmetadata.adapters.repositoryservices.inmemory.repositoryconnector.InMemoryOMRSRepositoryConnectorProvider" ]; then
      curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
        "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/mode/in-memory-repository" || exit $?
  else
    echo "-- Unknown native repository provider: ${CONNECTOR_PROVIDER} -- exiting."
    exit 1
  fi
elif [ "${TUT_TYPE}" = "plugin" ]; then
  curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
    --header "Content-Type: application/json" \
    "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/mode/plugin-repository/connection" \
    --data '{"class":"Connection","connectorType":{"class":"ConnectorType","connectorProviderClassName":"'"${CONNECTOR_PROVIDER}"'"},"configurationProperties":'${CONNECTOR_CONFIG}'}}' || exit $?
elif [ "${TUT_TYPE}" = "proxy" ]; then
  curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
    --header "Content-Type: application/json" \
    "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/mode/repository-proxy/connection" \
    --data '{"class":"Connection","connectorType":{"class":"ConnectorType","connectorProviderClassName":"'"${CONNECTOR_PROVIDER}"'"},"endpoint":{"class":"Endpoint","address":"'"${TUT_HOST}:${TUT_PORT}"'","protocol":"'"${TUT_PROTOCOL}"'"},"userId":"'"${TUT_USER}"'","clearPassword":"'"${TUT_PASS}"'","configurationProperties":'${CONNECTOR_CONFIG}'}}' || exit $?
else
  echo "-- Unknown repository type: ${TUT_TYPE} -- exiting."
  exit 1
fi

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/metadata-collection-name/TUT_MDR" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/cohorts/${EGERIA_COHORT}" || exit $?

# Custom audit log configuration to help troubleshooting errors and exceptions for TUT server #
# Remove all audit log destinations (removes default) #
curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X DELETE \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/audit-log-destinations" \
  --data ''|| exit $?
# Add the custom console destination using only Error and Exception severities #
curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/audit-log-destinations/console" \
  --data '["Error","Exception"]'|| exit $?

echo -e "\n-- End of configuration"
