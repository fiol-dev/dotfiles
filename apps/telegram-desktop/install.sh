#!/usr/bin/env bash
# telegram-desktop — official [extra] repo package, no AUR needed.
set -euo pipefail

sudo pacman -S --needed telegram-desktop

echo
echo "✓ telegram-desktop installed."
