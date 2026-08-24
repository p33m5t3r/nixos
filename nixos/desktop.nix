{ config, pkgs, ... }: {

  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  networking.hostName = "nixbox";
 
  imports = [ 
    ./modules/nvda/beta.nix 
    ./modules/games/default.nix
  ];

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
    HandleLidSwitch = "ignore";
    IdleAction = "ignore";
  };

  programs.zsh.shellAliases.rebuild = "sudo nixos-rebuild switch --flake ~/nixos/nixos#desktop";

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
