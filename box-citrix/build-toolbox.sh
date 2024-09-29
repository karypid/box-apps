#!/bin/sh

_container=${1:-tbox-citrix}
echo "Building image/container: $_container"

podman image build -t "$_container" . && \
	toolbox create -i "$_container:latest" "$_container"

# export apps to host
sh export-tbox.sh "$_container"

