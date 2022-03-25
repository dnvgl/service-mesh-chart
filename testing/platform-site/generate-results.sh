#!/bin/sh

rm results/*.yaml
echo `date` > results/run-date.txt
CHART="../../charts/platform-site"
echo $CHART

helm template test-release $CHART -n test-ns -f values.yaml --debug \
     > results/base-cases.yaml

# echo " *** kubeval results ***"
# kubeval --ignore-missing-schemas results/*.yaml
# echo " *** istioctl validation results ***"
# for f in $(ls results/*.yaml);
# do
#   echo istioctl validating $f;
#   cat $f | istioctl validate -f -
# done;
