<!-- SPDX-License-Identifier: CC-BY-4.0 -->
<!-- Copyright Contributors to the ODPi Egeria project. -->

# Egeria OMAG Server helm chart

## Description

The purpose of this chart is to demonstrate stand-alone OMAG server deployment for Kubernetes.
The deployment is based on Egeria main docker image. By modifying the default container entry point variable we are able to create new runtime environment similar to the platform deployment.

## How it works

The container application is configured using standard deployment and config map resources customized by setting the values in 'app' map in [values.yaml](values.yaml)

``````yaml
app:
  jarPath: "/deployments/server"
  jarName: "omag-server"
  loaderPath: "/deployments/server/lib"
  configPath: "/deployments/server/conf"
  configName: "cocoMDS1.yml"
  livenessProbe: "/actuator/health/livenessState"
  readinessProbe: "/actuator/health/readinessState"
``````

`app.jarPath` The path where the boot jar application is located inside the image.

`app.jarName` The name of the boot jar available on the `app.jarPath` location in the image.

`app.loaderPath` The spring boot application `LOADER_PATH`. This is the classpath location for Egeria connector libraries and additional third party libraries to be loaded at runtime.

`app.configPath` The location where configuration files will be located. Note this location is used as volume mount path inside the container.

`app.configName` The name of the configuration file (json or yaml) that will be loaded from `app.configPath` by the OMAG server instance on start-up.

`livenessProbe` and `readinessProbe` Standard kubernetes pod probes representing liveness and readiness states respectively.

For demo purpose, the chart contains example configuration files located in the [files](files) directory. The files placed here will be always copied as config map resources and mounted inside the container at location defined by `app.configPath`. From here, the server is trying to load the file defined by `app.configName` value.

For more details check out the [config.yaml](templates/config.yaml) and [deployment.yaml](templates/deployment.yaml) resources.


## Installation steps

### From helm repository

Add helm repo with name `egeria` (one-time)

```bash
helm repo add egeria https://github.com/odpi/egeria-charts.git
```

Once repo is added, pull latest chart versions

```bash
helm repo update
```

Install app instance with name `mds1` form chart with name `egeria-server`

```bash
helm install mds1 egeria/egeria-server 
```

### From local files

Clone the files with git and install app instance with name `mds1` using local chart located at `charts/egeria-server`

```bash
git clone https://github.com/odpi/egeria-charts.git
cd egeria-charts
helm install mds1 charts/egeria-server -f charts/egeria-server/values.yaml
```

### Uninstall the chart

```bash
helm uninstall mds1
```
