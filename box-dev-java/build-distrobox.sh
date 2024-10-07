#!/bin/sh

_container=${1:-dbox-dev-java}
echo "Building image/container: $_container"

podman image build -t "$_container" . && \
    DBX_CONTAINER_MANAGER=podman DBX_CONTAINER_ALWAYS_PULL=0 distrobox create --image $_container:latest --name $_container

# Actual installation using logged in account's uid/gid
distrobox enter -n "$_container" -- sh /container/configure-container.sh
../common/create-desktop-entry.sh --container dbox-dev-java --exec /opt/alxclipse/eclipse --icon /opt/alxclipse/icon.xpm --name Alxclipse

