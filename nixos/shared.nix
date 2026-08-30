{ config, lib, pkgs, ... }: {
  imports = [ 
    ./modules/docker
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # fierce tty setup
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "ter-u20b";
    packages = [ pkgs.kbd pkgs.terminus_font ];
    useXkbConfig = true;
  };

  environment.systemPackages = with pkgs; [
    # cli/dev utils
    man-pages man-pages-posix
    git wget psmisc htop pciutils lm_sensors lshw tmux ffmpeg unzip jq 
    kitty neovim ripgrep tree-sitter ranger
    
    # audio
    pavucontrol pamixer alsa-utils pulseaudio

    # silliness
    fastfetch pipes cmatrix cowsay lavat dysk

    # dev
    direnv 
    claude-code
    gcc cmake gnumake clang-tools
    python3 uv pyright python3Packages.ipython graphviz 
    nodejs bun deno
    lua lua-language-server
    rustc cargo rust-analyzer
    
    # wm
    hyprland
    grim slurp wl-clipboard      
    zathura yazi vanilla-dmz waybar wofi
    swaybg brightnessctl hypridle swaylock

    # gui
    firefox discord-ptb telegram-desktop mako 
    (google-chrome.override {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=UseOzonePlatform"
      ];
    })
    (pkgs.symlinkJoin {
      name = "spotify-wayland";
      paths = [ pkgs.spotify ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/spotify \
          --add-flags "--ozone-platform=wayland" \
          --add-flags "--enable-features=UseOzonePlatform"
      '';
    })
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.networkmanager.enable = true;
  time.timeZone = "America/Denver";

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.bigblue-terminal
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-color-emoji
    libertinus
  ];

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  services.dbus.enable = true;
  security.rtkit.enable = true;
  security.pam.services.swaylock = {};
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = false;
    histSize = 10000;

    shellAliases = {
      generations-list = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      generations-delete = "sudo nix-env --delete-generations +3";
      generations-gc = "sudo nix store gc";
      dev-hs = "nix develop ~/nixos/flakes/hs";
      dev-ts = "nix develop ~/nixos/flakes/ts";
      dev-py = "nix develop ~/nixos/flakes/py";
      dev-rust = "nix develop ~/nixos/flakes/rust";
      slippi = "nix run ~/nixos/flakes/slippi";
      workon = "source .venv/bin/activate";
      screenshot = "grim -g \"$(slurp)\"";
      screensaver = "pipes.sh -t 1 -r 20000 -p 5 -f 25 -c 5";
      open = "google-chrome-stable";
      claude = "claude --dangerously-skip-permissions";
      weather = "curl -s wttr.in/slc | head -n -3";
    };

    # zsh port of the snowflake λ prompt
    promptInit = ''
      autoload -U colors && colors
      setopt prompt_subst
      __prompt_nix_shell() { [ -n "$IN_NIX_SHELL" ] && echo "❄️ "; }
      PROMPT='%F{cyan}$(__prompt_nix_shell)%F{magenta}%~%f λ '
    '';

    interactiveShellInit = ''
      export PATH="$HOME/.scripts:$PATH"
      eval "$(direnv hook zsh)"
    '';
  };

  services.libinput.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
  };
  programs.ssh.startAgent = true;

  users.users.anon = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "audio"];
    shell = pkgs.zsh;
  };

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=120
  '';

  # NO TOUCH!
  system.stateVersion = "24.11";
}
