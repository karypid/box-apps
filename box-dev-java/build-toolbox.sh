#!/bin/sh

_container=${1:-tbox-dev-java}
echo "Building image/container: $_container"

podman image build -t "$_container" . && \
	toolbox create -i "$_container:latest" "$_container"

toolbox run -c "$_container" -- sh /opt/sdk/configure-container.sh

