{{- define "platform-site.destinationRule" }}
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: {{ .serviceName | replace "." "-" }}-destination
spec:
  host: {{ include "platform-site.qualifiedServiceName" . }}
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
  subsets:
{{- range .versions }}
  - name: {{ .version }}
{{- if .subsetDefinition }}
{{ .subsetDefinition | toYaml | indent 4 }}
{{- else }} {{- /* no subset definition override */}}
    labels:
      version: {{ .version }}
{{- end }} {{- /* end subsetDefinition */ -}}
{{- end }} {{- /* end range versions */ -}}
{{- end -}}
