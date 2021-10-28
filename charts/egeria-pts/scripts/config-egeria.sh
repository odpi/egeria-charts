#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

echo '-- Environment variables --'
env
echo '-- End of Environment variables --'

echo -e '\n-- Configuring platform with required servers...'

echo -e '\n > Configuring performance test suite driver:\n'

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/server-url-root?url=${EGERIA_ENDPOINT}"

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/server-type?typeName=Conformance"

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/event-bus?topicURLRoot=egeria" \
  --data '{"producer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"}, "consumer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"} }'

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/cohorts/${EGERIA_COHORT}"

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/conformance-suite-workbenches/repository-workbench/performance" \
  --data '{"class":"RepositoryPerformanceWorkbenchConfig","tutRepositoryServerName":"'"${TUT_SERVER}"'","instancesPerType":'${INSTANCES_PER_TYPE}',"maxSearchResults":'${MAX_SEARCH_RESULTS}',"waitBetweenScenarios":'${WAIT_BETWEEN_SCENARIOS}',"profilesToSkip":'${PROFILES_TO_SKIP}',"methodsToSkip":'${METHODS_TO_SKIP}' }'

echo -e '\n > Configuring technology under test:\n'

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/server-url-root?url=${EGERIA_ENDPOINT}"

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/server-type?typeName=TUT"

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/organization-name?name=Egeria"

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/event-bus?topicURLRoot=egeria" \
  --data '{"producer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"}, "consumer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"} }'

if [ "${TUT_TYPE}" = "native" ]; then
  if [ "${CONNECTOR_PROVIDER}" = "org.odpi.openmetadata.adapters.repositoryservices.graphrepository.repositoryconnector.GraphOMRSRepositoryConnectorProvider" ]; then
    curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
      "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/mode/local-graph-repository"
  else
    echo "-- Unknown native repository provider: ${CONNECTOR_PROVIDER} -- exiting."
    exit 1
  fi
elif [ "${TUT_TYPE}" = "plugin" ]; then
  curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
    --header "Content-Type: application/json" \
    "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/mode/plugin-repository/connection" \
    --data '{"class":"Connection","connectorType":{"class":"ConnectorType","connectorProviderClassName":"'"${CONNECTOR_PROVIDER}"'"},"configurationProperties":'${CONNECTOR_CONFIG}'}}'
elif [ "${TUT_TYPE}" = "proxy" ]; then
  curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
    --header "Content-Type: application/json" \
    "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/mode/repository-proxy/connection" \
    --data '{"class":"Connection","connectorType":{"class":"ConnectorType","connectorProviderClassName":"'"${CONNECTOR_PROVIDER}"'"},"endpoint":{"class":"Endpoint","address":"'"${TUT_HOST}:${TUT_PORT}"'","protocol":"'"${TUT_PROTOCOL}"'"},"userId":"'"${TUT_USER}"'","clearPassword":"'"${TUT_PASS}"'","configurationProperties":'${CONNECTOR_CONFIG}'}}'
else
  echo "-- Unknown repository type: ${TUT_TYPE} -- exiting."
  exit 1
fi

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/cohorts/${EGERIA_COHORT}"

echo -e "\n-- End of configuration"
