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
          # Create a dedicated npm directory for Claude with proper permissions
          CLAUDE_NPM_DIR="$HOME/.npm-global"
          mkdir -p "$CLAUDE_NPM_DIR"
          
          # Configure npm to use the custom global directory
          ${pkgs.nodejs}/bin/npm config set prefix "$CLAUDE_NPM_DIR"
          
          # Install the package if needed
          if [ ! -f "$CLAUDE_NPM_DIR/bin/claude" ]; then
            echo "Installing Claude Code CLI..."
            PATH="$CLAUDE_NPM_DIR/bin:$PATH" ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code
          fi
          
          # Set environment variable for the npm update path to be correct
          export NPM_CONFIG_PREFIX="$CLAUDE_NPM_DIR"
          
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
