# laptop.nix
{ config, pkgs, ... }: {

  networking.hostName = "nixos";
  imports = [ 
      ./modules/nvda/laptop.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    users.anon = {
      imports = [ ./home/sway/laptop.nix ];
      home.stateVersion = "24.11";
    }; 
  };
}
