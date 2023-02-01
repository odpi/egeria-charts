{{/*
Expand the name of the chart.
*/}}
{{- define "egeria-react-ui.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "egeria-react-ui.fullname" -}}
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
{{- define "egeria-react-ui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "egeria-react-ui.labels" -}}
helm.sh/chart: {{ include "egeria-react-ui.chart" . }}
{{ include "egeria-react-ui.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "egeria-react-ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "egeria-react-ui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate the ConfigMap name for referencing in the subcharts
*/}}
{{- define "egeria-base.configMapName" -}}
{{- printf "%s-env" .Release.Name -}}
{{- end -}}
{{/*
End of generating the ConfigMap name for referencing in the subcharts
*/}}

{{/*
Create the name of the service account to use
*/}}
{{- define "egeria-react-ui.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "egeria-react-ui.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
