{{- define "platform-site.externalRoute" }}
{{- /* External routing */}}
{{- /* args for templates which look across sources */}}
{{- $routeName := include "platform-site.routeName" . }}

  # Routing for {{ printf "%s / version: %s" .serviceName .version }}
{{- $prefixes := .urlPrefixes }}

{{- /* mutually exclusive settings, exactPrefixMatch takes precedence */}}
{{- $exactPrefixMatch := .exactPrefixMatch }}
{{- $redirectOnTrailingSlash := and (not $exactPrefixMatch) (.redirectOnNoTrailingSlash) }}

{{- if $prefixes }}
{{- if $redirectOnTrailingSlash }}
{{- range $prefixes }}
{{- $slashPrefix := printf "/%s" . }}
  - name: {{ include "platform-site.redirectName" $ }}
    match:
      - uri:
          exact: {{ $slashPrefix }}
    redirect:
      uri: {{ $slashPrefix }}/
{{- end }} {{/* end range prefixes */}}
{{- end }} {{/* end redirect on no trailing slash */}}
  - name: {{ $routeName }}
    match:
{{- range $prefixes }}
{{- if hasPrefix "/" . }}
  {{ fail "url prefixes must not include leading slash"}}
{{- end }}
{{- $slashPrefix := printf "/%s" . }}
{{- if $exactPrefixMatch }}
    - uri:
        exact: {{ $slashPrefix }}
{{- end }}        
    - uri:
        prefix: {{ $slashPrefix }}/
{{- end }} {{- /* end range prefixes */}}
{{- end }} {{- /* end if prefixes */}}

{{- $istioMatch := .externalIstioMatch }}
{{- if $istioMatch }}
  - name: {{ $routeName }}
    match:
    #custom match
{{ $istioMatch | toYaml | indent 4 }}
{{- end }}  {{- /* end if externalIstioMatch */}}

{{- if not (or $prefixes $istioMatch) }}

  - name: catch-all-{{ $routeName }}
{{- end }}  {{- /* no prefix or istio match specification */}}

{{- if (.rewriteUrlPrefix).enabled }}
    rewrite:
      uri: {{ .rewriteUrlPrefix.replaceWith }}
      {{- /* required "rewrite replacement is required" $rewriteSettings.rewriteUrlPrefix.replaceWith */}}
{{- end }}
    route:
{{- if .route }}
  # Explicitly specified route
{{- .route | toYaml | indent 6 }}

{{- else }} {{- /* not explicit route */}}
{{ include "platform-site.routeDestination" . | indent 4 }} 
{{- end }} {{- /* end if explicit route */}}

{{- include "platform-site.commonOptions" . }}

{{- $corsPolicy := .corsPolicy }}

{{- if $corsPolicy }}
    corsPolicy:
{{ $corsPolicy | toYaml | indent 6 }}
{{- end }} {{- /* end if cors policy */ -}}
{{- end -}}
