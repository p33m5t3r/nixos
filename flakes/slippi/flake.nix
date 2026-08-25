{
  description = "Slippi (Melee netplay) + GameCube adapter support";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        slippi-launcher = pkgs.callPackage ./slippi-launcher.nix { };
        default = self.packages.${system}.slippi-launcher;

        # Debug helper: a shell inside the *same* FHS sandbox the launcher
        # runs in, for poking at the downloaded Dolphin by hand.
        #   nix run .#fhs-shell
        fhs-shell = pkgs.buildFHSEnv (pkgs.appimageTools.defaultFhsEnvArgs // {
          name = "slippi-fhs";
          targetPkgs = p:
            pkgs.appimageTools.defaultFhsEnvArgs.targetPkgs p
            ++ (import ./runtime-deps.nix p);
          runScript = "bash";
        });
      };

      # `nix run .` / `nix run .#slippi-launcher`
      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.slippi-launcher}/bin/slippi-launcher";
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.usbutils pkgs.evtest ];
      };
    };
}
