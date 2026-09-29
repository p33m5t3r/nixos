# flake.nix
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware/hardware-configuration-laptop.nix
          ./shared.nix
          ./laptop.nix
        ];
      };
      fw = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware/hardware-configuration-fw.nix
          nixos-hardware.nixosModules.framework-amd-ai-300-series
          ./shared.nix
          ./fw.nix
        ];
      };
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware/hardware-configuration-desktop.nix
          ./shared.nix
          ./desktop.nix
        ];
      };
    };
  };
}
