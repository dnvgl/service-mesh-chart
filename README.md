# Service Mesh Chart

Opinionated Helm Chart for use with Kubernetes and Istio.

Created and maintained as part of the OneGateway project.

More information on usage to follow...

## Using

The recommended approach to using the platform-service chart is to reference it as a subchart:

### Create a Helm chart

Create your own Helm chart for your app (see the example-consumer folder in this repository for the format).

### Download the referenced platform service

1) Ensure that you reference the desired version of the service in the requirements.yaml
2) From the command line in your helm chart folder

``` sh
helm repo add platformteam https://dnvgl.github.io/service-mesh-chart/
helm dependency update
```

This will download a versioned tgz file into a charts subfolder.

*The requirements.lock and tgz files should be added to source control

## Development

### Testing

The current test approach involves generating output results with various inputs, and then manually validating the results against previous runs. Separate results are created for different test cases. New behavior should include additional test cases. Test cases are listed in the /testing/generate-reults.sh script.

Please run /testing/generate-results.sh and compare results to previous before submitting PR. Include the result output with the commit/PR.

### Version

The chart version is currently manually managed. Update the `version` in /charts/platform-service/Charts.yaml
