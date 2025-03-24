# Flux Bootstrap Helm Chart

The Bootstrap Chart is designed to generate all necessary manifests for a specified environment. It captures top-level values provided by KubeIT and defaults, and dynamically adjusts configurations based on the environment (prod or nonprod/ green or blue).

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0+

## Installation


To use the Flux Bootstrap Chart as a library chart, you need to reference it via Helm chart dependency and include the template in your main chart.

### Step 1: Add Dependency

In your main chart's Chart.yaml, add the Bootstrap Chart as a dependency:

```
dependencies:
  - name: flux-bootstrap
    version: "0.0.1"
    repository: "https://github.com/dnvgl/service-mesh-chart/charts/flux-bootstrap"
```

### Step 2: Include Template
In your main chart's template file, reference the Bootstrap Chart's template:

# Generate all manifests for specified environment
{{- include "bootstrap.allManifests" . }}



## Configuration

The chart is configured using a values.yaml file. Below is an example configuration:

``
## KubeIT top level values
env: nonprod
region: eastus2
dnsDomain: "kubeit.dnv.com"
clusterSubdomain: "nonprod002"
clusterColour: "blue"
ingressType: "internal"
shortRegion: eus2
tenantName: <tenant>
targetRevision: main
repoURL: <repoUrl>
networkPlugin: azure
tenantMultiRegion: false
managementNamespace: "management-<tenant>"
workloadIdentityClientId: xxxx-xxx-xxx-xxxx-xxxx


## Tenant environment values
nonprod:
  environments:
  - namespace: spi-dev
    shortRegion: eus2
    clusterColour: green

prod:
  environments:
  - namespace: spi-prod
    shortRegion: eus2
    clusterColour: blue

``

## Template Structure

The main template file `all-manifests.tpl` includes the following section:

1. Top-level Values: Captures values provided by KubeIT passed via ArgoCD
2. Environment-Specific Values: Adjusts scope based on the environment (prod or nonprod)
3. Sub-templates: Includes sub-templates such as gitRepository, kustomization, serviceMeshChartHelmRepository, imageAutomation and sshKeySecrets

