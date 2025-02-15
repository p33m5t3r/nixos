{
  description = "Simple Python development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        py = pkgs.python3Packages;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            uv
            py.ipython
            py.python-lsp-server
            
            # Core system libraries
            stdenv.cc.cc
            zlib
            openssl
          ];

          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc
              pkgs.zlib
              pkgs.openssl
            ]}"
          '';
        };
      });
}
