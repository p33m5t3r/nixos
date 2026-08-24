# laptop.nix
{ config, pkgs, ... }: {

  networking.hostName = "nixos";
  imports = [ ./modules/nvda/laptop.nix ];

  programs.zsh.shellAliases.rebuild = "sudo nixos-rebuild switch --flake ~/nixos/nixos#laptop";
}
