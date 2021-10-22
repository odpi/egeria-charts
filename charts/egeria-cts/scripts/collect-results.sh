#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

echo -e '\n-- Collecting results of the conformance test suite...'

echo -e '\n > Collecting basic configuration information...'

curl -f -k --silent -X GET \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/configuration" > /tmp/omag.server.${EGERIA_SERVER}.config

curl -f -k --silent -X GET \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/configuration" > /tmp/omag.server.${TUT_SERVER}.config

curl -f -k --silent -X GET \
  "${EGERIA_ENDPOINT}/servers/${EGERIA_SERVER}/open-metadata/repository-services/users/${EGERIA_USER}/metadata-highway/local-registration" > /tmp/cohort.${EGERIA_COHORT}.${EGERIA_SERVER}.local

curl -f -k --silent -X GET \
  "${EGERIA_ENDPOINT}/servers/${EGERIA_SERVER}/open-metadata/repository-services/users/${EGERIA_USER}/metadata-highway/cohorts/${EGERIA_COHORT}/remote-members" > /tmp/cohort.${EGERIA_COHORT}.${EGERIA_SERVER}.remote

curl -f -k --silent -X GET \
  "${EGERIA_ENDPOINT}/servers/${TUT_SERVER}/open-metadata/repository-services/users/${EGERIA_USER}/metadata-highway/local-registration" > /tmp/cohort.${EGERIA_COHORT}.${TUT_SERVER}.local

curl -f -k --silent -X GET \
  "${EGERIA_ENDPOINT}/servers/${TUT_SERVER}/open-metadata/repository-services/users/${EGERIA_USER}/metadata-highway/cohorts/${EGERIA_COHORT}/remote-members" > /tmp/cohort.${EGERIA_COHORT}.${TUT_SERVER}.remote

echo -e ' > Waiting for the conformance test suite to complete...'

sleep 60
SECONDS_WAITING=60

until [ $(curl -f -k --silent -X GET ${EGERIA_ENDPOINT}/servers/${EGERIA_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/status/workbenches/repository-workbench | jq '.workbenchStatus.workbenchComplete') == "true" ]; do
  echo "   ... still waiting ($((SECONDS_WAITING/86400))d:"$(date -ud "@$SECONDS_WAITING" "+%Hh:%Mm:%Ss")")"
  let SECONDS_WAITING+=30;
  sleep 30;
done

curl -f -k --silent -X GET --max-time 60 ${EGERIA_ENDPOINT}/servers/${EGERIA_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/report/summary > /tmp/openmetadata_cts_summary.json

TEST_CASES=$(curl -f -k --silent -X GET --max-time 60 ${EGERIA_ENDPOINT}/servers/${EGERIA_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/report/test-cases  | jq -r '.testCaseIds[]')

PROFILES=$(curl -f -k --silent -X GET --max-time 60 ${EGERIA_ENDPOINT}/servers/${EGERIA_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/report/profiles | jq -r '.profileNames[]')

echo -e '\n > Retrieving detailed profile results...\n'
mkdir -p /tmp/profile-details
while read -r line; do
  urlencoded=$(echo ${line} | sed -e 's/ /%20/g');
  filename=$(echo ${line} | sed -e 's/ /_/g');
  echo "   ... retrieving profile details for: ${line}";
  curl -f -k --silent -X GET --max-time 60 ${EGERIA_ENDPOINT}/servers/${EGERIA_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/report/profiles/${urlencoded} > /tmp/profile-details/${filename}.json;
done < <(echo "${PROFILES}")

echo -e '\n > Retrieving detailed test case results...\n'
mkdir -p /tmp/test-case-details
while read -r line; do
  urlencoded=$(echo ${line} | sed -e 's/</%3C/g');
  urlencoded=$(echo ${urlencoded} | sed -e 's/>/%3E/g');
  filename=$(echo ${line} | sed -e 's/[<>]/_/g');
  echo "   ... retrieving test case details for: ${line}";
  curl -f -k --silent -X GET --max-time 60 ${EGERIA_ENDPOINT}/servers/${EGERIA_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/report/test-cases/${urlencoded} > /tmp/test-case-details/${filename}.json;
done < <(echo "${TEST_CASES}")

echo -e '\n > Bundling all results into an archive...\n'
cd /tmp
tar cvf pd.tar profile-details/*.json; gzip pd.tar
tar cvf tcd.tar test-case-details/*.json; gzip tcd.tar
tar cvf ${CTS_REPORT_NAME}.tar *.config cohort.* openmetadata_cts_summary.json pd.tar.gz tcd.tar.gz; gzip ${CTS_REPORT_NAME}.tar

echo -e "\n-- End of conformance test suite results collection, download from: /tmp/${CTS_REPORT_NAME}.tar.gz"
