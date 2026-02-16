{ config, pkgs, ... }:

let
  userSettings = rec {
    name = "Alexandros Karypidis";
    email = "1221101+karypid@users.noreply.github.com";
  };

  # used to source nix profile in case of single-user install
  # not needed for modern Fedora distrobox with official packages (where it is a do-nothing)
  nixSourcing = ''
    nix_sh="$HOME/.nix-profile/etc/profile.d/nix.sh"
    if [ -z "$NIX_PROFILES" ] && [ -e "$nix_sh" ]; then
      source "$nix_sh"
    fi
    # Start gnome-keyring daemon (Fedora path)
    if [ -z "$GNOME_KEYRING_CONTROL" ]; then
      eval "$(/usr/bin/gnome-keyring-daemon --start --components=secrets,ssh)"
    fi
  '';
  hostSourcing = ''
    # Source host aliases (adjust if your shell init differs)
    REPO_HOME=$DISTROBOX_HOST_HOME/devroot/wc.git
    if [[ -f "$DISTROBOX_HOST_HOME/.config/alx-shell/aliases.sh" ]]; then
      source "$DISTROBOX_HOST_HOME/.config/alx-shell/aliases.sh"
    fi
  '';

  shAliases = {
    mgs = "mgitstatus -d 3 $DISTROBOX_HOST_HOME/devroot/wc.git";
    mgsf = "mgitstatus -d 3 -f $DISTROBOX_HOST_HOME/devroot/wc.git";
    hmdiff = "nix profile diff-closures --profile ~/.local/state/nix/profiles/home-manager";
    hmnvd = "home-manager generations | head -n 2 | cut -d' ' -f 7 | tac | xargs nvd diff";
  };
in
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    direnv
    nix-direnv
    starship
    atuin

    nvd

    git
    mgitstatus
    helix

    mesa
    intel-media-driver
    libva-utils
    vulkan-tools

    zed-editor
    vscode
    xdg-utils

    pandoc
    (texlive.combine {
      inherit (texlive)
        scheme-medium      # ← includes xelatex, latexmk, most common packages
        xurl               # good for URLs in XeLaTeX

        tcolorbox          # provides tcolorbox.sty + dependencies
        environ            # required by tcolorbox
        trimspaces         # required by tcolorbox
        collectbox         # often pulled by tcolorbox for collect environment
        pdfcol
        upquote
        titling
        enumitem

        # These are commonly needed by nbconvert-generated .tex and prevent follow-up errors:
        parskip            # you're already using it in the log
        adjustbox
        fontspec           # unicode/font handling in XeLaTeX
        xcolor             # colors (used heavily)
        hyperref           # hyperlinks
        listings           # code listings
      ;
    })
  ];


  xdg = {
    enable = true;
  };

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
    initExtra = nixSourcing + hostSourcing;
    enableCompletion = true;
  };
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    # dotDir = "${config.xdg.configHome}/zsh";  # uncomment for new "xdg" location
    shellAliases = shAliases;
    initContent = nixSourcing + hostSourcing;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh.enable = true;
    oh-my-zsh.plugins = [ ];
    oh-my-zsh.theme = "";
    # oh-my-zsh.theme = "robbyrussell";
  };
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;   # or enableFishIntegration / etc.
    enableBashIntegration = true;
    settings = {
      records=true; # needed for history sync
      enter_accept=true;
      style = "compact";
      update_check = false;
      # do not enable dotfiles here, let home-manager deal with those
    };
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

  programs.chromium = {
    enable = true;
    package = pkgs.chromium;  # or pkgs.ungoogled-chromium if preferred
    commandLineArgs = [
      "--ozone-platform=wayland"                  # or --ozone-platform-hint=auto if you want fallback
      "--enable-features=Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,VaapiVideoDecoder,VaapiIgnoreDriverChecks"
      "--use-gl=angle"
      "--use-angle=vulkan"                        # ← key for Arc: forces Vulkan ANGLE backend
      "--enable-zero-copy"
      "--enable-gpu-rasterization"
    ];
  };
}
