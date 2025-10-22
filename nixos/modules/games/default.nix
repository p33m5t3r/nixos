{ config, pkgs, ... }:

{
  # services.xserver.enable = true;

  programs.gamemode.enable = true;
  programs.java.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    prismlauncher
    gamescope
    gamemode
    mangohud
    vkbasalt
  ];

  # common fixes; not needed usually
  # environment.sessionVariables = {
  #   WLR_NO_HARDWARE_CURSORS = "1";
  #   NIXOS_OZONE_WL = "1";
  #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  #   GBM_BACKEND = "nvidia-drm";
  # };
}
