{{- define "fineract-mifos.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "fineract-mifos.fullname" -}}
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

{{- define "fineract-mifos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "fineract-mifos.labels" -}}
helm.sh/chart: {{ include "fineract-mifos.chart" . }}
app.kubernetes.io/name: {{ include "fineract-mifos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "fineract-mifos.apiName" -}}
{{- printf "%s-api" (include "fineract-mifos.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "fineract-mifos.frontendName" -}}
{{- printf "%s-frontend" (include "fineract-mifos.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "fineract-mifos.apiSelectorLabels" -}}
app.kubernetes.io/name: {{ include "fineract-mifos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: api
{{- end -}}

{{- define "fineract-mifos.frontendSelectorLabels" -}}
app.kubernetes.io/name: {{ include "fineract-mifos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: frontend
{{- end -}}
