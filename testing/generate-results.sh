rm results/*.yaml
echo `date` > results/run-date.txt

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
     > results/base-case.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set gateway.exposeService=false \
    > results/not-exposed.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set sessionManagement.enabled=false \
    > results/no-sessman.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set sessionManagement.redirectToLogin=true \
    > results/sessman-with-redirect.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set deploymentOnly=true \
    > results/deployment-only.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.enabled=false \
    > results/vs-default-routing-disabled.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.retries.enabled=true \
    --show-only templates/virtualservice.yaml \
    > results/vs-with-retries.yaml


helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.allHosts=true \
    --show-only templates/virtualservice.yaml \
    > results/vs-all-hosts.yaml


helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.urlPrefixes= \
    --show-only templates/virtualservice.yaml \
    > results/vs-no-urlPrefixes.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.rewriteUrlPrefix.enabled=false \
    --show-only templates/virtualservice.yaml \
    > results/vs-rewriteUrlPrefix-disabled.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.redirectOnNoTrailingSlash=false \
    --show-only templates/virtualservice.yaml \
    > results/vs-no-slash-redirect.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    -f cors-policy-values.yaml \
    --show-only templates/virtualservice.yaml \
    > results/vs-cors-policy.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set defaultRouting.urlExactMatches[0]="url1",defaultRouting.urlExactMatches[0]="url2" \
    --show-only templates/virtualservice.yaml \
    > results/vs-exact-matches.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    --set opa.enabled=true \
    --show-only templates/deployment.yaml \
    > results/opa-enabled.yaml

helm template test-release ../charts/platform-service -n test-ns -f values.yaml \
    -f opa-resource-values.yaml \
    --set opa.enabled=true \
    --show-only templates/deployment.yaml \
    > results/opa-with-resources.yaml


echo " *** kubeval results ***"
kubeval --ignore-missing-schemas results/*.yaml
echo " *** istioctl validation results ***"
for f in $(ls results/*.yaml);
do
  echo istioctl validating $f;
  cat $f | istioctl validate -f -
done;
