{{- define "bootstrap.allManifests" }}

# Generate all manifests for sepcified environment

{{- /* Capture top level values: those provided by KubeIT and defaults */}}

{{- $values := .Values }}
{{- $tenantName := $values.tenantName }}
{{- $serviceAccount := (print $values.tenantName  "-flux-sa") }}
{{- $prodOrNonprod := $values.env }}

# Tenant: {{ $tenantName  }}
# Prod/NonProd: {{ $prodOrNonprod }}
# Short Region: {{ $values.shortRegion }}
# Cluster Colour: {{ $values.clusterColour }}


{{- /* Change scope to prod or nonprod depending on KubeIT provided values */}}
{{ with index .Values $prodOrNonprod }}

{{- /* Save values provided only at prod/nonprod level and defaults */}}
{{- $repoURL := print "ssh://" (.repoURL | default $values.repoURL) | replace "https://github.com" "git@github.com" | replace ":v3" "/v3" }}
{{- $fluxSshKeyVaultUrl := (.fluxSshKeyVaultUrl | default $values.fluxSshKeyVaultUrl) }}
{{- $branch := (.branch | default $values.branch) }}
{{- $workloadIdentityClientId := .workloadIdentityClientId }}


{{- /* Boolean defaults suck */}}
{{- $defaultUseImageAutomation := (hasKey . "useImageAutomation" | ternary .useImageAutomation $values.useImageAutomation) }}
{{- $useServiceMeshChartHelmRepository := (hasKey . "useServiceMeshChartHelmRepository" | ternary .useServiceMeshChartHelmRepository $values.useServiceMeshChartHelmRepository) }}

{{- /* Loop through all namespaces deployed to provided region and cluster colour*/}}
{{ range .environments }}
{{- if and
  (eq (.shortRegion|default $values.shortRegion) $values.shortRegion)
  (eq (.clusterColour|default $values.clusterColour) $values.clusterColour)
}}


{{- /* Dictionary of required values for templates*/}}
{{- $context := (dict
  "clusterColour" $values.clusterColour
  "tenantName" $tenantName
  "repoURL" $repoURL
  "workloadIdentityClientId" .workloadIdentityClientId
  "branch" (.branch | default $branch)
  "prodOrNonprod" $prodOrNonprod
  "shortRegion" $values.shortRegion
  "region" $values.region
  "serviceAccount" $serviceAccount
  "fluxSshKeyVaultUrl" $fluxSshKeyVaultUrl
  "namespace" .namespace
  "path" .path
  "pathTemplate" $values.pathTemplate
  "fluxSshSecretNameTemplate" ($values.fluxSshSecretNameTemplate | default "gitops-repo-key")
  "gitRepoNameTemplate" ( $values.gitRepoNameTemplate | default "tenant" )
  "kustomizationNameTemplate" ( $values.kustomizationNameTemplate | default "tenant")
  "Template" $.Template) }}

{{- include "bootstrap.gitRepository" $context }}


{{- include "bootstrap.kustomization" $context }}

{{- if (hasKey . "useServiceMeshChartHelmRepository" | ternary .useServiceMeshChartHelmRepository $useServiceMeshChartHelmRepository) }}
{{- include "bootstrap.serviceMeshChartHelmRepository" $context }}
{{- end }}

{{- if (hasKey . "useImageAutomation" | ternary .useImageAutomation $defaultUseImageAutomation) }}
{{- include "bootstrap.imageAutomation" $context -}}
{{- end }}

{{- include "bootstrap.sshKeySecrets" $context }}

{{ end }}
{{ end }}

{{ end }}
{{ end }}
