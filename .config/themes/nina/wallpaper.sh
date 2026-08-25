#!/usr/bin/env bash
# nina — wallpaper generator
#
# Regenerates ~/wallpaper/nina-{main,side}.png. Run it by hand after editing;
# nothing calls it automatically, since swaybg only ever reads the PNGs.
#
# Flat cool paper with a fine blue grid and a coarse ink grid over it. The
# background sits a little cooler and darker than the theme's own paper so that
# windows read as sheets laid on a desk; move $bg toward #f6f2ee to flatten that
# separation, or toward #dfe4f2 to deepen it.
#
# Grid pitch is given in output pixels, so it's sized per monitor to land at
# roughly the same apparent scale on both.
set -euo pipefail

out_dir="${1:-$HOME/wallpaper}"
mkdir -p "$out_dir"

bg="#e7e9f0"       # the desk
fine="#2b2bd8"     # fine grid, laid down at 5% alpha
coarse="#14140f"   # coarse grid, laid down at 8% alpha

# render W H FINE_PITCH COARSE_PITCH OUTFILE
render() {
  local w=$1 h=$2 fp=$3 cp=$4 dest=$5

  magick -size "${w}x${h}" "xc:${bg}" \
    \( -size "${fp}x${fp}" xc:none -fill "$fine" \
       -draw "rectangle 0,0 0,$(( fp - 1 ))" \
       -draw "rectangle 0,0 $(( fp - 1 )),0" \
       -write mpr:fine +delete \
       -size "${w}x${h}" tile:mpr:fine -alpha set -channel A -evaluate multiply 0.05 +channel \) \
    -compose over -composite \
    \( -size "${cp}x${cp}" xc:none -fill "$coarse" \
       -draw "rectangle 0,0 0,$(( cp - 1 ))" \
       -draw "rectangle 0,0 $(( cp - 1 )),0" \
       -write mpr:coarse +delete \
       -size "${w}x${h}" tile:mpr:coarse -alpha set -channel A -evaluate multiply 0.08 +channel \) \
    -compose over -composite \
    -alpha off -depth 8 \
    "$dest"
  echo "$dest"
}

# main: 3840x2160 at scale 1.5 -> 2560x1440 logical, so pitch is 1.5x the mock's
render 3840 2160  69 345 "$out_dir/nina-main.png"

# side: 2560x1440 rotated 90 (transform 3), so the image is portrait
render 1440 2560  46 230 "$out_dir/nina-side.png"
