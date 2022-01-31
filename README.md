<!-- SPDX-License-Identifier: CC-BY-4.0 -->
<!-- Copyright Contributors to the Egeria project. -->

# Egeria helm charts for Kubernetes

**Refer to the full documentation on the [Egeria documentation site](https://odpi.github.io/egeria-docs/guides/operations/kubernetes/)** .

This repository manages helm chart definitions for Egeria. These are published automatically on build when the chart version
is incremented. The repository can be accessed by adding to your list of helm repositories via:

```shell
% helm repo add egeria https://odpi.github.io/egeria-charts
```

To list the available charts:

```shell
$ helm search repo egeria
NAME                  	CHART VERSION	APP VERSION	DESCRIPTION
egeria/egeria-base    	3.1.0        	           	Egeria simple deployment to Kubernetes
egeria/odpi-egeria-lab	3.1.0        	           	Egeria lab environment
```

For charts still being developed (or released, if later):

```shell
$ helm search repo egeria --devel                                                  [16:41:30]
NAME                  	CHART VERSION	APP VERSION	DESCRIPTION
egeria/egeria-base    	3.1.0        	           	Egeria simple deployment to Kubernetes
egeria/odpi-egeria-lab	3.1.0        	           	Egeria lab environment
```

To install a chart, a simple example would be our lab chart:

```shell
$ helm install egeria/odpi-egeria-lab lab
```

Refer to the **charts** directory for the chart content

## Additional Kubernetes related content

See also the https://github.com/odpi/egeria-k8s-operator repository for development of an Operator for Egeria.


----
License: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/),
Copyright Contributors to the ODPi Egeria project.
