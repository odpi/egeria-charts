echo -e '\n-- Configuring platform with requires servers'

# Set the URL root
echo -e '\n\n > Setting server URL root:\n'
curl -f -k --verbose --basic admin:admin -X POST \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_OMAG_SERVER_NAME}/server-url-root?url=${EGERIA_ENDPOINT}"

# Setup the event bus
echo -e '\n\n > Setting up event bus:\n'
curl -f -k --verbose --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_OMAG_SERVER_NAME}/event-bus" \
  --data '{"producer": {"bootstrap.servers": "'"${EGERIA_KAFKA_ENDPOINT}"'"}, "consumer": {"bootstrap.servers": "'"${EGERIA_KAFKA_ENDPOINT}"'"} }'

# Enable all the access services (we will adjust this later)
echo -e '\n\n > Enabling all access servces:\n'
curl -f -k --verbose --basic admin:admin -X POST \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_OMAG_SERVER_NAME}/access-services?serviceMode=ENABLED"

# Use a local graph repo
echo -e '\n\n > Use local graph repo:\n'
curl -f -k --verbose --basic admin:admin -X POST \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_OMAG_SERVER_NAME}/local-repository/mode/local-graph-repository"

# Configure the cohort membership
echo -e '\n\n > configuring cohort membership:\n'
curl -f -k --verbose --basic admin:admin -X POST \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_OMAG_SERVER_NAME}/cohorts/${EGERIA_COHORT}"

# Start up the server, might take some time
echo -e '\n\n > Starting the server:\n'
curl -f -k --verbose --basic admin:admin -X POST --max-time 900 \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_OMAG_SERVER_NAME}/instance"




