{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "platform-service.name" -}}
{{- default (required "app value is required" .Values.app) .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "platform-service.fullname" -}}
{{- $name := include "platform-service.name" . -}}
{{- $name := required "app value is required" .Values.app -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "platform-service.serviceName" -}}
  {{ include "platform-service.name" . }}
{{- end -}}


{{- define "platform-service.fullQualifiedServiceName" -}}
  {{ include "platform-service.name" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end -}}

{{- define "platform-service.imageRepository" -}}
{{- if .Values.image.full -}}
  {{ fail "image automation is incompatible with full image format" }}
{{- else if .Values.image.registry -}}
  {{ .Values.image.registry }}/{{ .Values.image.repository }}
{{- else -}}
  {{ .Values.image.repository }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "platform-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "appLabels" -}}
app: {{ required "app is required" .Values.app }}
app.kubernetes.io/name: {{ include "platform-service.name" . }}
helm.sh/chart: {{ include "platform-service.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
version: {{ .Values.version }}
{{- if $.Values.kubeit }}
{{- if $.Values.kubeit.tenantName }}
tenant: {{ $.Values.kubeit.tenantName }}
{{- end -}}
{{- end -}}

{{- if $.Values.podIdentityName }}
{{ $podIdentityName = .Values.podIdentityName }}
{{- end }}

{{- if $podIdentityName }}
aadpodidbinding: {{ $podIdentityName }}
{{- end }}
{{ if $.Values.volumes -}}
state: stateful
{{- end -}}
{{- end -}}
