#!/bin/sh

_version=${1:-2025-03}
_container=${1:-dbox-dev-java}
echo "Building version: $_version"
echo "Building image/container: $_container"

BOX_HOME=~/bx/$_container

podman image build -t "$_container" --build-arg ALXVER="${_version}" . && \
    DBX_CONTAINER_ALWAYS_PULL=0 distrobox create --image $_container:latest --name $_container --home $BOX_HOME || exit 1

# Enter to use the user account's uid/gid to perform initial setup
distrobox enter -n "$_container" -- sh /container/configure-container.sh || exit 1

# export apps
echo Creating desktop entry...
../common/create-desktop-entry.sh --container $_container --exec "env WEBKIT_DISABLE_COMPOSITING_MODE=1 /opt/alxclipse/eclipse" --icon /opt/alxclipse/icon.xpm --name AlxclipseDbox --wmclass Eclipse

../common/ptyxis-profile.sh -l "Java Dev" -n dbox-dev-java

