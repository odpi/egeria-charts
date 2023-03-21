{{/* <!-- SPDX-License-Identifier: Apache-2.0 --> */}}
{{/* Copyright Contributors to the Egeria project. */}}{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "egeria-base.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "egeria-base.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "egeria-base.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "egeria-base.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "egeria-base.name" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Generate the names of the kafka resources (cluster, namespace, bootstrap)
*/}}
{{- define "egeria-base.KafkaClusterName" -}}
{{- if .Values.global.kafka.external -}}
{{- printf "%s" .Values.global.kafka.clusterName -}}
{{- else -}}
{{- printf "%s-strimzi" .Release.Name -}}
{{- end -}}
{{- end -}}

{{- define "egeria-base.KafkaClusterNamespace" -}}
{{- if .Values.global.kafka.external -}}
{{- printf "%s" .Values.global.kafka.namespace -}}
{{- else -}}
{{- printf "%s" .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{- define "egeria-base.KafkaClusterEndpoint" -}}
{{- if .Values.global.kafka.external -}}
{{- printf "%s:%s" .Values.global.kafka.externalBootstrap .Values.global.kafka.listenerPort -}}
{{- else -}}
{{- printf "%s-strimzi-kafka-bootstrap:9092" .Release.Name -}}
{{- end -}}
{{- end -}}
{{/*
End of generating the names of the kafka resources (cluster, namespace, bootstrap)
*/}}

{{/*
Generate names of the referenced objects in the subcharts
*/}}
{{- define "egeria-base.configMapName" -}}
{{- printf "%s-env" .Release.Name -}}
{{- end -}}

{{- define "egeria-base.JobName" -}}
{{- printf "%s-config" .Release.Name -}}
{{- end -}}
{{/*
End of generating the ConfigMap name for referencing in the subcharts
*/}}


{{- define "egeria.security" -}}
serviceAccountName: {{ template "egeria-base.serviceAccountName" . }}

{{- end }}
