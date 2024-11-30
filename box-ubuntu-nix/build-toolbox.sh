#!/bin/sh

_container=${1:-tbox-ubuntu-nix}
echo "Building image/container: $_container"

podman image build -t "$_container" .
toolbox create -i "$_container:latest" "$_container"

toolbox run -c "$_container" -- curl -L https://nixos.org/nix/install -o /tmp/nix-install
toolbox run -c "$_container" -- sh /tmp/nix-install

