#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

echo -e '\n-- Collecting results of the performance test suite...'

echo -e '\n > Collecting basic configuration information...'

curl -f -k --silent -X GET \
  "${PTS_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${PTS_SERVER}/configuration" > /export/omag.server.${PTS_SERVER}.config

curl -f -k --silent -X GET \
  "${PTS_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/configuration" > /export/omag.server.${TUT_SERVER}.config

curl -f -k --silent -X GET \
  "${PTS_ENDPOINT}/servers/${PTS_SERVER}/open-metadata/repository-services/users/${EGERIA_USER}/metadata-highway/local-registration" > /export/cohort.${EGERIA_COHORT}.${PTS_SERVER}.local

curl -f -k --silent -X GET \
  "${PTS_ENDPOINT}/servers/${PTS_SERVER}/open-metadata/repository-services/users/${EGERIA_USER}/metadata-highway/cohorts/${EGERIA_COHORT}/remote-members" > /export/cohort.${EGERIA_COHORT}.${PTS_SERVER}.remote

curl -f -k --silent -X GET \
  "${PTS_ENDPOINT}/servers/${TUT_SERVER}/open-metadata/repository-services/users/${EGERIA_USER}/metadata-highway/local-registration" > /export/cohort.${EGERIA_COHORT}.${TUT_SERVER}.local

curl -f -k --silent -X GET \
  "${PTS_ENDPOINT}/servers/${TUT_SERVER}/open-metadata/repository-services/users/${EGERIA_USER}/metadata-highway/cohorts/${EGERIA_COHORT}/remote-members" > /export/cohort.${EGERIA_COHORT}.${TUT_SERVER}.remote

echo -e ' > Waiting for the performance test suite to complete...'

sleep 60
SECONDS_WAITING=60

until [ $(curl -f -k --silent -X GET ${PTS_ENDPOINT}/servers/${PTS_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/status/workbenches/performance-workbench | jq '.workbenchStatus.workbenchComplete') == "true" ]; do
  echo "   ... still waiting ($((SECONDS_WAITING/86400))d:"$(date -ud "@$SECONDS_WAITING" "+%Hh:%Mm:%Ss")")"
  let SECONDS_WAITING+=30;
  sleep 30;
done

curl -f -k --silent -X GET --max-time 120 ${PTS_ENDPOINT}/servers/${PTS_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/report/summary > /export/openmetadata_pts_summary.json

TEST_CASES=$(curl -f -k --silent -X GET --max-time 120 ${PTS_ENDPOINT}/servers/${PTS_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/report/test-cases  | jq -r '.testCaseIds[]')

PROFILES=$(curl -f -k --silent -X GET --max-time 120 ${PTS_ENDPOINT}/servers/${PTS_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/report/profiles | jq -r '.profileNames[]')

echo -e '\n > Retrieving detailed profile results...\n'
mkdir -p /export/profile-details
while read -r line; do
  urlencoded=$(echo ${line} | sed -e 's/ /%20/g');
  filename=$(echo ${line} | sed -e 's/ /_/g');
  echo "   ... retrieving profile details for: ${line}";
  curl -f -k --silent -X GET --max-time 120 ${PTS_ENDPOINT}/servers/${PTS_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/report/profiles/${urlencoded} > /export/profile-details/${filename}.json;
done < <(echo "${PROFILES}")

echo -e '\n > Retrieving detailed test case results...\n'
mkdir -p /export/test-case-details
while read -r line; do
  urlencoded=$(echo ${line} | sed -e 's/</%3C/g');
  urlencoded=$(echo ${urlencoded} | sed -e 's/>/%3E/g');
  filename=$(echo ${line} | sed -e 's/[<>]/_/g');
  echo "   ... retrieving test case details for: ${line}";
  curl -f -k --silent -X GET --max-time 120 ${PTS_ENDPOINT}/servers/${PTS_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/report/test-cases/${urlencoded} > /export/test-case-details/${filename}.json;
done < <(echo "${TEST_CASES}")

echo -e '\n > Bundling all results into an archive...\n'
cd /export
tar cf pd.tar profile-details/*.json; gzip pd.tar
tar cf tcd.tar test-case-details/*.json; gzip tcd.tar
tar cf ${PTS_REPORT_NAME}.tar *.config cohort.* openmetadata_pts_summary.json pd.tar.gz tcd.tar.gz; gzip ${PTS_REPORT_NAME}.tar

echo -e "\n-- End of performance test suite results collection, download from: /export/${PTS_REPORT_NAME}.tar.gz"
