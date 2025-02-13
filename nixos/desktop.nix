{ config, pkgs, ... }: {


  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  networking.hostName = "desktop";
  
  imports = [ 
    ./modules/nvda
  ];

  # home-manager = {
  #   useGlobalPkgs = true;
  #   users.anon = {
  #     wayland.windowManager.sway = {
  #       enable = true;
  #       config = {
  #         # Your desktop-specific Sway config here
  #         # e.g., different monitor setup
  #       };
  #     };
  #   };
  # };
}
