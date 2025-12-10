{{- define "bootstrap.kustomization" }}
---
{{- if .capabilities.APIVersions.Has "kustomize.toolkit.fluxcd.io/v1" }}
apiVersion: kustomize.toolkit.fluxcd.io/v1
{{- else }}
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
{{- end }}
kind: Kustomization
metadata:
  name: {{ include "bootstrap.kustomizationName" . }}
  namespace: {{ .namespace }}
spec:
  serviceAccountName: {{ .serviceAccount }}
  interval: 1m0s
  {{ $explicitPath := .path }}
  {{- if $explicitPath -}}
  path: {{ $explicitPath }}
  {{- else -}}
  path: {{ tpl (.pathTemplate | required "Path or path template required") . }}
  {{- end }}
  prune: true
  sourceRef:
    kind: GitRepository
    name: {{ include "bootstrap.gitRepoName" . }}
{{- end }}
