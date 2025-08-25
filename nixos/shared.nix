{ config, lib, pkgs, ... }: {
  imports = [ 
    # ./modules/neovim
    ./modules/docker
    # ./modules/python
    # ./modules/scripts
    # ./modules/cuda
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
    # graphical user programs
    firefox 
    (google-chrome.override {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=UseOzonePlatform"
      ];
    })
    telegram-desktop 
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

    # cli utils
    git wget psmisc htop ranger pciutils lshw tmux

    # audio
    pavucontrol pamixer alsa-utils pulseaudio

    # vanity
    neofetch pipes cmatrix cowsay

    # Global dev tools
    gcc

    # Python
    python3 uv poetry pyright
    python3Packages.ipython
    
    # JavaScript/TypeScript
    nodejs_20 bun deno
    nodePackages.pnpm
    nodePackages.typescript

    # lua
    lua-language-server
    
    # Rust
    rustc cargo rust-analyzer
    
    # LaTeX
    tree-sitter
    texlive.combined.scheme-full
    zathura
    
    # Hyprland (parallel install with Sway for migration)
    hyprland
    vanilla-dmz       # cursor icons
    kitty             # terminal
    waybar            # system bar
    wofi              # dmenu but wayland
    grim              # screenshots
    slurp             # area selection w/ grim
    hypridle          # idle management
    swaybg            # wallpaper
    brightnessctl     # brightness control
    wl-clipboard      # clipboard
    swaylock          # screen locker

    # neovim
    neovim
    ripgrep
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
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-emoji
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

  programs.bash = {
    shellAliases = {
      lah = "ls -lah";
      generations-list = ''
        sudo nix-env -p /nix/var/nix/profiles/system --list-generations
      '';
      generations-delete = ''
        sudo nix-env --delete-generations +3
      '';
      generations-gc = ''
        sudo nix store gc
      '';
      dev-hs = ''
        nix develop ~/nixos/flakes/hs
      '';
      dev-ts = ''
        nix develop ~/nixos/flakes/ts
      '';
      dev-py = ''
        nix develop ~/nixos/flakes/py
      '';
      dev-rust = ''
        nix develop ~/nixos/flakes/rust
      '';
      dev-claude = ''
        nix develop ~/nixos/flakes/claude
      '';
    };
    completion.enable = true;
    promptInit = ''
      __prompt_nix_shell() {
        if [ -n "$IN_NIX_SHELL" ]; then
          echo "❄️ "  # Snowflake for Nix
        fi
      }
      PS1='\[\033[36m\]$(__prompt_nix_shell)\[\033[35m\]\w\[\033[0m\] λ '
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
  };

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=120
  '';

  # NO TOUCH!
  system.stateVersion = "24.11";
}
