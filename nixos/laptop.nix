# laptop.nix
{ config, pkgs, ... }: {

  networking.hostName = "nixos";
  imports = [ ./modules/nvda/laptop.nix ];

  services.logind = {
    # lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  programs.bash = {
      shellAliases = {
        rebuild = ''
        sudo nixos-rebuild switch --flake ~/nixos/nixos#laptop
        '';
      };
    };
}
