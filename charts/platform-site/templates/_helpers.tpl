{{/*
Expand the name of the chart.
*/}}
{{- define "platform-site.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "platform-site.fullname" -}}
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
{{- define "platform-site.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "platform-site.labels" -}}
helm.sh/chart: {{ include "platform-site.chart" . }}
{{ include "platform-site.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "platform-site.selectorLabels" -}}
app.kubernetes.io/name: {{ include "platform-site.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "platform-site.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "platform-site.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "platform-site.retries" -}}
{{- if .retries.enabled }}
    retries:
{{- if .retries.settings }}
{{ .retries.settings | toYaml | trim | indent 6 }}
{{- else }}
      attempts: 3
      perTryTimeout: 2s
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "platform-site.serviceName" -}}
{{ .service | replace "." "-" }}
{{- end -}}



{{- define "platform-site.externalMatcher" }}
{{- if .externalMatch }}
  # Explicitly specified match criteria
    match:
{{- default .externalMatch | toYaml | indent 4 }}
{{- else if .externalMatchConfig }}
{{- if not .externalMatchConfig.catchAll }}
    match:
{{- if .externalMatchConfig.urlExactMatches }} {{- /* match config types */ -}}
  # Exact matches
  {{- range .externalMatchConfig.urlExactMatches }}
  {{- if hasPrefix "/" . }}
    {{ fail "url matches must not include leading slash"}}
  {{- end }}
  {{- $slashMatch := printf "/%s" . }}
    - uri:
        exact: {{ $slashMatch }}
    - uri:
        prefix: {{ $slashMatch }}/
  {{- end -}} {{- /* end range urls */ -}}

{{- else }} {{- /* match config types */ -}}
  # prefix routing

{{- $prefixes := default (list $.Values.service) .externalMatchConfig.urlPrefixes }}
{{- $redirectOnTrailingSlash := .externalMatchConfig.redirectOnNoTrailingSlash }}

{{- range $prefixes }}
{{- if hasPrefix "/" . }}
  {{ fail "url prefixes must not include leading slash"}}
{{- end}}
{{- $slashPrefix := printf "/%s" . }}

{{- if $redirectOnTrailingSlash }}
    - name: "redirect-nts-{{ . }}"
      uri:
        exact: {{ $slashPrefix }}
    redirect:
      uri: {{ $slashPrefix }}/
  # Set up for next match
    match:
{{- end}} {{- /* end redirect on no trailing slash */ -}}

    - name: "prefix-{{ . }}"
      uri:
        prefix: {{ $slashPrefix }}/
{{- end }} {{- /* end range prefixes */ -}}
{{- end }} {{- /* end match types */ -}}
{{- else }} {{- /* catch all case */ -}}
  # No match conditions for catch-all route
  {{- /* don't do this for now since there are variable scoping complications }}
  {{- if $catchAllRouteDefined }}
    {{ fail "only one catch-all route may be defined"}}
  {{- end }}
  {{- $catchAllRouteDefined := true }}
  {{ */ -}}
{{- end }} {{- /* end else catch all */ -}}
{{- end }} {{- /* end match vs match config */ -}}
{{- end }} {{- /* end define */ -}}


{{- define "platform-site.internalMatcher" }}
{{- if .internalMatch }}
    match:
{{- default .internalMatch | toYaml | indent 4 }}
{{- end }}
{{- end }}
