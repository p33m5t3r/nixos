# Edit this configuration file to define what should be installed on your system. Help is available in the configuration.nix(5) man page, on 
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{ imports =
    [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfreePredicate = pkg: 
    builtins.elem (lib.getName pkg) [
      "google-chrome"
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

  # Enable touchpad support (enabled default in most desktopManager). 
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’. users.users.alice = {
  #   isNormalUser = true; extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user. packages = with pkgs; [
  #     tree ];
  # };
  users.users.anon = {
    isNormalUser = true;
    extraGroups  = ["wheel" "networkmanager" "audio"];
    initialPassword = "anon";
  };

  # List packages installed in system profile. To search, run: $ nix search wget environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default. wget
  # ];
  environment.systemPackages = with pkgs; [
    neovim
    vim
    wget
    git
    firefox
    google-chrome

    pavucontrol pamixer
    psmisc # killall
    htop
  ];

  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true; programs.gnupg.agent = {
  #   enable = true; enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon. 
  services.openssh.enable = true;

  # Open ports in the firewall. networking.firewall.allowedTCPPorts = [ ... ]; networking.firewall.allowedUDPPorts = [ ... ]; Or disable the firewall 
  # altogether. networking.firewall.enable = false;

  # NO TOUCH!
  system.copySystemConfiguration = true;
  system.stateVersion = "24.11";
}

