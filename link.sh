#!/usr/bin/env bash
# symlink dotfiles from this repo into $HOME. safe to re-run.
set -euo pipefail
repo="$(cd "$(dirname "$0")" && pwd)"

# "repo path:home path"
links=(
  ".config/claude:.config/claude"
  ".config/htop:.config/htop"
  ".config/hypr:.config/hypr"
  ".config/kitty:.config/kitty"
  ".config/nvim:.config/nvim"
  ".config/ranger:.config/ranger"
  ".config/themes:.config/themes"
  ".config/waybar:.config/waybar"
  ".config/wofi:.config/wofi"
  ".config/zathura:.config/zathura"
  ".config/zsh/.zshrc:.zshrc"
  ".tmux.conf:.tmux.conf"
)

mkdir -p "$HOME/.config"
for pair in "${links[@]}"; do
  src="$repo/${pair%%:*}"
  dst="$HOME/${pair##*:}"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "skip: $dst exists and isn't a symlink (move it aside first)"
  else
    ln -sfn "$src" "$dst"
    echo "ok:   $dst -> $src"
  fi
done
