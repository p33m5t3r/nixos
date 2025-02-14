{ config, pkgs, ... }: {

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  networking.hostName = "desktop";
  
  imports = [ ./modules/nvda/desktop.nix ];
  home-manager.users.anon.imports = [ ./home/sway/desktop.nix ];
}
