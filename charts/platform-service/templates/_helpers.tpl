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

{{ $podIdentityName := "" }}
{{- if $.Values.kubeit }}
{{- if $.Values.kubeit.tenantPodIdentityName }}
{{ $podIdentityName = .Values.kubeit.tenantPodIdentityName }}
{{- end }}
{{- end }}

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

{{- define "retries" -}}
{{- if $.Values.defaultRouting.retries.enabled }}
retries:
{{- if $.Values.defaultRouting.retries.settings }}
{{ $.Values.defaultRouting.retries.settings | toYaml | trim | indent 2 }}
{{- else }}
   attempts: 3
   perTryTimeout: 2s
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "platform-service.virtualserviceContent" -}}
{{- $prefixes := default (list $.Values.app) $.Values.defaultRouting.urlPrefixes }}
{{- $regexes := $.Values.defaultRouting.urlRegexes }}
http:
{{- if $.Values.defaultRouting.urlExactMatches }}
  - match:
  {{- range $.Values.defaultRouting.urlExactMatches }}
  {{- if hasPrefix "/" . }}
    {{ fail "url matches must not include leading slash"}}
  {{- end}}
  {{- $slashMatch := printf "/%s" . }}
    - uri:
        exact: {{ $slashMatch }}
    - uri:
        prefix: {{ $slashMatch }}/
  {{- end }}
  # routes to service
    route:
    - destination:
        host: {{ include "platform-service.fullQualifiedServiceName" $ | quote }}
{{- if $.Values.defaultRouting.corsPolicy }}
  corsPolicy:
{{ $.Values.defaultRouting.corsPolicy | toYaml | trim | indent 4 }}
{{- end }}
{{- end }}

{{- if $.Values.defaultRouting.redirectOnNoTrailingSlash }}
  # redirect on prefixes without trailing slashes
  {{- range $prefixes }}
  {{- $slashPrefix := printf "/%s" . }}
  - match:
    - uri:
        exact: {{ $slashPrefix }}
    redirect:
      uri: {{ $slashPrefix }}/
  {{- end}}
{{- end}}
  # routes to service
  - route:
    - destination:
        host: {{ include "platform-service.fullQualifiedServiceName" $ | quote }}
{{- if $.Values.defaultRouting.corsPolicy }}
  corsPolicy:
{{ $.Values.defaultRouting.corsPolicy | toYaml | trim | indent 4 }}
{{- end -}}

  {{- if not $.Values.defaultRouting.catchAll }}
    match:
    {{- range $prefixes }}
    {{- if hasPrefix "/" . }}
      {{ fail "url prefixes must not include leading slash"}}
    {{- end}}
    {{- $slashPrefix := printf "/%s" . }}
    - uri:
        prefix: {{ $slashPrefix }}/
    {{- end }}
    {{- range $regexes }}
    - uri:
        regex: {{ . }}
    {{- end }}
  {{- end }}
{{- if $.Values.defaultRouting.rewriteUrlPrefix.enabled }}
    rewrite:
      uri: {{ required "rewriteUri is required" $.Values.defaultRouting.rewriteUrlPrefix.replaceWith }}
{{- end}}
    # deprecated
    headers:
      request:
        add:
          x-appname: {{ first $prefixes }}
{{- include "retries" $ | indent 4 }}
{{- end -}}
