#!/bin/sh

_container=${1:-dbox-dev-java}
echo "Building image/container: $_container"

podman image build -t "$_container" . && \
    DBX_CONTAINER_MANAGER=podman DBX_CONTAINER_ALWAYS_PULL=0 distrobox create --image $_container:latest --name $_container

# Enter to use the user account's uid/gid to perform initial setup
distrobox enter -n "$_container" -- sh /container/configure-container.sh

# export apps
../common/create-desktop-entry.sh --container $_container --exec /opt/alxclipse/eclipse --icon /opt/alxclipse/icon.xpm --name Alxclipse --wmclass Eclipse

