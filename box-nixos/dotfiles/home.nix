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

  shAliases = {
    mgs = "mgitstatus -d 3 $DISTROBOX_HOST_HOME/devroot/wc.git";
    mgsf = "mgitstatus -d 3 -f $DISTROBOX_HOST_HOME/devroot/wc.git";
    hmdiff = "nix profile diff-closures --profile ~/.local/state/nix/profiles/home-manager";
  };
in
{
  home.packages = with pkgs; [
    direnv
    nix-direnv
    starship

    git
    mgitstatus
    riffdiff
    helix

    mesa
    zed-editor

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
  };

  programs.bash = {
    enable = true;
    shellAliases = shAliases;
    initExtra = nixSourcing;
    enableCompletion = true;
  };
  programs.zsh = {
    enable = true;
    shellAliases = shAliases;
    initContent = nixSourcing;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
  programs.riff = {
    enable = true;
    enableGitIntegration = true;
  };

}
