#!/bin/sh

_container=${1:-dbox-dev-java}
echo "Building image/container: $_container"

podman image build -t "$_container" . && \
    DBX_CONTAINER_MANAGER=podman DBX_CONTAINER_ALWAYS_PULL=0 distrobox create --image $_container:latest --name $_container

# Actual installation using logged in account's uid/gid
distrobox enter -n "$_container" -- sh /opt/sdk/configure-container.sh

