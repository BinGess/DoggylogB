#!/usr/bin/env bash
set -euo pipefail

# Two illustrated poses per dog: standing and a genuinely redrawn airborne
# pose. Each dog gets its own rhythm and arc. Keep PNGs for previews and widgets.
# Requires ffmpeg.
cd "$(dirname "$0")/.."

frame_dir=$(mktemp -d)
trap 'rm -rf "$frame_dir"' EXIT

for name in border_collie_cocoa dachshund_cocoa dalmatian_spot; do
  # pose / horizontal offset / vertical offset / direction / rendered height.
  # A shorter standing frame keeps the paws on the baseline during a crouch.
  case "$name" in
    border_collie_cocoa)
      # Quick, playful double hops with very short pauses.
      fps=12
      frames=(
        'stand 0 0 right 270'
        'stand 0 20 right 250'
        'jump -10 -14 left 270'
        'jump -25 -29 left 270'
        'jump -31 -15 left 270'
        'stand -31 0 left 270'
        'stand -31 12 left 258'
        'jump -13 -17 right 270'
        'jump 8 -31 right 270'
        'jump 29 -16 right 270'
        'stand 29 0 right 270'
        'stand 29 17 right 253'
        'jump 13 -17 left 270'
        'jump -12 -27 left 270'
        'stand -18 0 left 270'
        'stand -18 14 left 256'
        'jump 0 -16 right 270'
        'jump 17 -28 right 270'
        'stand 19 0 right 270'
        'jump 7 -16 left 270'
        'jump -5 -24 left 270'
        'stand 0 0 right 270'
        'stand 0 0 right 270'
        'stand 0 0 right 270'
      )
      ;;
    dachshund_cocoa)
      # Longer wind-up, low springy arcs, and an unhurried landing.
      fps=10
      frames=(
        'stand 0 0 right 270'
        'stand 0 0 right 270'
        'stand 0 24 right 246'
        'stand 0 32 right 238'
        'jump -10 -8 left 270'
        'jump -23 -16 left 270'
        'jump -33 -9 left 270'
        'stand -33 0 left 270'
        'stand -33 0 left 270'
        'stand -33 0 left 270'
        'stand -33 24 left 246'
        'stand -33 32 left 238'
        'jump -12 -8 right 270'
        'jump 12 -17 right 270'
        'jump 33 -9 right 270'
        'stand 33 0 right 270'
        'stand 33 0 right 270'
        'stand 33 0 right 270'
        'stand 33 28 right 242'
        'jump 16 -8 left 270'
        'jump 0 -14 left 270'
        'stand 0 0 right 270'
        'stand 0 0 right 270'
        'stand 0 0 right 270'
      )
      ;;
    dalmatian_spot)
      # Athletic bounds with more airtime and longer side-to-side travel.
      fps=10
      frames=(
        'stand 0 0 right 270'
        'stand 0 15 right 255'
        'jump -12 -21 left 270'
        'jump -29 -40 left 270'
        'jump -41 -43 left 270'
        'jump -42 -24 left 270'
        'stand -42 0 left 270'
        'stand -42 0 left 270'
        'stand -42 16 left 254'
        'jump -20 -23 right 270'
        'jump 0 -40 right 270'
        'jump 24 -43 right 270'
        'jump 42 -22 right 270'
        'stand 42 0 right 270'
        'stand 42 0 right 270'
        'stand 42 16 right 254'
        'jump 25 -22 left 270'
        'jump 8 -39 left 270'
        'jump -7 -40 left 270'
        'jump -12 -21 left 270'
        'stand 0 0 right 270'
        'stand 0 0 right 270'
        'stand 0 0 right 270'
        'stand 0 0 right 270'
      )
      ;;
  esac
  for index in "${!frames[@]}"; do
    read -r pose dx dy direction height <<< "${frames[index]}"
    source="assets/skin_candidates/${name}_jump.png"
    if [[ "$pose" == stand ]]; then
      source="assets/images/calendar/${name}_timeline.png"
    fi
    filters="scale=270:${height}:flags=lanczos,format=rgba"
    if [[ "$direction" == left ]]; then
      filters+=",hflip"
    fi
    filters+=",pad=360:360:$((45 + dx)):$((45 + dy)):color=black@0"
    printf -v filename '%s/frame_%02d.png' "$frame_dir" "$index"
    ffmpeg -hide_banner -loglevel error -i "$source" \
      -vf "$filters" -frames:v 1 -y "$filename"
  done

  ffmpeg -hide_banner -loglevel error -framerate "$fps" \
    -i "$frame_dir/frame_%02d.png" \
    -filter_complex '[0:v]split[a][b];[a]palettegen=reserve_transparent=1:transparency_color=0x000000[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:alpha_threshold=64[out]' \
    -map '[out]' -frames:v "${#frames[@]}" -loop 0 -y \
    "assets/images/calendar/${name}_timeline.gif"
done
