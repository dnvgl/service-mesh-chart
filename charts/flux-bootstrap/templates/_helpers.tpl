{{- define "bootstrap.gitRepoName" }}
{{- tpl .gitRepoNameTemplate . }}
{{- end }}
{{- define "bootstrap.kustomizationName" }}
{{- tpl .kustomizationNameTemplate . }}
{{- end }}
{{- define "bootstrap.fluxSshSecretName" }}
{{- tpl .fluxSshSecretNameTemplate . }}
{{- end }}
