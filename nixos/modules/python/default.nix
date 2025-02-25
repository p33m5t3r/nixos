{ config, pkgs, ... }:
let py = pkgs.python3Packages;
in {
  environment.systemPackages = with pkgs; [
    python3	# system-wide python
    pyright
  ];
  # ++ (with py; [
  #   python-lsp-server
  # ]);
}

