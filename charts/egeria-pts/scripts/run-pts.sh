#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

echo -e '\n-- Running the performance test suite...'

echo -e '\n > Starting performance test suite:\n'

response=$(curl -f -k --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/instance") || exit $?

if [ "200" != "$(echo ${response} | jq '.relatedHTTPCode')" ]; then
  echo "Unable to start the PTS server:"
  echo ${response}
  exit 2
else
  echo ${response}
fi

echo -e '\n > Starting the technology under test:\n'

response=$(curl -f -k --silent -X POST --max-time 900 \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/instance") || exit $?

if [ "200" != "$(echo ${response} | jq '.relatedHTTPCode')" ]; then
  echo "Unable to start the TUT server:"
  echo ${response}
  exit 3
else
  echo ${response}
fi

echo -e "\n-- End of performance test suite startup"
