#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the Egeria project.

# split SERVER_LIST by ,
SERVER_LIST_ARR=($(echo $SERVER_LIST | tr "," "\n"))

# loop server list and add servers to STARTUP_SERVER_LIST if present on file system
# or to CONFIG_SERVER_LIST if they are not present
STARTUP_SERVER_LIST=""
CONFIG_SERVER_LIST=""
for SERVER in "${SERVER_LIST_ARR[@]}";
do
    SERVER_CONFIG_PATH=/deployments/data/servers/${SERVER}
    if [ -d "${SERVER_CONFIG_PATH}" ]
    then
        if [ -z "${STARTUP_SERVER_LIST}" ]
        then
            STARTUP_SERVER_LIST="${SERVER}"
        else
            STARTUP_SERVER_LIST="${STARTUP_SERVER_LIST},${SERVER}"
        fi
        echo "For server ${SERVER} found config in ${SERVER_CONFIG_PATH}. Added ${SERVER} to autostart: STARTUP_SERVER_LIST=${STARTUP_SERVER_LIST}";
    else
        if [ -z "${CONFIG_SERVER_LIST}" ]
        then
            CONFIG_SERVER_LIST="${SERVER}"
        else
            CONFIG_SERVER_LIST="${CONFIG_SERVER_LIST},${SERVER}"
        fi
        echo "For server ${SERVER} could not find config in ${SERVER_CONFIG_PATH}. Added ${SERVER} to config: CONFIG_SERVER_LIST=${CONFIG_SERVER_LIST}";
    fi
done

# report result
echo "STARTUP_SERVER_LIST=${STARTUP_SERVER_LIST}"
echo "CONFIG_SERVER_LIST=${CONFIG_SERVER_LIST}"

# make available
export STARTUP_SERVER_LIST="${STARTUP_SERVER_LIST}"
export CONFIG_SERVER_LIST="${CONFIG_SERVER_LIST}"

# wait until Kafka is available
echo "exit" | curl -m 2 -v telnet://${EGERIA_KAFKA_ENDPOINT}
exit_code=$?
echo "Wait until Kafka is ready..."
until [ $exit_code -eq 0 ]; do
    echo "Exit code for Kafka request: ${exit_code}"
    sleep 4;
    echo "exit" | curl -m 2 -v telnet://${EGERIA_KAFKA_ENDPOINT}
    exit_code=$?
done;
echo "Kafka is available"

# wait until base platform is ready if it is not self
if [[ "${EGERIA_OMAG_SERVER_URL}" != "${EGERIA_ENDPOINT}" ]]
then
    echo "The OMAG Server runs on URL ${EGERIA_OMAG_SERVER_URL}, wait for it to come up..."
    status_code=$(curl -s -o /dev/null -w "%{http_code}" -k -X GET ${EGERIA_OMAG_SERVER_URL}/open-metadata/platform-services/users/${EGERIA_USER}/server-platform/origin)
    until [ $status_code -eq 200 ]; do
        echo "Request to OMAG Server Platform: ${status_code}"
        sleep 2;
        status_code=$(curl -s -o /dev/null -w "%{http_code}" -k -X GET ${EGERIA_OMAG_SERVER_URL}/open-metadata/platform-services/users/${EGERIA_USER}/server-platform/origin)
    done;
    echo "OMAG Server is reachable under ${EGERIA_OMAG_SERVER_URL}"
fi

# start the config daemon if CONFIG_SERVER_LIST has entries
if [ -n "${CONFIG_SERVER_LIST}" ]
then
    echo "Start config-daemon.sh"
    /home/jboss/scripts/config-daemon.sh &
else
    # mark pod as ready after 20sec
    # hopefully everything is loaded then
    (sleep 20 && echo 'Done' > /tmp/done.txt) &
fi

# execute the original s2i run script
# this will autload servers stored in STARTUP_SERVER_LIST
exec /usr/local/s2i/run

