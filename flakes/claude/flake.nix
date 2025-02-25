{
  description = "Claude Code CLI development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Create a script that installs and runs the Claude CLI
        claude-cli-wrapper = pkgs.writeShellScriptBin "claude" ''
          # Create local npm directory if it doesn't exist
          CLAUDE_NPM_DIR="$HOME/.claude-code-npm"
          mkdir -p "$CLAUDE_NPM_DIR"
          
          # Install the package if needed
          if [ ! -f "$CLAUDE_NPM_DIR/bin/claude" ]; then
            echo "Installing Claude Code CLI..."
            NPM_CONFIG_PREFIX="$CLAUDE_NPM_DIR" ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code
          fi
          
          # Run the claude command with all arguments passed through
          PATH="$CLAUDE_NPM_DIR/bin:$PATH" "$CLAUDE_NPM_DIR/bin/claude" "$@"
        '';
      in
      {
        # Make the wrapper available as a package
        packages.default = claude-cli-wrapper;
        
        # Create a development shell with the wrapper
        devShells.default = pkgs.mkShell {
          buildInputs = [
            claude-cli-wrapper
            pkgs.nodejs
          ];
          shellHook = ''
            echo "Claude CLI environment loaded!"
            echo "Run 'claude' to use the CLI"
          '';
        };
      });
}
