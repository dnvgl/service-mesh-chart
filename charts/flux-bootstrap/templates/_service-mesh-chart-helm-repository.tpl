{{- define "bootstrap.serviceMeshChartHelmRepository" }}
---
{{- if $.Capabilities.APIVersions.Has "source.toolkit.fluxcd.io/v1" }}
apiVersion: source.toolkit.fluxcd.io/v1
{{- else }}
apiVersion: source.toolkit.fluxcd.io/v1beta2
{{- end }}
kind: HelmRepository
metadata:
  name: service-mesh-chart
  namespace: {{ .namespace }}
spec:
  url: https://dnvgl.github.io/service-mesh-chart
  interval: 5m
{{- end }}
