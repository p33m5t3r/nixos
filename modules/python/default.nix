{ config, pkgs, ... }:
let py = pkgs.python3Packages;
in {
  environment.systemPackages = with pkgs; [
    python3	# system-wide python
    uv		# for actual projects
  ] ++ (with py; [
    python-lsp-server
  ]);
}

