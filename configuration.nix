# Edit this configuration file to define what should be installed on your system. Help is available in the configuration.nix(5) man page, on 
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{ imports = [ 
    ./hardware-configuration.nix 
    ./modules/neovim
    ./modules/python
  ];

  # anger stallman
  nixpkgs.config.allowUnfreePredicate = pkg: 
    builtins.elem (lib.getName pkg) [
      "google-chrome"
    ];

  # user packages
  environment.systemPackages = with pkgs; [
    # graphical programs
    firefox google-chrome

    # cli utils
    git wget psmisc htop ranger

    # sound
    pavucontrol pamixer

    # vanity
    neofetch pipes cmatrix

    # claude pwa
    (makeDesktopItem {
      name = "claude";
      exec = "google-chrome-stable --app=https://claude.ai";
      desktopName = "claude";
      categories = [ "Network" ];
    })
  ];

  # boot
  boot.loader.systemd-boot.enable = true; 
  boot.loader.efi.canTouchEfiVariables = true;

  # networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # time zone. 
  time.timeZone = "America/Denver";

  # fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ 
      "FiraCode"
      "ProggyClean"
      "BigBlueTerminal"
      ]; 
    })
  ];

  # wayland config
  environment.sessionVariables = {
     XDG_CURRENT_DESKTOP = "sway";
     XDG_SESSION_DESKTOP = "sway";
     XDG_SESSION_TYPE = "wayland";
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
  services.dbus.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock          # screen lock
      waybar            # system bar
      wofi              # dmenu but wayland
      kitty             # terminal
      grim              # screenshots
      slurp             # area selection w/ grim
      swayidle          # idle management
      brightnessctl     # brightness control
      wl-clipboard      # clipboard
    ];
  };

  # sound stuff: use pactl for volume control
  hardware.pulseaudio.enable=true;
  security.rtkit.enable = true;

  # note: pipewire needs to exist for the xdg portal
  # ... even though we dont use it for audio
  services.pipewire = {
    enable = true;
    jack.enable = false;
    pulse.enable = false;
    alsa.enable = false;
  };

  programs.bash = {
    completion.enable = true;
    promptInit = ''
    	PS1='\[\033[35m\]\w\[\033[0m\] λ '
    '';
  };

  # Enable touchpad support (enabled default in most desktopManager). 
  services.libinput.enable = true;
  services.openssh.enable = true;

  users.users.anon = {
    isNormalUser = true;
    extraGroups  = ["wheel" "networkmanager" "audio"];
    initialPassword = "anon";
  };

  # set a timeout for re-entering sudo pwd
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=120
  '';

  # NO TOUCH!
  system.copySystemConfiguration = true;
  system.stateVersion = "24.11";
}

