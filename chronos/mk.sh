#!/bin/bash

# Wait for the specified number of entries to show up for the
# specified SkyDNS name.
set -e

if [ "${#}" -ne 2 ]; then
    echo "usage: ${0} {chronos-version} {mesos-version}"
    echo ""
    echo "  If a deb package exists in CWD with {chronos-version} in the name,"
    echo "  it will be used, otherwise chronos will be pulled from the package"
    echo "  repositories."
    exit 1
fi

CHRONOS_VERSION=${1}
MESOS_VERSION=${2}

FULL_VERSION="chronos-$CHRONOS_VERSION-mesos-$MESOS_VERSION"
echo "$FULL_VERSION" > docker-tag

CHRONOS_PKG=$(shopt -s nullglob; echo chronos_*${CHRONOS_VERSION}*.deb)
if test -n "$CHRONOS_PKG"
then
  echo "building with local chronos package: ${CHRONOS_PKG}"
  cp chronos-local-template Dockerfile
  sed -i -e "s/CHRONOS_PKG/${CHRONOS_PKG}/g" Dockerfile
else
  echo "building with chronos from package repositories"
  cp chronos-template Dockerfile
  echo "CHRONOS_VERSION is set to ${CHRONOS_VERSION} in Dockerfile"
  sed -i -e "s/CHRONOS_VERSION/${CHRONOS_VERSION}/g" Dockerfile
fi

echo "MESOS_VERSION is set to ${MESOS_VERSION} in Dockerfile"
sed -i -e "s/MESOS_VERSION/${MESOS_VERSION}/g" Dockerfile

docker build -t "mesosphere/chronos:${FULL_VERSION}" .
echo "to push: \"docker push mesosphere/chronos:${FULL_VERSION}\""
rm -f Dockerfile
