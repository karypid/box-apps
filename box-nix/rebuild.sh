#!/bin/bash

NAME=nixbox

rm -fr ~/bx/$NAME/{.profile,.bash*,.zsh*,.zprofile,.zcompdump,.nix*,.config,.local,.cache}

# recreate
distrobox rm -f $NAME
distrobox create -i quay.io/fedora/fedora-toolbox:43 --name $NAME --home ~/bx/$NAME --init --additional-packages "systemd"

# instlal nix package manager
distrobox enter $NAME -- sudo dnf install -y nix nix-daemon
distrobox enter $NAME -- sudo systemctl enable --now nix-daemon

# install home manager
echo "Initializing home-manager (vanilla)..."
distrobox enter $NAME -- nix shell home-manager#home-manager --command home-manager init
echo "Installing home-manager (vanilla)..."
distrobox enter $NAME -- nix shell home-manager#home-manager --command home-manager switch

# install personal home manager programs
echo "Installing home-manager (customized)..."
cp box-home.nix ~/bx/$NAME/.config/home-manager/box-home.nix
distrobox enter $NAME -- zsh -l -c 'F=$HOME/.config/home-manager/home.nix; (head -n -1 "$F" && echo "  imports = [ ./box-home.nix ];" && tail -n 1 "$F") > /tmp/h.nix && mv /tmp/h.nix "$F" && home-manager switch -b hm-old'

