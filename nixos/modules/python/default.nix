{ config, pkgs, ... }:
let py = pkgs.python3Packages;
in {
  environment.systemPackages = with pkgs; [
    python3	# system-wide python
  ] ++ (with py; [
    python-lsp-server
  ]);
}

