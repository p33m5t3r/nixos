{ config, lib, ... }:

{
  imports = [ ./default.nix ];
  
  wayland.windowManager.sway.config = {
    output = {
      "HDMI-A-1" = {
        mode = "2560x1440@74.964Hz";
        transform = "270";
        position = "0,0";
      };
      "DP-1" = {
        mode = "1920x1080@143.855Hz";
        position = "1440,800";
      };
    };
  };
}
