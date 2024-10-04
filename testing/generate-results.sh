# Run helm template to allow comparing differences from run to run

rm results/*.yaml
echo `date` > results/run-date.txt

./generate-test-chart.sh \
     > results/base-case.yaml

./generate-test-chart.sh \
    --set gateway.exposeService=false \
    > results/not-exposed.yaml

./generate-test-chart.sh \
    --set sessionManagement.enabled=false \
    --show-only templates/deployment.yaml \
    > results/no-sessman.yaml

./generate-test-chart.sh \
    --set sessionManagement.redirectToLogin=true \
    --show-only templates/deployment.yaml \
    > results/sessman-with-redirect.yaml

./generate-test-chart.sh \
    --set mergeAppMetrics=true \
    --show-only templates/deployment.yaml \
    > results/mergeAppMetrics.yaml

./generate-test-chart.sh \
    --set deploymentOnly=true \
    > results/deployment-only.yaml

./generate-test-chart.sh \
    --set defaultRouting.enabled=false \
    > results/vs-default-routing-disabled.yaml

./generate-test-chart.sh \
    --set defaultRouting.retries.enabled=true \
    --show-only templates/virtualservice.yaml \
    > results/vs-with-retries.yaml

./generate-test-chart.sh \
    --set defaultRouting.allHosts=true \
    --show-only templates/virtualservice.yaml \
    > results/vs-all-hosts.yaml

./generate-test-chart.sh \
    --set defaultRouting.urlPrefixes= \
    --show-only templates/virtualservice.yaml \
    > results/vs-no-urlPrefixes.yaml

./generate-test-chart.sh \
    --set defaultRouting.rewriteUrlPrefix.enabled=false \
    --show-only templates/virtualservice.yaml \
    > results/vs-rewriteUrlPrefix-disabled.yaml

./generate-test-chart.sh \
    --set defaultRouting.redirectOnNoTrailingSlash=false \
    --show-only templates/virtualservice.yaml \
    > results/vs-no-slash-redirect.yaml

./generate-test-chart.sh \
    -f cors-policy-values.yaml \
    --show-only templates/virtualservice.yaml \
    > results/vs-cors-policy.yaml

./generate-test-chart.sh \
    --set defaultRouting.urlExactMatches[0]="url1",defaultRouting.urlExactMatches[0]="url2" \
    --show-only templates/virtualservice.yaml \
    > results/vs-exact-matches.yaml

./generate-test-chart.sh \
    --set defaultRouting.urlRegexes[0]="/api/.*" \
    --show-only templates/virtualservice.yaml \
    > results/vs-regexPrefixes.yaml

./generate-test-chart.sh \
    --set opa.enabled=true \
    --show-only templates/deployment.yaml \
    > results/opa-enabled.yaml

./generate-test-chart.sh \
    -f opa-resource-values.yaml \
    --set opa.enabled=true \
    --show-only templates/deployment.yaml \
    > results/opa-with-resources.yaml

./generate-test-chart.sh \
    --set image.full=alt-registry/alt-repo:alt-tag \
    --show-only templates/deployment.yaml \
    > results/full-image-syntax.yaml

./generate-test-chart.sh \
    --set image.fluxAutomation.enabled=true \
    > results/default-image-automation.yaml

./generate-test-chart.sh \
    --set image.fluxAutomation.enabled=true,image.fluxAutomation.filterTags.pattern='^dev-(?P<build>.*)',image.fluxAutomation.filterTags.extract='$build',image.fluxAutomation.policy.semver.range='> 0' \
    --show-only templates/image-policy.yaml \
    --show-only templates/image-repository.yaml \
    > results/image-automation-options.yaml

./generate-test-chart.sh \
    --set proxyResources.requests.cpu="1m",proxyResources.limits.cpu="2m",proxyResources.requests.memory="10Mi",proxyResources.limits.memory="20Mi" \
    --show-only templates/deployment.yaml \
    > results/proxy-resources.yaml

echo " *** kubeval results ***"
kubeval --ignore-missing-schemas results/*.yaml
echo " *** istioctl validation results ***"
for f in $(ls results/*.yaml);
do
  echo istioctl validating $f;
  cat $f | istioctl validate -f -
done;
