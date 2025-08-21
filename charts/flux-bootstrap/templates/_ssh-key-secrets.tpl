{{- define "bootstrap.sshKeySecrets" }}
---
# Source: akv-secrets/templates/secret-sync.yaml
{{- if .Capabilities.APIVersions.Has "external-secrets.io/v1" }}
apiVersion: external-secrets.io/v1
{{- else }}
apiVersion: external-secrets.io/v1beta1
{{- end }}
kind: ExternalSecret
metadata:
  name: "secret-definition-sshkey"
  namespace: {{ .namespace }}
spec:
  refreshInterval: 5m
  secretStoreRef:
    name: "secret-store-{{ .tenantName }}-flux-sshkey"
    kind: SecretStore
  target:
    name: {{ include "bootstrap.fluxSshSecretName" . }}
    creationPolicy: Owner
  data:
    - secretKey: identity
      remoteRef:
        key: "sshkey--identity"
    - secretKey: identity.pub
      remoteRef:
        key: "sshkey--identity-pub"
    - secretKey: known_hosts
      remoteRef:
        key: "sshkey--known-hosts"
---

{{ $serviceAccount := "bootstrap-service-account" }}
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: {{ .workloadIdentityClientId }}
    azure.workload.identity/tenant-id: adf10e2b-b6e9-41d6-be2f-c12bb566019c
  name: {{ $serviceAccount }}
  namespace: {{ .namespace }}
---
# Source: akv-secrets/templates/secret-sync.yaml
{{- if .Capabilities.APIVersions.Has "external-secrets.io/v1" }}
apiVersion: external-secrets.io/v1
{{- else }}
apiVersion: external-secrets.io/v1beta1
{{- end }}
kind: SecretStore
metadata:
  name: "secret-store-{{ .tenantName }}-flux-sshkey"
  namespace: {{ .namespace }}
spec:
  provider:
    azurekv:
      authType: WorkloadIdentity
      vaultUrl: {{ .fluxSshKeyVaultUrl }}
      serviceAccountRef:
        name: {{ $serviceAccount }}
{{- end -}}
