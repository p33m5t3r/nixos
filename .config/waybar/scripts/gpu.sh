#!/usr/bin/env bash
# GPU vram usage + temperature for waybar
read -r used total temp < <(
  nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu \
             --format=csv,noheader,nounits 2>/dev/null | tr -d ',' 
)
[ -z "$temp" ] && { echo "n/a"; exit 0; }
awk -v u="$used" -v t="$total" -v c="$temp" \
  'BEGIN { printf "%4.1fG/%.0fG +%2d°C\n", u/1024, t/1024, c }'
