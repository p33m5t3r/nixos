# Adapter support for Slippi / Dolphin.
#
# These two things genuinely cannot live in a user-level flake:
#   1. udev rules   -- they are read by the system udev daemon
#   2. kernel module -- it has to be built against the running kernel
#
# Imported by desktop.nix (enabled via modules/games) and laptop.nix.
#
{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.gamecube-adapter;
in {
  options.hardware.gamecube-adapter = {
    enable = lib.mkEnableOption "Wii U / Mayflash GameCube controller adapter";

    overclock = {
      enable = lib.mkEnableOption "1000 Hz polling for the adapter" // {
        default = true;
      };

      rate = lib.mkOption {
        type = lib.types.ints.between 1 16;
        default = 1;
        description = ''
          USB polling interval in milliseconds. 1 = 1000 Hz, which is what
          Melee players want. Measured stock rate on the Mayflash/WUP-028 is
          bInterval=8, i.e. 8 ms / 125 Hz.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Let a normal logged-in user talk to the adapter over libusb. Without
    # this, Dolphin only sees it as root.
    services.udev.extraRules = ''
      # Nintendo Wii U / Mayflash GameCube controller adapter
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", TAG+="uaccess"
    '';

    boot = lib.mkIf cfg.overclock.enable {
      extraModulePackages = [ config.boot.kernelPackages.gcadapter-oc-kmod ];
      kernelModules = [ "gcadapter_oc" ];
      extraModprobeConfig = ''
        options gcadapter_oc rate=${toString cfg.overclock.rate}
      '';
    };
  };
}
