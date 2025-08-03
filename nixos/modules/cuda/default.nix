{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # CUDA/NVIDIA packages
    cudatoolkit
    linuxPackages.nvidia_x11_production
    cudaPackages.cuda_cudart
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_nvrtc
    cudaPackages.cudnn
    stdenv.cc.cc
    zlib
  ];
  
  environment.sessionVariables = {
    CUDA_PATH = "${pkgs.cudatoolkit}";
    CUDA_HOME = "${pkgs.cudatoolkit}";
    CUDA_ROOT = "${pkgs.cudatoolkit}";
    CUDNN_PATH = "${pkgs.cudaPackages.cudnn}";
  };
  
  # Add to LD_LIBRARY_PATH
  environment.variables.LD_LIBRARY_PATH = lib.mkForce (lib.concatStringsSep ":" [
    "${pkgs.linuxPackages.nvidia_x11_production}/lib"
    # "${pkgs.stdenv.cc.cc.lib}/lib"  # Commented out - causes Hyprland GLIBCXX conflict
    "${pkgs.cudaPackages.cuda_cudart}/lib"
    "${pkgs.cudaPackages.cudnn}/lib"
    "\${LD_LIBRARY_PATH}"
  ]);
}