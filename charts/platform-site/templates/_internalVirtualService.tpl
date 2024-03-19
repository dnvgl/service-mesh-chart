{{- define "platform-site.internalVirtualService" }}
{{- $qualifiedServiceName := include "platform-site.qualifiedServiceName" . }}
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: {{ $.releaseName }}-{{ .serviceName | replace "." "-" }}-internal-routes
spec:
  hosts:
  - {{ $qualifiedServiceName }}
  gateways:
  - mesh
  http:
{{- range .versions }}
{{- /* args for templates which look across sources */}}
{{- $versionValues := (. | deepCopy) | mustMergeOverwrite ($ | deepCopy) }} 

{{- $sanitizedVersion := .version | replace "." "-" }}
  - name: {{ include "platform-site.routeName" $versionValues }}
  {{- $match := $versionValues.internalMatch }}
  {{- if $match }}
    match:
{{ $match | toYaml | indent 4 }}
  {{- end }}
    route:
{{ include "platform-site.routeDestination" $versionValues | indent 4 }} 
{{- include "platform-site.commonOptions" $versionValues }}
{{- end }} {{/* end range versions */}}
{{- end -}}
