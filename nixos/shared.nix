{ config, lib, pkgs, ... }:
with lib;
let
  mkOutOfStoreSymlink = path:
    let
      pathStr = toString path;
      name = baseNameOf pathStr;
    in
      pkgs.runCommandLocal name {} ''ln -s ${escapeShellArg pathStr} $out'';
in {
  imports = [ 
    ./modules/neovim
    # ./modules/python
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home-manager = {
    useGlobalPkgs = true;
    users.anon = {
      home.stateVersion = "24.11";
      # home.file.".config/nvim/init.lua".source =
      #  mkOutOfStoreSymlink ../.config/nvim/init.lua;
      home.file.".config/swaylock".source = ../.config/swaylock;
      home.file.".config/kitty".source = ../.config/kitty;
      home.file.".config/waybar".source = ../.config/waybar;
      home.file.".config/wofi".source = ../.config/wofi;
    };
  };

  environment.systemPackages = with pkgs; [
    # graphical user programs
    firefox google-chrome

    # cli utils
    git wget psmisc htop ranger pciutils lshw

    # audio
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

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.networkmanager.enable = true;
  time.timeZone = "America/Denver";

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ 
      "FiraCode" 
      "ProggyClean"
      "BigBlueTerminal" 
      ]; 
    })
  ];

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

  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
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

  services.libinput.enable = true;
  services.openssh.enable = true;

  users.users.anon = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "audio"];
    initialPassword = "anon";
  };

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=120
  '';

  # NO TOUCH!
  system.stateVersion = "24.11";
}
