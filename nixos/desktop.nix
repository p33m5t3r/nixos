{ config, pkgs, ... }: {


  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  networking.hostName = "desktop";
  
  imports = [ 
    ./modules/nvda/desktop.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    users.anon = {
      imports = [ ./home/sway/desktop.nix ];
      home.stateVersion = "24.11";
    };
  };
}
