{{/*
Expand the name of the chart.
*/}}
{{- define "egeria-lineage.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "egeria-lineage.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "egeria-lineage.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "egeria-lineage.labels" -}}
helm.sh/chart: {{ include "egeria-lineage.chart" . }}
{{ include "egeria-lineage.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "egeria-lineage.selectorLabels" -}}
app.kubernetes.io/name: {{ include "egeria-lineage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "egeria-lineage.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "egeria-lineage.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate names of the referenced objects in the subcharts (ConfigMap, Kafka, etc.)
*/}}
{{- define "egeria-base.configMapName" -}}
{{- printf "%s-env" .Release.Name -}}
{{- end -}}

{{- define "egeria-base.KafkaClusterName" -}}
{{- if .Values.global.kafka.external -}}
{{ printf "%s" .Values.global.kafka.clusterName }}
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

{{- define "egeria-base.JobName" -}}
{{- printf "%s-config" .Release.Name -}}
{{- end -}}

{{- define "egeria-lineage.JobName" -}}
{{- printf "%s-config" (include "egeria-lineage.name" .) -}}
{{- end -}}
{{/*
End of generating the ConfigMap name for referencing in the subcharts
*/}}

{{- define "egeria-lineage.security" -}}
serviceAccountName: {{ template "egeria-lineage.serviceAccountName" . }}

{{- end }}
