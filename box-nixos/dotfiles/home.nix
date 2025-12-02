{ config, pkgs, ... }:

let
  userSettings = rec {
    name = "Alexandros Karypidis";
    email = "1221101+karypid@users.noreply.github.com";
  };
  # used to source nix profile
  nixSourcing = ''
    nix_sh="$HOME/.nix-profile/etc/profile.d/nix.sh"
    if [ -z "$NIX_PROFILES" ] && [ -e "$nix_sh" ]; then
      source "$nix_sh"
    fi
  '';
in
{
  home.packages = with pkgs; [
    mesa
    zed-editor

    riffdiff
    git
    mgitstatus

    direnv
    # nixdirenv
    starship
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user.name = userSettings.name;
      user.email = userSettings.email;
    };
    ignores = [
      ".direnv"
    ];
    #riff.enable = true;
  };

  programs.bash = {
    enable = true;
    initExtra = nixSourcing;
  };
  programs.zsh = {
    enable = true;
    initContent = nixSourcing;
  };

  programs.starship.enable = true;
  programs.direnv = {
    enable = true;
    # enableZshIntegration = true;
    nix-direnv.enable = true;
  };

}
