# egeria-platform

This chart is based on `egeria-base` chart in https://github.com/odpi/egeria-charts, but it handles configuration differently and allows for multiple server platforms.


## Prerequisite: Install Kafka

Kafka is not a dependency of this Helm Chart and must be installed beforehand.

```
helm repo add bitnami
helm install egeria-kafka bitnami/kafka
```

This will deploy Bitnami Kafka (https://charts.bitnami.com/bitnami).

*In the following steps it is assumed that the corresponding service is named `egeria-kafka` on port 9092. If you deploy with other settings you need to adjust the following steps.*

If Kafka is deployed to OpenShift, both service accounts `default` and `egeria-kafka` need to have the `system:openshift:scc:anyuid` cluster role.

## Deploy Egeria Servers

Egeria Servers are deployed on an *Egeria Server Platform*. After starting the platform, servers can be configured by issuing REST calls to the platform. If the Egeria server finds configuration documents in the file system, it automatically starts up the servers. **Starting a server using REST call when the same server was already configured is discouraged.**

The [main configuration script](scripts/run.sh) will check which server configurations are already present and which need to be configured.

The configuration script for a server needs to be placed in `/home/jboss/scripts/config-<server-name>.sh` in the container image. The following environment variables can be used in the configuration scripts:
- `EGERIA_ENDPOINT`: the URL for the server platform
- `EGERIA_LOCAL_ENDPOINT`: the localhost URL for the server platform, use this as the target for curl requests during startup
- `EGERIA_USER`: a user that can make admin requests
- `EGERIA_COHORT`: cohort of the server platform
- `EGERIA_KAFKA_ENDPOINT`: URL of Kafka installation (see above)
- `EGERIA_VIEW_ORG`: organisation for view
- `EGERIA_OMAG_SERVER_NAME`: name of the OMAG Server (usually mds1)
- `EGERIA_OMAG_SERVER_URL`: URL of the OMAG Server (its platform url)

### Deploy an OMAG Server and a View Server

Use the following settings in `egeria-platform` helm chart:
- set `egeria.serverList` to `mds1,view1`
- set `egeria.omagServer.name` to `mds1` and `egeria.omagServer.platformUrl` to `` (an empty string will be replaced with the platform URL of the deployment)
- adjust `egeria.kafkaEndpoint` to use the correct Kafka address (see above)
- make sure that the correct image is used (this must contain `config-mds1.sh` and `config-view1.sh`)

Run
```
helm install egeria-platform ./egeria-platform
```
to create the Egeria platform with `mds1` and `view1` deployed.

### Deploy additional servers

The Helm chart can be used to deploy additional Server Platforms with different server types running on this platform. To do so, the following settings need to be adjusted in `values.yaml`:
- set `egeria.serverList` to the desired server types
- set `egeria.omagServer.name` to `mds1` and `egeria.omagServer.platformUrl` to `https://egeria-platform:9443` (the URL depends on the chart name used to deploy the OMAG server)
- adjust `egeria.kafkaEndpoint` to use the correct Kafka address (see above)
- provide additional environment variables that are required by configuration script via `extraEnv`
- provide additional secrets with environment variables by referencing a Kubernetes secret in `egeria-pull-secrets`. The secret will used as environment variable in the pod.
