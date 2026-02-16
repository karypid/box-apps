#!/bin/bash

NAME=dbox-dev-nix
BOX_HOME=~/bx/$NAME

rm -fr $BOX_HOME/{.profile,.bash*,.zsh*,.zprofile,.zcompdump,.nix*,.config,.local,.cache,.ssh}
# keyring
mkdir -p $BOX_HOME/.local/share/keyrings
cp resources/default $BOX_HOME/.local/share/keyrings
cp resources/Login.keyring $BOX_HOME/.local/share/keyrings
# prepare for xauth
touch $BOX_HOME/.Xauthority
chmod 600 $BOX_HOME/.Xauthority
# add ssh keys
ln -s $HOME/.ssh $BOX_HOME/.ssh

# recreate
distrobox rm -f $NAME
distrobox create -i quay.io/fedora/fedora-toolbox:43 --name $NAME --home $BOX_HOME --init --additional-packages "systemd gnome-keyring gnome-keyring-pam seahorse dbus-tools"

# install nix package manager
distrobox enter $NAME -- sudo dnf install -y nix nix-daemon
distrobox enter $NAME -- sudo systemctl enable --now nix-daemon

# install home manager
echo "Initializing home-manager (vanilla)..."
distrobox enter $NAME -- nix shell home-manager#home-manager --command home-manager init
echo "Installing home-manager (vanilla)..."
distrobox enter $NAME -- nix shell home-manager#home-manager --command home-manager switch

# install personal home manager programs
echo "Installing home-manager (customized)..."
cp resources/box-home.nix ~/bx/$NAME/.config/home-manager/box-home.nix
distrobox enter $NAME -- zsh -l -c 'F=$HOME/.config/home-manager/home.nix; (head -n -1 "$F" && echo "  imports = [ ./box-home.nix ];" && tail -n 1 "$F") > /tmp/h.nix && mv /tmp/h.nix "$F" && home-manager switch -b hm-old'

# add xauth for host
LINE=$( xauth list | grep $( hostname ) )
if [ -n "$LINE" ]; then
  COOKIE=$(echo "$LINE" | awk '{print $3}')
  distrobox enter $NAME -- xauth add :0  MIT-MAGIC-COOKIE-1  $COOKIE
fi

# c++/java
distrobox enter $NAME -- zsh -l -c 'code --install-extension ms-vscode.cpptools'
distrobox enter $NAME -- zsh -l -c 'code --install-extension ms-vscode.cmake-tools'
distrobox enter $NAME -- zsh -l -c 'code --install-extension vscjava.vscode-java-pack'
# python/jupyter extensions
distrobox enter $NAME -- zsh -l -c 'code --install-extension ms-python.python'
distrobox enter $NAME -- zsh -l -c 'code --install-extension ms-toolsai.jupyter'
distrobox enter $NAME -- zsh -l -c 'code --install-extension donjayamanne.vscode-jupytext'
distrobox enter $NAME -- zsh -l -c 'code --install-extension ms-toolsai.datawrangler'
distrobox enter $NAME -- zsh -l -c 'code --install-extension mechatroner.rainbow-csv'

# core tools
distrobox enter $NAME -- zsh -l -c 'code --install-extension continue.continue'
distrobox enter $NAME -- zsh -l -c 'code --install-extension mkhl.direnv'

# desktop entry with launcher for VSCode and icon on host
cp resources/nix-vscode.svg $HOME/.local/share/icons/nix-vscode.svg
sed "s/BOX_NAME/${NAME}/g" "resources/dbox-nix-vscode-aut.desktop" > ~/.local/share/applications/dbox-nix-vscode-aut.desktop
echo Icon=$HOME/.local/share/icons/nix-vscode.svg >> ~/.local/share/applications/dbox-nix-vscode-aut.desktop

