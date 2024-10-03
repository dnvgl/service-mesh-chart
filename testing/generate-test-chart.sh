# Wrapper for helm command to generate chart. 
# Passes all parameters through to helm 
# Removes the chart version to avoid creating diffs on every file for every change
helm template test-release ../charts/platform-service -n test-ns -f values.yaml "$@" \
    | sed 's/platform-service-.*/platform-service-test/g' \
