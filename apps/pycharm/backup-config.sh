#!/usr/bin/env bash
# Snapshot the safe, non-secret subset of PyCharm's config (keymaps, color
# schemes, code styles) to a local, non-git backup directory. Auto-detects
# the newest JetBrains/PyCharm* config dir under ~/.config/JetBrains.
set -euo pipefail

CFG_DIR="$(find "$HOME/.config/JetBrains" -maxdepth 1 -iname 'PyCharm*' -type d 2>/dev/null | sort | tail -n1)"
OUT_DIR="$HOME/.local/backups/pycharm-$(date +%Y%m%d-%H%M%S)"

if [[ -z "$CFG_DIR" ]]; then
  echo "No ~/.config/JetBrains/PyCharm* directory found."
  exit 1
fi

mkdir -p "$OUT_DIR"
for sub in keymaps colors codestyles templates; do
  if [[ -d "$CFG_DIR/$sub" ]]; then
    cp -r "$CFG_DIR/$sub" "$OUT_DIR/"
  fi
done

echo "Backed up $CFG_DIR/{keymaps,colors,codestyles,templates} -> $OUT_DIR"
