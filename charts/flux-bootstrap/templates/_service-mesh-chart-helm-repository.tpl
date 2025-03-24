{{- define "bootstrap.serviceMeshChartHelmRepository" }}
---
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: service-mesh-chart
  namespace: {{ .namespace }}
spec:
  url: https://dnvgl.github.io/service-mesh-chart
  interval: 5m
{{- end }}
