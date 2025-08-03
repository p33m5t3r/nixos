# laptop.nix
{ config, pkgs, ... }: {

  networking.hostName = "nixos";
  imports = [ ./modules/nvda/laptop.nix ];

  programs.bash = {
      shellAliases = {
        rebuild = ''
        sudo nixos-rebuild switch --flake ~/nixos/nixos#laptop
        '';
      };
    };
}
