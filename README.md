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
$ helm install lab egeria/odpi-egeria-lab
```

Refer to the **charts** directory for the chart content
## Snippets / Configuration

The *config/values* directory contains snippets of yaml that can be used to deploy Egeria in a Kubernetes environment. These are provided as examples, and commented within each file. Review each change, and note that the content may need updating, ie with new versions.

Each yaml file sets 'values' which will change the behaviour of the chart

Files are prefixed with a short name relating to the chart (ie `lab-` for odpi-egeria-lab) and then a description of the configuration. 

There may also be other files present which, whilst not helm snippets, may be useful in your configurations. these being found in *config/other*

To use one of these snippets you will need to download the yaml file, and you can then use with an install like:
```shell
$ helm install lab egeria/odpi-egeria-lab -f <path to yaml file>
```

You can also use the '--set' and '--set-string' options of helm, however with multiple settings this leads to a complex command, so use of these configuration files is recommended.

You should also not place these files within the git source repo (unless you are contributing them!) as it may cause conflicts when retrieving any git updates.

You can review the full set of configurable values for each chart by issuing a command such as:
```shell
helm show values egeria/odpi-egeria-lab
```

## Additional Kubernetes related content

See also the https://github.com/odpi/egeria-k8s-operator repository for development of an Operator for Egeria.


----
License: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/),
Copyright Contributors to the ODPi Egeria project.
