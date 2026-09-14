#!/usr/bin/env bash
# Encrypted local backup of AmneziaVPN's config. Not committed to git.
set -euo pipefail

SRC="$HOME/.config/AmneziaVPN.ORG"
OUT_DIR="$HOME/.local/backups"
OUT="$OUT_DIR/amneziavpn-$(date +%Y%m%d-%H%M%S).tar.gz.gpg"

if [[ ! -d "$SRC" ]]; then
  echo "No AmneziaVPN config found at $SRC — nothing to back up."
  exit 1
fi

mkdir -p "$OUT_DIR"
tar -C "$HOME/.config" -czf - "AmneziaVPN.ORG" | gpg -c --cipher-algo AES256 -o "$OUT"

echo "Encrypted backup: $OUT"
echo "Restore with:"
echo "  gpg -d '$OUT' | tar -C ~/.config -xzf -"
