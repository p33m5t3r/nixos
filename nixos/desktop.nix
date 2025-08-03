{ config, pkgs, ... }: {

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  networking.hostName = "desktop";
  
  imports = [ ./modules/nvda/desktop.nix ];

  programs.bash = {
    shellAliases = {
      rebuild = ''
      sudo nixos-rebuild switch --flake ~/nixos/nixos#desktop
      '';
    };
  };
}
