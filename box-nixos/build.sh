
rm -fr ~/bx/mybox/{.profile,.bash*,.zsh*,.zprofile,.zcompdump,.nix*,.config,.local,.cache}
distrobox rm -f mybox
distrobox create -i quay.io/fedora/fedora-toolbox:43 --name mybox --home ~/bx/mybox --init

cp insert_imports.sh ~/bx/mybox/
cp -R dotfiles ~/bx/mybox/
distrobox enter mybox -- sh setup_box.sh

