#!/bin/bash
usage() {
    cat <<EOM
    Usage:
    $0 path-to-source

    path-to-source:
    The (local) path to the root service mesh chart folder.
    This almost always is a checkout of the master branch.
EOM
    exit 1
}

if [ $# == 0 ]; then
    usage;
fi

SRCPATH="${1}/helm/platform-service"
regex="platform-service-(.+)\.tgz"

RES=$(helm package $SRCPATH)

if [[ $RES =~ $regex ]]; then
    # echo "regex: $regex"
    # echo "res: $RES"
    VER=${BASH_REMATCH[1]}
    echo "Packaged version: $VER"
else
    echo "Error capturing version result - aborting"
    exit 1
fi

echo "Updating indexes..."
helm repo index .
echo "Updating git..."
git add .
git commit -m "Update chart to version $VER"
#git push
