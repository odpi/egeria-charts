export EGERIA_VIEW_SERVER=view1

# Set the URL root
echo -e '\n\n > Setting view server URL root:\n'
curl -f -k --verbose --basic admin:admin -X POST \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_VIEW_SERVER}/server-url-root?url=${EGERIA_ENDPOINT}"

# Setup the event bus
echo -e '\n\n > Setting up event bus:\n'
curl -f -k --verbose --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_VIEW_SERVER}/event-bus" \
  --data '{"producer": {"bootstrap.servers": "'"${EGERIA_KAFKA_ENDPOINT}"'"}, "consumer": {"bootstrap.servers": "'"${EGERIA_KAFKA_ENDPOINT}"'"} }'

# Set as view server
echo -e '\n\n > Set as view server:\n'
curl -f -k --verbose --basic admin:admin -X POST \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_VIEW_SERVER}/server-type?typeName=View%20Server"

# Configure the view server cohort membership
echo -e '\n\n > configuring cohort membership:\n'
curl -f -k --verbose --basic admin:admin -X POST \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_VIEW_SERVER}/cohorts/${EGERIA_COHORT}"

# Configure the view services
echo -e '\n\n > Setting up Glossary Author:\n'
curl -f -k --verbose --basic admin:admin \
   --header "Content-Type: application/json" \
   "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_VIEW_SERVER}/view-services/glossary-author" \
   --data @- <<EOF
{
  "class": "ViewServiceConfig",
  "omagserverPlatformRootURL": "${EGERIA_OMAG_SERVER_URL}",
  "omagserverName" : "${EGERIA_OMAG_SERVER_NAME}"
}
EOF

echo -e '\n\n > Setting up TEX:\n'
curl -f -k --verbose --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_VIEW_SERVER}/view-services/tex" \
  --data @- <<EOF
{
  "class":"IntegrationViewServiceConfig",
  "viewServiceAdminClass":"org.odpi.openmetadata.viewservices.tex.admin.TexViewAdmin",
  "viewServiceFullName":"Type Explorer",
  "viewServiceOperationalStatus":"ENABLED",
  "omagserverPlatformRootURL": "UNUSED",
  "omagserverName" : "UNUSED",
  "resourceEndpoints" : [
    {
      "class"              : "ResourceEndpointConfig",
      "resourceCategory"   : "Platform",
      "description"        : "Platform",
      "platformName"       : "platform",
      "platformRootURL"    : "${EGERIA_ENDPOINT}"
    },
    {
      "class"              : "ResourceEndpointConfig",
      "resourceCategory"   : "Server",
      "serverInstanceName" : "${EGERIA_OMAG_SERVER_NAME}",
      "description"        : "Server",
      "platformName"       : "platform",
      "serverName"         : "${EGERIA_OMAG_SERVER_NAME}"
    }
  ]
}
EOF

echo -e '\n\n > Setting up REX:\n'
curl -f -k --verbose --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_VIEW_SERVER}/view-services/rex" \
  --data @- <<EOF
{
  "class":"IntegrationViewServiceConfig",
  "viewServiceAdminClass":"org.odpi.openmetadata.viewservices.rex.admin.RexViewAdmin",
  "viewServiceFullName":"Repository Explorer",
  "viewServiceOperationalStatus":"ENABLED",
  "omagserverPlatformRootURL": "UNUSED",
  "omagserverName" : "UNUSED",
  "resourceEndpoints" : [
    {
        "class"              : "ResourceEndpointConfig",
        "resourceCategory"   : "Platform",
        "description"        : "Platform",
        "platformName"       : "platform",
        "platformRootURL"    : "${EGERIA_ENDPOINT}"
    },
                  {
        "class"              : "ResourceEndpointConfig",
        "resourceCategory"   : "Server",
        "serverInstanceName" : "${EGERIA_OMAG_SERVER_NAME}",
        "description"        : "Server",
        "platformName"       : "platform",
        "serverName"         : "${EGERIA_OMAG_SERVER_NAME}"
    }
  ]
}
EOF

echo -e '\n\n > Setting up DINO:\n'
curl -f -k --verbose --basic admin:admin \
  --header "Content-Type: application/json" \
  "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_VIEW_SERVER}/view-services/dino" \
  --data @- <<EOF
{
  "class":"IntegrationViewServiceConfig",
  "viewServiceAdminClass":"org.odpi.openmetadata.viewservices.dino.admin.DinoViewAdmin",
  "viewServiceFullName":"Dino",
  "viewServiceOperationalStatus":"ENABLED",
  "omagserverPlatformRootURL": "UNUSED",
  "omagserverName" : "UNUSED",
  "resourceEndpoints" : [
    {
        "class"              : "ResourceEndpointConfig",
        "resourceCategory"   : "Platform",
        "description"        : "Platform",
        "platformName"       : "platform",
        "platformRootURL"    : "${EGERIA_ENDPOINT}"
    },
    {
        "class"              : "ResourceEndpointConfig",
        "resourceCategory"   : "Server",
        "serverInstanceName" : "${EGERIA_OMAG_SERVER_NAME}",
        "description"        : "Server",
        "platformName"       : "platform",
        "serverName"         : "${EGERIA_OMAG_SERVER_NAME}"
    },
    {
        "class"              : "ResourceEndpointConfig",
        "resourceCategory"   : "Server",
        "serverInstanceName" : "${EGERIA_VIEW_SERVER}",
        "description"        : "Server",
        "platformName"       : "platform",
        "serverName"         : "${EGERIA_VIEW_SERVER}"
    }
  ]
}
EOF

# Start up the view server
echo -e '\n\n > Starting the view server:\n'
curl -f -k --verbose --basic admin:admin -X POST --max-time 900 \
    "${EGERIA_LOCAL_ENDPOINT}/open-metadata/admin-services/users/${EGERIA_USER}/servers/${EGERIA_VIEW_SERVER}/instance"

