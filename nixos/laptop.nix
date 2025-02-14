# laptop.nix
{ config, pkgs, ... }: {

  networking.hostName = "nixos";
  imports = [ ./modules/nvda/laptop.nix ];
  home-manager.users.anon.imports = [ ./home/sway/laptop.nix ];
}
