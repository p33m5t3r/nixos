{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    git	     # for packer
    ripgrep  # for telescope
  ];

  # programs.bash = {
  #   shellAliases = {
  #     vim = "nvim";
  #   };
  # };
}
