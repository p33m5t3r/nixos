# docker.nix - Docker configuration module for NixOS
{ config, lib, pkgs, ... }:

{
  # Enable Docker daemon
  virtualisation.docker = {
    enable = true;
    # Default Docker daemon configuration
    enableOnBoot = true;
    autoPrune.enable = true;  # Auto-cleanup of unused images/containers
    
    # Uncomment and modify any additional options you need
    # extraOptions = "--default-address-pool base=10.10.0.0/16,size=24";
  };

  # Add user to the docker group to run commands without sudo
  users.users.anon.extraGroups = [ "docker" ];
  
  # Install Docker related packages
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}