sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon --yes
mkdir -p ~/.config/nix ; echo "experimental-features = nix-command flakes" | tee -a ~/.config/nix/nix.conf

. ~/.nix-profile/etc/profile.d/nix.sh

nix-channel --add https://github.com/NixOS/nixpkgs/archive/release-25.11.tar.gz nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install
sh insert_imports.sh ~/.config/home-manager/home.nix
rm -f ~/.bash_profile ~/.bashrc ~/.zshrc
home-manager switch

