{ config, lib, ... }:

{
  imports = [ ./default.nix ];
  
  wayland.windowManager.sway.config = {
    output = {
      "eDP-1" = {
        position = "0,0";
      };
      "HDMI-A-2" = {
        mode = "2560x1440@59.95Hz";
        position = "1920,0";
      };
    };
  };
}
