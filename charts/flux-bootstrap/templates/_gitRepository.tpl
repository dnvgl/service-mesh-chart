{{- define "bootstrap.gitRepository" }}

---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: {{ include "bootstrap.gitRepoName" . }}
  namespace: {{ .namespace }}
spec:
  interval: 30s
  ref:
    branch: {{ .branch  }}
  url: {{ .repoURL }}
  secretRef:
    name: {{ include "bootstrap.fluxSshSecretName" . }}

{{- end }}
