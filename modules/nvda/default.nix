{ config, pkgs, ... }:
{
  hardware.graphics.enable = true;

  hardware.nvidia = {
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:45:0:0";
    };
  };

  environment.systemPackages = with pkgs; [
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
    cudatoolkit
    stdenv.cc.cc.lib  # for libstdc++
    # config.boot.kernelPackages.nvidia_x11.bin
    config.boot.kernelPackages.nvidiaPackages.production.bin
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidiaPackages.production ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  environment.variables = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      "${pkgs.stdenv.cc.cc.lib}/lib"
      "${pkgs.cudaPackages.cudatoolkit}/lib"
    ];
  };
}
