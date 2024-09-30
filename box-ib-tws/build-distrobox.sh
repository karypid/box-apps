#!/bin/sh

_container=${1:-dbox-ib-tws}
echo "Building image/container: $_container"

podman image build -t "$_container" . && \
    DBX_CONTAINER_MANAGER=podman DBX_CONTAINER_ALWAYS_PULL=0 distrobox create --image $_container:latest --name $_container

# Actual installation using logged in account's uid/gid
distrobox enter -n dbox-ib-tws -- sh /container/configure-container.sh stable
distrobox enter -n dbox-ib-tws -- sh /container/configure-container.sh latest

# export apps to host
# distrobox enter -n "$_container" -- distrobox-export --app Citrix

