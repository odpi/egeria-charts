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

This directory currently contains two helm charts for Egeria, refer to the full source tree for any other additions.

## odpi-egeria-lab

This directory contains the 'lab' helm chart which creates a tutorial environment intended to show how
Egeria can be used to support the metadata needs of a small, hypothetical, pharmaceutical company known
as Coco Pharmecuticals. Configuration & demonstration is done through Jupyter Notebooks and Python.

Please refer to [odpi-egeria-lab/README.md] for more detailed information

## egeria-base

This directory contains a simpler helm chart which creates a basic egeria environment with
a single server preconfigured. This is a simpler environment than we use for coco, but is likely
useful for experimenting further with Egeria once you understand the tutorials.

Please refer to [egeria-base/README.md] for more detailed information.

## Additional Kubernetes related content

See also the https://github.com/odpi/egeria-k8s-operator repository for development of an Operator for Egeria.


----
License: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/),
Copyright Contributors to the ODPi Egeria project.
