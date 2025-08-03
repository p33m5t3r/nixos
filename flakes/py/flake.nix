{
  description = "Simple Python development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { 
          inherit system;
          config.allowUnfree = true;
        };
        py = pkgs.python3Packages;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Python core
            python3
            uv
            py.ipython
            py.python-lsp-server
            
            # CUDA/NVIDIA
            cudatoolkit
            linuxPackages.nvidia_x11_production
            
            # Additional CUDA packages that torch might need
            cudaPackages.cuda_cudart
            cudaPackages.cuda_nvcc
            cudaPackages.cuda_nvrtc
            cudaPackages.cudnn
            
            # System libs
            stdenv.cc.cc
            zlib
          ];
          
          shellHook = ''
            export CUDA_PATH=${pkgs.cudatoolkit}
            export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11_production}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.cudaPackages.cuda_cudart}/lib:${pkgs.cudaPackages.cudnn}/lib
            export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11_production}/lib"
            export EXTRA_CCFLAGS="-I/usr/include"
            
            # Additional CUDA env vars that torch might look for
            export CUDA_HOME=${pkgs.cudatoolkit}
            export CUDA_ROOT=${pkgs.cudatoolkit}
            export CUDNN_PATH=${pkgs.cudaPackages.cudnn}
          '';
        };
      });
}
