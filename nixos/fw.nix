# framework 13 (amd ai 300)
{ config, pkgs, ... }: {

  boot.resumeDevice = "/dev/mapper/cryptswap";
  networking.hostName = "fw";
  imports = [
    ./modules/gamecube-adapter
  ];

  # desktop enables this from modules/games, which laptop.nix does not import
  hardware.gamecube-adapter.enable = true;

  programs.zsh.shellAliases.rebuild = "sudo nixos-rebuild switch --flake ~/nixos/nixos#fw";

  # release this machine was first installed with. NO TOUCH!
  system.stateVersion = "26.05";
}
