# egeria-presentation

This repository is based on https://github.com/odpi/egeria-charts, but it only deploys the Egeria UI. This chart assumes that the platform of the view server was deployed using [egeria-platform](../egeria-platform/README.md).

## Deploy Egeria UI

Use the following settings in `egeria-presentation` helm chart:
- set `egeria.platformConfigMap` to the configmap of the Egeria OMAG deployment (here `egeria-platform-config`)
- set `egeria.viewOrg` to the same viewOrg as the OMAG deployment (here `org`)
- set `egeria.viewServerPlatformUrl` to the Egeria platform URL of `view1` (here `https://egeria-platform:9443`)

Run
```
helm install presentation ./egeria-presentation
```
to create the Egeria UI deployment.