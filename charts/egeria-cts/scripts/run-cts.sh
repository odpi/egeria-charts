#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

echo -e '\n-- Running the conformance test suite...'

echo -e '\n > Starting conformance test suite:\n'

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_SERVER}/instance"

echo -e '\n > Starting the technology under test:\n'

curl -f -k -w "\n   (%{http_code} - %{url_effective})\n" --silent -X POST --max-time 900 \
  "${EGERIA_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${TUT_SERVER}/instance"

echo -e "\n-- End of conformance test suite startup"
