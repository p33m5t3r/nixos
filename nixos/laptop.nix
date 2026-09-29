# laptop.nix
{ config, pkgs, ... }: {

  networking.hostName = "nixos";
  imports = [
    ./modules/nvda/laptop.nix
    ./modules/gamecube-adapter
  ];

  # desktop enables this from modules/games, which laptop.nix does not import
  hardware.gamecube-adapter.enable = true;

  programs.zsh.shellAliases.rebuild = "sudo nixos-rebuild switch --flake ~/nixos/nixos#laptop";

  # release this machine was first installed with. NO TOUCH!
  system.stateVersion = "24.11";
}
