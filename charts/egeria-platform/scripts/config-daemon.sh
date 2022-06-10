#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

# wait until Egeria API is ready
status_code=$(curl -s -o /dev/null -w "%{http_code}" -k -X GET ${EGERIA_LOCAL_ENDPOINT}/open-metadata/platform-services/users/${EGERIA_USER}/server-platform/origin)
until [ $status_code -eq 200 ]; do
    echo "Status code: ${status_code}"
    sleep 2;
    status_code=$(curl -s -o /dev/null -w "%{http_code}" -k -X GET ${EGERIA_LOCAL_ENDPOINT}/open-metadata/platform-services/users/${EGERIA_USER}/server-platform/origin)
done;
echo "Egeria Tomcat Server is up and running"

# log environment variables
echo '-- Environment variables --'
env
echo '-- End of Environment variables --'

# execute configuration scripts
CONFIG_SERVER_LIST_ARR=($(echo $CONFIG_SERVER_LIST | tr "," "\n"))
for SERVER in "${CONFIG_SERVER_LIST_ARR[@]}";
do
    echo '-- Start configuring ${SERVER} --'
    /home/jboss/scripts/config-${SERVER}.sh
    echo '-- End configuring ${SERVER}'
done

# create file to let startupProbe succeed
echo "Done" > /tmp/done.txt
