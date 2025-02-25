{ config, lib, pkgs, ... }:
let
  mkPythonScript = { name, scriptName, requirements ? [] }: 
    pkgs.writeScriptBin name ''
      #!${pkgs.bash}/bin/bash
      VENV_DIR="$HOME/.cache/nix-python-scripts/${name}"
      SCRIPT_PATH="${config.modules.scripts.scriptsPath}/${scriptName}"
      
      if [ ! -d "$VENV_DIR" ]; then
        echo "Setting up virtualenv for ${name}..."
        mkdir -p "$VENV_DIR"
        ${pkgs.python3}/bin/python3 -m venv "$VENV_DIR"
        source "$VENV_DIR/bin/activate"
        pip install --quiet ${lib.concatStringsSep " " requirements}
      else
        source "$VENV_DIR/bin/activate"
      fi
      
      python3 "$SCRIPT_PATH" "$@"
    '';

in {
  options.modules.scripts = {
    enable = lib.mkEnableOption "custom scripts";
    scriptsPath = lib.mkOption {
      type = lib.types.str;
      description = "Base path to scripts directory";
    };
  };

  config = lib.mkIf config.modules.scripts.enable {
    environment.systemPackages = with pkgs; [
      python3
      python3.pkgs.pip
      
      (mkPythonScript {
        name = "hey";
        scriptName = "hey.py";
        requirements = [ "anthropic" ];
      })
    ];
  };
}
