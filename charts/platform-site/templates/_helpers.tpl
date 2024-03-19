
{{/*
Fully qualified service name given standard values dictionary
*/}}
{{- define "platform-site.qualifiedServiceName" -}}
{{- printf "%s.%s.svc.cluster.local" .serviceName .namespace }}
{{- end }}


{{/*
Base route name given standard values dictionary
*/}}
{{- define "platform-site.routeName" -}}
{{ printf "%s-%s-route" (.serviceName | replace "." "-") (.version | replace "." "-") }}
{{- end }}

{{/*
Base redirect name given standard values dictionary
*/}}
{{- define "platform-site.redirectName" -}}
{{ printf "%s-%s-redirect" (.serviceName | replace "." "-") (.version | replace "." "-") }}
{{- end }}


{{- define "platform-site.commonOptions" -}}

{{- $timeout := .timeout }}
{{- if $timeout }}
    timeout: {{ $timeout }}
{{- end }}

{{- if (.retries).enabled }}
    retries:
{{ .retries.settings | toYaml | indent 6 }}
{{- end }}
{{- end -}}
