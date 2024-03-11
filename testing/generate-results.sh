# Run helm template to allow comparing differences from run to run
# Replaces chart version with `test` to avoid creating diffs on every file for every change

rm results/*.yaml
echo `date` > results/run-date.txt

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
     > results/base-case.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set gateway.exposeService=false \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/not-exposed.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set sessionManagement.enabled=false \
    --show-only templates/deployment.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/no-sessman.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set sessionManagement.redirectToLogin=true \
    --show-only templates/deployment.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/sessman-with-redirect.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set mergeAppMetrics=true \
    --show-only templates/deployment.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/mergeAppMetrics.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set deploymentOnly=true \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/deployment-only.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.enabled=false \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/vs-default-routing-disabled.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.retries.enabled=true \
    --show-only templates/virtualservice.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/vs-with-retries.yaml


helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.allHosts=true \
    --show-only templates/virtualservice.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/vs-all-hosts.yaml


helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.urlPrefixes= \
    --show-only templates/virtualservice.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/vs-no-urlPrefixes.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.rewriteUrlPrefix.enabled=false \
    --show-only templates/virtualservice.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/vs-rewriteUrlPrefix-disabled.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.redirectOnNoTrailingSlash=false \
    --show-only templates/virtualservice.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/vs-no-slash-redirect.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    -f cors-policy-values.yaml \
    --show-only templates/virtualservice.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/vs-cors-policy.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.urlExactMatches[0]="url1",defaultRouting.urlExactMatches[0]="url2" \
    --show-only templates/virtualservice.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/vs-exact-matches.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.urlRegexes[0]="/api/.*" \
    --show-only templates/virtualservice.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/vs-regexPrefixes.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set opa.enabled=true \
    --show-only templates/deployment.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/opa-enabled.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    -f opa-resource-values.yaml \
    --set opa.enabled=true \
    --show-only templates/deployment.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/opa-with-resources.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set image.full=alt-registry/alt-repo:alt-tag \
    --show-only templates/deployment.yaml \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/full-image-syntax.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set image.fluxAutomation.enabled=true \
    --debug \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/default-image-automation.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set image.fluxAutomation.enabled=true,image.fluxAutomation.filterTags.pattern='^dev-(?P<build>.*)',image.fluxAutomation.filterTags.extract='$build',image.fluxAutomation.policy.semver.range='> 0' \
    --show-only templates/image-policy.yaml \
    --show-only templates/image-repository.yaml \
    --debug \
    | sed 's/platform-service-.*/platform-service-test/g' \
    > results/image-automation-options.yaml

echo " *** kubeval results ***"
kubeval --ignore-missing-schemas results/*.yaml
echo " *** istioctl validation results ***"
for f in $(ls results/*.yaml);
do
  echo istioctl validating $f;
  cat $f | istioctl validate -f -
done;
