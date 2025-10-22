{ config, pkgs, ... }: {

  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  networking.hostName = "nixbox";
 
  # normal config
  # imports = [ 
  #   ./modules/nvda/desktop.nix 
  #   ./modules/games/default.nix
  # ];

  # gaming config
  imports = [ 
    ./modules/nvda/beta.nix 
    ./modules/games/default.nix
  ];

# Power management - disable all suspend/sleep due to NVIDIA issues
  services.logind = {
    lidSwitch = "ignore";
    powerKey = "ignore";
    extraConfig = ''
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      HandleLidSwitch=ignore
      IdleAction=ignore
    '';
  };

  programs.bash = {
    shellAliases = {
      rebuild = ''
      sudo nixos-rebuild switch --flake ~/nixos/nixos#desktop
      '';
    };
  };
}
