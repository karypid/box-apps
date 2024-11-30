#!/bin/sh

_container=${1:-dbox-ubuntu-nix}
echo "Building image/container: $_container"

podman image build -t "$_container" .
DBX_CONTAINER_MANAGER=podman DBX_CONTAINER_ALWAYS_PULL=0 distrobox create --image $_container:latest --name $_container

distrobox enter -n "$_container" -- curl -L https://nixos.org/nix/install -o /tmp/nix-install
distrobox enter -n "$_container" -- sh /tmp/nix-install

../common/ptyxis-profile.sh -l "Nix" -n dbox-ubuntu-nix

