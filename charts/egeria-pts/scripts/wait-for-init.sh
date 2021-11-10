#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

until $(curl -f -k --silent -X GET ${EGERIA_ENDPOINT}/servers/${EGERIA_SERVER}/open-metadata/conformance-suite/users/${EGERIA_USER}/status/workbenches/performance-workbench | grep 'workbenchStatus' >/dev/null); do
  echo "Waiting for PTS to be running in ${EGERIA_ENDPOINT}..."
  sleep 5
done
