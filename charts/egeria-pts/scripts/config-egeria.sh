#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

echo '-- Environment variables --'
env
echo '-- End of Environment variables --'

echo -e '\n-- Configuring platform with required servers...'

echo -e '\n > Configuring performance test suite driver:\n'

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${PTS_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${PTS_SERVER}/server-url-root?url=${PTS_ENDPOINT}" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${PTS_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${PTS_SERVER}/server-type?typeName=Conformance" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${PTS_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${PTS_SERVER}/event-bus?topicURLRoot=egeria" \
  --data '{"producer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"}, "consumer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"} }' || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${PTS_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${PTS_SERVER}/cohorts/${EGERIA_COHORT}" || exit $?

echo '{"class":"RepositoryPerformanceWorkbenchConfig","tutRepositoryServerName":"'"${TUT_SERVER}"'","instancesPerType":'${INSTANCES_PER_TYPE}',"maxSearchResults":'${MAX_SEARCH_RESULTS}',"waitBetweenScenarios":'${WAIT_BETWEEN_SCENARIOS}',"profilesToSkip":'${PROFILES_TO_SKIP}',"methodsToSkip":'${METHODS_TO_SKIP}' }' > /tmp/config.json

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${PTS_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${PTS_SERVER}/conformance-suite-workbenches/repository-workbench/performance" \
  --data @/tmp/config.json || exit $?

echo -e '\n > Configuring technology under test:\n'

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${TUT_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/server-url-root?url=${TUT_ENDPOINT}" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${TUT_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/server-type?typeName=TUT" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${TUT_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/organization-name?name=Egeria" || exit $?

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  --header "Content-Type: application/json" \
  "${TUT_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/event-bus?topicURLRoot=egeria" \
  --data '{"producer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"}, "consumer": {"bootstrap.servers": "'"${KAFKA_ENDPOINT}"'"} }' || exit $?

if [ "${TUT_TYPE}" = "native" ]; then
  if [ "${CONNECTOR_PROVIDER}" = "org.odpi.openmetadata.adapters.repositoryservices.graphrepository.repositoryconnector.GraphOMRSRepositoryConnectorProvider" ]; then
    curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
      "${TUT_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/mode/local-graph-repository" || exit $?
  else
    echo "-- Unknown native repository provider: ${CONNECTOR_PROVIDER} -- exiting."
    exit 1
  fi
elif [ "${TUT_TYPE}" = "plugin" ]; then
  curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
    --header "Content-Type: application/json" \
    "${TUT_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/mode/plugin-repository/connection" \
    --data '{"class":"Connection","connectorType":{"class":"ConnectorType","connectorProviderClassName":"'"${CONNECTOR_PROVIDER}"'"},"configurationProperties":'${CONNECTOR_CONFIG}'}}' || exit $?
elif [ "${TUT_TYPE}" = "proxy" ]; then
  curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
    --header "Content-Type: application/json" \
    "${TUT_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/local-repository/mode/repository-proxy/connection" \
    --data '{"class":"Connection","connectorType":{"class":"ConnectorType","connectorProviderClassName":"'"${CONNECTOR_PROVIDER}"'"},"endpoint":{"class":"Endpoint","address":"'"${TUT_HOST}:${TUT_PORT}"'","protocol":"'"${TUT_PROTOCOL}"'"},"userId":"'"${TUT_USER}"'","clearPassword":"'"${TUT_PASS}"'","configurationProperties":'${CONNECTOR_CONFIG}'}}' || exit $?
else
  echo "-- Unknown repository type: ${TUT_TYPE} -- exiting."
  exit 1
fi

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${TUT_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/cohorts/${EGERIA_COHORT}" || exit $?

echo -e "\n-- End of configuration"
