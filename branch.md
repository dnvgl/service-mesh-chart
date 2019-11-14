# Service Mesh Chart - Branch

## Branch purpose
This is the chart repository branch - this holds the published packages for platform service

## Building
The package build and publish process is currently manual:

1)	Checkout the master branch and (this) gh-branch in separate folders
2) Package, commit, and push

>In the example below I’m in the branch folder and the ../service-mesh-chart is the master branch of the repo

``` sh
helm package ../service-mesh-chart/helm/platform-service/ 
helm repo index .
git add .
git commit -m "chart version update"
git push
```
