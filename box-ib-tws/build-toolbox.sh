#!/bin/sh

_container=${1:-dbox-ib-tws}
echo "Building image/container: $_container"

podman image build -t "$_container" . && \
    toolbox create -i "$_container:latest" "$_container"

# Actual installation using logged in account's uid/gid
toolbox run -c tbox-ib-tws -- sh /container/configure-container.sh stable
toolbox run -c tbox-ib-tws -- sh /container/configure-container.sh latest

# export apps to host
# sh export-tbox.sh "$_container"

