#!/bin/sh

_container=${1:-tbox-dev-java}
echo "Building image/container: $_container"

podman image build -t "$_container" . && \
	toolbox create -i "$_container:latest" "$_container"

# 
toolbox run -c "$_container" -- sh /container/configure-container.sh

# export apps
../common/create-desktop-entry.sh --container $_container --exec /opt/alxclipse/eclipse --icon /opt/alxclipse/icon.xpm --name Alxclipse --wmclass Eclipse

