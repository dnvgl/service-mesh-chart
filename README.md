# Service Mesh Chart

## Branch purpose
This is the chart repository branch - this holds the published packages for platform service

## Building
The package build and publish process is currently manual:

1)	Checkout the master branch and (this) gh-branch in separate folders
2)	Run stuff (note in the example below I’m in the branch folder and the ../service-mesh-chart is the master branch of the repo)

``` sh
CHART_VERSION="0.10.8"
helm package ../service-mesh-chart/helm/platform-service/ --version $CHART_VERSION
helm repo index .
git add .
git commit -m $CHART_VERSION
git push
```
