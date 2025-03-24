{{- define "bootstrap.imageAutomation" }}

---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImageUpdateAutomation
metadata:
  name: image-update-automation
  namespace: {{ .namespace }}
spec:
  interval: 1m0s
  sourceRef:
    kind: GitRepository
    name: {{ include "bootstrap.gitRepoName" . }}
  git:
    checkout:
      ref:
        branch: {{ .branch }}
    commit:
      author:
        email: fluxcdbot@users.noreply.github.com
        name: fluxcdbot
      messageTemplate:  '{{"{{"}}range .Updated.Images{{"}}"}}{{"{{"}}println .{{"}}"}}{{"{{"}}end{{"}}"}}'
    push:
      branch: {{ .branch }}
  update:
    path: .
    strategy: Setters

{{- end }}
